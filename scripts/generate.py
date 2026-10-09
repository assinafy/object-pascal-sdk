"""Generate Pascal resource methods and API reference from the published contract."""

import argparse
import json
import re
from pathlib import Path
from urllib.parse import quote, urlencode

ROOT = Path(__file__).resolve().parents[1]
SPEC = json.loads((ROOT / 'docs/openapi.json').read_text(encoding='utf-8'))
METHODS = {'get', 'post', 'put', 'patch', 'delete'}
SECURITY_MODES = {
    frozenset(): 'aaPublic',
    frozenset({'signerAccessCode'}): 'aaSigner',
    frozenset({'bearerAuth'}): 'aaBearer',
    frozenset({'oauth2'}): 'aaBearer',
    frozenset({'bearerAuth', 'oauth2'}): 'aaBearer',
    frozenset({'bearerAuth', 'apiKeyAuth'}): 'aaAPI',
    frozenset({'signerAccessCode', 'bearerAuth', 'apiKeyAuth'}): 'aaSignerOrAPI',
}
MULTIPART_MEDIA = {'/v1/accounts/{accountId}/documents': 'application/pdf',
                   '/v1/accounts/{accountId}/logo': 'application/octet-stream'}
OVERRIDES = {
    'Exchange a code, refresh token, or subject token for an access token': 'ExchangeOAuthToken',
    'Revoke a token': 'RevokeOAuthToken',
    'OpenID Connect userinfo': 'GetOAuthUserInfo',
    'OAuth 2.0 protected resource metadata': 'GetOAuthResourceMetadata',
    'Upload and create document': 'UploadDocument',
    'Upload account logo': 'UploadAccountLogo',
    'Upload signature image': 'UploadSignatureImage',
    'Get the authenticated user': 'GetUser',
    'Account document KPIs': 'GetAccountStats',
    'My cross-account document KPIs': 'GetUserStats',
    "Get signer's document": 'GetSignerDocument',
    "List signer's documents": 'ListSignerDocuments',
    "Search signer's documents": 'SearchSignerDocuments',
    "Download signer's document artifact": 'DownloadSignerDocumentArtifact',
}


def resolve(value):
    while isinstance(value, dict) and '$ref' in value:
        reference = value['$ref']
        if not reference.startswith('#/'):
            raise ValueError(f'External reference: {reference}')
        value = SPEC
        for part in reference[2:].split('/'):
            value = value[part.replace('~1', '/').replace('~0', '~')]
    return value


def method_name(summary):
    if summary in OVERRIDES:
        return OVERRIDES[summary]
    summary = re.sub(r'\([^)]*\)', '', summary)
    return ''.join(word[:1].upper() + word[1:] for word in re.findall(r'[A-Za-z0-9]+', summary))


def operations():
    names = set()
    for path, item in SPEC['paths'].items():
        for verb, operation in item.items():
            if verb not in METHODS:
                continue
            name = method_name(operation['summary'])
            if name.lower() in names:
                raise ValueError(f'Duplicate Pascal method: {name}')
            names.add(name.lower())
            parameters = list({(x['in'], x['name']): x for x in map(resolve,
                              item.get('parameters', []) + operation.get('parameters', []))}.values())
            path_names = re.findall(r'\{([^}]+)\}', path)
            if set(path_names) != {x['name'] for x in parameters if x['in'] == 'path'}:
                raise ValueError(f'Path parameters do not match URI: {path}')
            paths = [x[:1].upper() + x[1:] for x in path_names]
            security = operation.get('security', SPEC.get('security', []))
            schemes = set()
            for alternative in security:
                if len(alternative) > 1:
                    raise ValueError(f'Unsupported combined security: {path}')
                for scheme in alternative:
                    if scheme not in {'signerAccessCode', 'bearerAuth', 'apiKeyAuth', 'oauth2'}:
                        raise ValueError(f'Unsupported security scheme: {scheme}')
                    if scheme not in SPEC['components']['securitySchemes']:
                        raise ValueError(f'Undefined security scheme: {scheme}')
                    schemes.add(scheme)
            if any(not alternative for alternative in security):
                schemes.clear()
            if frozenset(schemes) not in SECURITY_MODES:
                raise ValueError(f'Unsupported security alternatives: {path}')
            auth = SECURITY_MODES[frozenset(schemes)]
            if path == '/v1/oauth/userinfo':
                auth = 'aaBearer'
            signer = auth in {'aaSigner', 'aaSignerOrAPI'}
            api = auth in {'aaAPI', 'aaBearer', 'aaSignerOrAPI'}
            body_spec = resolve(operation.get('requestBody', {}))
            content = body_spec.get('content', {})
            if len(content) > 1 and set(content) != {'application/json', 'application/x-www-form-urlencoded'}:
                raise ValueError(f'Unsupported request media alternatives: {path}')
            file_field, media_type = '', ''
            custom_media = False
            if 'multipart/form-data' in content:
                multipart = content['multipart/form-data']
                properties = resolve(multipart['schema']).get('properties', {})
                if len(properties) != 1:
                    raise ValueError(f'Unsupported multipart fields: {path}')
                file_field, file_schema = next(iter(properties.items()))
                if resolve(file_schema).get('format') != 'binary':
                    raise ValueError(f'Multipart field must be binary: {path}')
                media_type = multipart.get('encoding', {}).get(file_field, {}).get('contentType', '')
                media_type = media_type or resolve(file_schema).get('contentMediaType', '')
                custom_media = not media_type and MULTIPART_MEDIA.get(path) == 'application/octet-stream'
                media_type = media_type or MULTIPART_MEDIA.get(path, '')
                if not media_type or ',' in media_type:
                    raise ValueError(f'Explicit multipart content type required: {path}')
            elif content and 'application/json' not in content:
                if len(content) != 1:
                    raise ValueError(f'Unsupported request media: {path}')
                media_type = next(iter(content))
                if resolve(content[media_type].get('schema', {})).get('format') != 'binary':
                    raise ValueError(f'Unsupported request body: {path}')
            is_file = bool(media_type)
            has_body = 'application/json' in content
            if has_body:
                media_type = 'application/json'
            has_query = any(x['in'] == 'query' for x in parameters)
            args = [('A' + x if x == 'AccountId' else x, 'string', None) for x in paths]
            if signer and not api:
                args.append(('SignerAccessCode', 'string', None))
            if is_file:
                args.append(('FileName', 'string', None))
            if has_body:
                default = None if body_spec.get('required') else 'nil'
                args.append(('Body', 'TJSONData', default))
            if signer and api:
                args.append(('SignerAccessCode', 'string', "''"))
            if has_query:
                args.append(('Query', 'TStrings', 'nil'))
            if custom_media:
                args.append(('ContentType', 'string', "'application/octet-stream'"))
            yield {
                'name': name, 'path': path, 'verb': verb.upper(), 'op': operation,
                'parameters': parameters, 'paths': paths, 'auth': auth, 'args': args,
                'file': is_file, 'body': has_body, 'query': has_query,
                'signer': signer, 'content': content,
                'file_field': file_field, 'media_type': media_type,
                'required_body': body_spec.get('required', False),
                'custom_media': custom_media,
            }


def signature(op, defaults=True):
    parts = []
    for name, kind, default in op['args']:
        part = f'{name}: {kind}'
        if kind == 'string':
            part = 'const ' + part
        if defaults and default is not None:
            part += ' = ' + default
        parts.append(part)
    return '(' + '; '.join(parts) + ')' if parts else ''


def path_expression(op):
    path = op['path'].removeprefix('/v1')
    chunks = re.split(r'(\{[^}]+\})', path)
    return ' + '.join(
        f"PathValue({'A' if x == '{accountId}' else ''}{x[1].upper() + x[2:-1]}, '{x[1].upper() + x[2:-1]}')" if x.startswith('{')
        else "'" + x + "'" for x in chunks if x
    )


def generate_methods(ops):
    declarations, implementations, checks = [], [], []
    for op in ops:
        declarations.append(f"    // {op['verb']} {op['path']}; payloads: docs/API.md#{op['name'].lower()}")
        declarations.append(f"    function {op['name']}{signature(op)}: TAssinafyResponse;")
        impl = [f"function TAssinafyClient.{op['name']}{signature(op, False)}: TAssinafyResponse;", 'begin']
        if op['body'] and op['required_body']:
            impl.append("  if Body = nil then raise EAssinafyInputError.Create('Request body is required');")
        if op['file']:
            impl.append("  RequireValue(FileName, 'File name');")
        if op['custom_media']:
            impl.append("  RequireValue(ContentType, 'File content type');")
        field = "'" + op['file_field'].replace("'", "''") + "'"
        media = "'" + op['media_type'].replace("'", "''") + "'"
        request_media = 'ContentType' if op['custom_media'] else media
        impl.append(f"  Result := Call('{op['verb']}', {path_expression(op)}, {op['auth']},")
        impl.append(f"    {'Query' if op['query'] else 'nil'}, {'Body' if op['body'] else 'nil'}, {'FileName' if op['file'] else chr(39)*2}, {field}, {request_media}, {'SignerAccessCode' if op['signer'] else chr(39)*2});")
        impl += ['end;', '']
        implementations.extend(impl)
        args = []
        for name, kind, default in op['args']:
            if name == 'ContentType':
                args.append(default)
                continue
            args.append("''" if name == 'AAccountId' else "'" + name + "'" if kind == 'string' and name != 'FileName' else 'FixtureFile' if name == 'FileName' else 'TestBody' if name == 'Body' else 'TestQuery')
        call = '(' + ', '.join(args) + ')' if args else ''
        expected_path = op['path'].removeprefix('/v1')
        for key in re.findall(r'\{([^}]+)\}', expected_path):
            value = 'default-account' if key == 'accountId' else key[:1].upper() + key[1:]
            expected_path = expected_path.replace('{' + key + '}', value)
        query = {x['name']: str(example(x.get('schema', {}))).lower()
                 if x.get('schema', {}).get('type') == 'boolean'
                 else str(example(x.get('schema', {})))
                 for x in op['parameters'] if x['in'] == 'query'}
        if query:
            checks.append('  TestQuery.Clear;')
            for key, value in query.items():
                pair = (key + '=' + value).replace("'", "''")
                checks.append(f"  TestQuery.Add('{pair}');")
        suffix = '?' + urlencode(query, quote_via=quote) if query else ''
        if op['signer']:
            suffix += ('&' if suffix else '?') + 'signer-access-code=SignerAccessCode'
        root = 'https://sandbox.assinafy.com.br' if op['path'].startswith('/.well-known') else 'https://sandbox.assinafy.com.br/v1'
        expected_auth = 'signer' if op['signer'] else 'public' if op['auth'] == 'aaPublic' else 'bearer'
        checks += [f"  Response := Client.{op['name']}{call};", '  Response.Free;', f"  Check(Fake.LastMethod = '{op['verb']}', '{op['name']} verb');", f"  Check(Fake.LastURL = '{root + expected_path + suffix}', '{op['name']} URL');", f"  Check(Fake.LastAuth = '{expected_auth}', '{op['name']} authentication');"]
        if op['body']:
            checks.append(f"  Check(Fake.LastBody = JSONText(TestBody), '{op['name']} body');")
        if op['file']:
            checks.append(f"  Check(Fake.LastFile = FixtureFile, '{op['name']} file');")
            checks.append(f"  Check(Fake.LastFileField = {field}, '{op['name']} file field');")
        if op['file'] or op['body']:
            checks.append(f"  Check(Fake.LastContentType = {media}, '{op['name']} content type');")
        checks.append('')
    return {
        'src/resources.inc': '\n'.join(declarations) + '\n',
        'src/methods.inc': '\n'.join(implementations),
        'tests/operations.inc': '\n'.join(checks),
    }


def example(schema, trail=()):
    if not schema:
        return {}
    if '$ref' in schema:
        if schema['$ref'] in trail:
            return {}
        return example(resolve(schema), trail + (schema['$ref'],))
    if 'example' in schema:
        return schema['example']
    if 'const' in schema:
        return schema['const']
    if 'enum' in schema:
        return schema['enum'][0]
    if 'allOf' in schema:
        result = {}
        for part in schema['allOf']:
            value = example(part, trail)
            if isinstance(value, dict):
                result.update(value)
        return result
    for variant in ['oneOf', 'anyOf']:
        if variant in schema:
            return example(schema[variant][0], trail)
    kind = schema.get('type')
    if isinstance(kind, list):
        kind = next((x for x in kind if x != 'null'), 'null')
    if kind == 'object' or 'properties' in schema:
        return {name: example(value, trail) for name, value in schema.get('properties', {}).items()}
    if kind == 'array':
        return [example(schema.get('items', {}), trail)]
    if kind in ['integer', 'number']:
        return schema.get('minimum', 1)
    if kind == 'boolean':
        return False
    if kind == 'null':
        return None
    return {'email': 'developer@example.com', 'uri': 'https://app.example.com/resource', 'date-time': '2030-01-01T12:00:00Z', 'binary': '<binary bytes>'}.get(schema.get('format'), '<string>')


def code(value, language='json'):
    text = json.dumps(value, indent=2, ensure_ascii=False) if language == 'json' else value
    return f'```{language}\n{text}\n```\n'


def generate_docs(ops):
    lines = ['# API reference', '', 'Contract: [Assinafy API v1](https://api.assinafy.com.br/v1/docs) and [OpenAPI](https://api.assinafy.com.br/v1/docs/openapi.json).', '', f'The client exposes all {len(ops)} published operations. Each method below links its request, response, authentication, and status codes to the bundled [contract](openapi.json). Shared response models are fully defined in [Schemas](SCHEMAS.md).', '', '## Ownership and payloads', '', 'Every call returns a caller-owned `TAssinafyResponse`; free it in `finally`. `Response.JSON` contains the entire wire response; `Response.Data` refers to the envelope’s `data`, or the entire flat OAuth response. Both are borrowed until `Response.Free`. Requests borrow `Body` and `Query`; the caller frees them. Empty account IDs use the client’s configured account. Other path parameters are required and percent-encoded.', '', '`Query` is a `TStrings` of decoded `name=value` pairs; use the exact API field names. The SDK percent-encodes names and values, preserving duplicates and empty values. Send JSON booleans, arrays, numbers and explicit nulls using `AssinafyJson` helpers or the compiler’s native JSON classes. Binary response bytes remain in `Response.Body`; use `Response.SaveToStream` to write them after a successful request.', '', 'Payload examples show the documented fields, including optional fields. They illustrate shapes; follow each schema’s `required`, `enum`, constraints and descriptions when constructing an actual request. Placeholder values and mutually exclusive variants must be replaced with valid values. `{}` denotes an open object whose fields the API does not specify.', '', '## Operations', '', '| Method | HTTP operation |', '| --- | --- |']
    lines += [f"| [{op['name']}](#{op['name'].lower()}) | `{op['verb']} {op['path']}` |" for op in ops]
    for op in ops:
        lines += ['', f"## {op['name']}", '', code(f"function {op['name']}{signature(op)}: TAssinafyResponse;", 'pascal'), f"`{op['verb']} {op['path']}`", '', op['op'].get('description', op['op']['summary']), '']
        auth = {'aaPublic': 'Public: workspace credentials are omitted.', 'aaAPI': 'API key or bearer token. OAuth permissions are governed by the server’s scope and resource restrictions.', 'aaSigner': 'Required `SignerAccessCode` as the `signer-access-code` query parameter. Workspace credentials are omitted.', 'aaSignerOrAPI': 'Signer code when supplied; otherwise API key or bearer token.', 'aaBearer': 'Required bearer access token (`Client.AccessToken`).'}[op['auth']]
        lines += ['**Authentication:** ' + auth, '', '**Parameters:**']
        if op['custom_media']:
            lines += ['', '`ContentType` is an optional SDK parameter for the file part media type (for example `image/png` or `image/jpeg`); the default is `application/octet-stream`. It does not add a JSON field.']
        if not op['parameters']:
            lines += ['', 'No path or query parameters.']
        for parameter in op['parameters']:
            lines += ['', f"- `{parameter['name']}` ({parameter['in']}, {'required' if parameter.get('required') else 'optional'}): {parameter.get('description', '')}", code(parameter.get('schema', {}))]
        if op['content']:
            for media, content in op['content'].items():
                schema = content.get('schema', {})
                lines += ['', f"**Request: `{media}` ({'required' if op['required_body'] else 'optional'})**", '', code(resolve(schema)), '**Payload shape:**', '', code(example(schema))]
        else:
            lines += ['', '**Request body:** none.']
        for status, response in op['op'].get('responses', {}).items():
            response = resolve(response)
            lines += ['', f"**Response `{status}`:** {response.get('description', '')}"]
            for media, content in response.get('content', {}).items():
                schema = content.get('schema', {})
                lines += ['', f'Content type: `{media}`', '', code(schema)]
                if 'json' in media:
                    lines += ['**Payload shape:**', '', code(example(schema))]
                else:
                    lines += ['Raw binary bytes; preserved without JSON decoding.']
            if response.get('headers'):
                lines += ['', '**Response headers:**', '', code(response['headers'])]
    schemas = ['# Payload schemas', '', 'Complete shared request and response schemas from the [published API](https://api.assinafy.com.br/v1/docs). References use the identifiers in [openapi.json](openapi.json).', '']
    for name, schema in SPEC['components'].get('schemas', {}).items():
        schemas += [f'## {name}', '', code(schema), '**Payload shape:**', '', code(example(schema))]
    return {'docs/API.md': '\n'.join(lines) + '\n', 'docs/SCHEMAS.md': '\n'.join(schemas) + '\n'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Fail if generated files differ')
    args = parser.parse_args()
    ops = list(operations())
    outputs = generate_methods(ops) | generate_docs(ops)
    outputs = {name: '\n'.join(line.rstrip() for line in content.splitlines()).rstrip() + '\n'
               for name, content in outputs.items()}
    stale = []
    for name, content in outputs.items():
        path = ROOT / name
        if args.check:
            if not path.exists() or path.read_text(encoding='utf-8') != content:
                stale.append(name)
        else:
            path.write_text(content, encoding='utf-8')
    if stale:
        raise SystemExit('Regenerate files: ' + ', '.join(stale))
    print(f'{len(ops)} API operations and complete payload references verified.')


if __name__ == '__main__':
    main()
