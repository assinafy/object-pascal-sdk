"""Check API operation coverage, documentation links and source hygiene."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition, message):
    if not condition:
        raise SystemExit(message)


def expected_auth(operation, path):
    roles = set()
    for alternative in operation.get('security', spec.get('security', [])):
        if not alternative:
            return 'aaPublic'
        require(len(alternative) == 1, f'Unsupported combined authentication: {path}')
        name = next(iter(alternative))
        scheme = spec['components']['securitySchemes'].get(name, {})
        if scheme.get('type') == 'oauth2' or (
                scheme.get('type') == 'http' and scheme.get('scheme') == 'bearer'):
            roles.add('bearer')
        elif (scheme.get('type'), scheme.get('in'), scheme.get('name')) == (
                'apiKey', 'header', 'X-Api-Key'):
            roles.add('key')
        elif (scheme.get('type'), scheme.get('in'), scheme.get('name')) == (
                'apiKey', 'query', 'signer-access-code'):
            roles.add('signer')
        else:
            raise SystemExit(f'Unsupported authentication scheme: {name}')
    modes = {frozenset(): 'aaPublic', frozenset({'bearer'}): 'aaBearer',
             frozenset({'key', 'bearer'}): 'aaAPI',
             frozenset({'signer'}): 'aaSigner',
             frozenset({'key', 'bearer', 'signer'}): 'aaSignerOrAPI'}
    require(frozenset(roles) in modes, f'Unsupported authentication alternatives: {path}')
    return 'aaBearer' if path == '/v1/oauth/userinfo' else modes[frozenset(roles)]


spec = json.loads((ROOT / 'docs/openapi.json').read_text())
expected = {(verb.upper(), path) for path, item in spec['paths'].items()
            for verb in item if verb in {'get', 'post', 'put', 'patch', 'delete'}}
declarations = (ROOT / 'src/resources.inc').read_text()
actual = re.findall(r'// (GET|POST|PUT|PATCH|DELETE) (\S+);', declarations)
require(len(actual) == len(set(actual)), 'Duplicate API operation')
require(set(actual) == expected, 'Missing or extra API operations')
names = re.findall(r'function (\w+)\(', declarations) + re.findall(r'function (\w+):', declarations)
require(len(names) == len(actual) and len(names) == len(set(names)), 'Incorrect resource declarations')
implementation = (ROOT / 'src/methods.inc').read_text()
docs = (ROOT / 'docs/API.md').read_text()
for name in names:
    require(implementation.count('TAssinafyClient.' + name + '(') + implementation.count('TAssinafyClient.' + name + ':') == 1, name)
    require('\n## ' + name + '\n' in docs, f'Missing documentation for {name}')
auth_modes = dict(re.findall(r'function TAssinafyClient\.(\w+)[\s\S]*?Result := Call\([^\n]*, (aa\w+),', implementation))
bindings = re.findall(r'// (GET|POST|PUT|PATCH|DELETE) (\S+);[^\n]*\n\s+function (\w+)', declarations)
require(len(bindings) == len(actual) and set(auth_modes) == set(names), 'Incomplete authentication checks')
for verb, path, name in bindings:
    require(auth_modes.get(name) == expected_auth(spec['paths'][path][verb.lower()], path),
            f'Incorrect authentication for {name}')
require((ROOT / 'VERSION').read_text().strip() in (ROOT / 'src/assinafy.pas').read_text(), 'Version mismatch')
for filename in ['AGENTS.md', 'CLAUDE.md']:
    require('/' + filename in (ROOT / '.gitignore').read_text(), f'{filename} must be ignored')
for path in ROOT.rglob('*'):
    if not path.is_file() or any(part in {'.git', 'build', '__pycache__', '.ruff_cache'} for part in path.parts) or path.name in {'AGENTS.md', 'CLAUDE.md'}:
        continue
    if path.suffix not in {'.md', '.json', '.pas', '.inc', '.py', '.yml', '.yaml', '.sh'} and path.name not in {'Makefile', 'VERSION', 'LICENSE', '.gitignore', '.env.example'}:
        continue
    text = path.read_text()
    require(all(line.rstrip() == line for line in text.splitlines()), f'Trailing whitespace: {path}')
    if path.suffix in {'.md', '.json', '.pas', '.inc'}:
        for address in re.findall(r'[\w.+-]+@(?:[\w-]+\.)+[A-Za-z]{2,}', text):
            domain = address.rsplit('@', 1)[1]
            require(domain in {'example.com', 'example.net', 'example.org'} or domain.endswith(('.example.com', '.example.net', '.example.org', '.example')), f'Use reserved email domain in {path}')
    if path.suffix == '.md':
        require(not re.search(r'\b(?:audit|comparison|comparision)\b', text, re.IGNORECASE), f'Unwanted commentary in {path}')
        for target in re.findall(r'\]\(([^)]+)\)', text):
            if target.startswith(('https://', 'http://', '#', 'mailto:')):
                continue
            require((path.parent / target.split('#', 1)[0]).exists(), f'Broken local link in {path}: {target}')
print(f'PASS: {len(expected)} published operations, payload documentation, versions and source hygiene')
