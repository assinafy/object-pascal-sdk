"""Check contract failures independently of generated operation expectations."""

import contextlib
import copy
import importlib.util
import io
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
module_spec = importlib.util.spec_from_file_location('generate', ROOT / 'scripts/generate.py')
generate = importlib.util.module_from_spec(module_spec)
module_spec.loader.exec_module(generate)


class GeneratorTests(unittest.TestCase):
    def test_reference_preserves_sibling_description(self):
        value = generate.resolve({'$ref': '#/components/responses/ValidationError',
                                  'description': '`url` is missing.'})
        self.assertEqual(value['description'], '`url` is missing.')
        self.assertIn('content', value)

    def test_webhook_payloads_are_documented(self):
        docs = generate.generate_docs(list(generate.operations()))['docs/API.md']
        for name, item in generate.SPEC['webhooks'].items():
            with self.subTest(event=name):
                self.assertIn('\n### ' + name + '\n', docs)
                content = item['post']['requestBody']['content']['application/json']
                self.assertIn(generate.code(content['example']), docs)

    def operation(self, security, **changes):
        spec = copy.deepcopy(generate.SPEC)
        operation = {'summary': 'Test operation', 'security': security, **changes}
        spec['paths'] = {'/v1/accounts/{accountId}': {
            'parameters': [{'name': 'accountId', 'in': 'path', 'required': True}],
            'get': operation,
        }}
        with patch.object(generate, 'SPEC', spec):
            return next(iter(generate.operations()))

    def test_authentication_modes(self):
        cases = [([], 'aaPublic'), ([{}], 'aaPublic'),
                 ([{'signerAccessCode': []}], 'aaSigner'),
                 ([{'bearerAuth': []}], 'aaBearer'),
                 ([{'oauth2': ['documents:read']}], 'aaBearer'),
                 ([{'bearerAuth': []}, {'apiKeyAuth': []}], 'aaAPI'),
                 ([{'signerAccessCode': []}, {'bearerAuth': []}, {'apiKeyAuth': []}],
                  'aaSignerOrAPI')]
        for security, expected in cases:
            with self.subTest(security=security):
                self.assertEqual(self.operation(security)['auth'], expected)

    def test_signer_or_workspace_routes_get_separate_workspace_method(self):
        spec = copy.deepcopy(generate.SPEC)
        spec['paths'] = {'/v1/signers/{signerId}/documents': {
            'parameters': [{'name': 'signerId', 'in': 'path', 'required': True}],
            'get': {'summary': 'Test operation', 'security': [
                {'signerAccessCode': []}, {'bearerAuth': []}, {'apiKeyAuth': []}]},
        }}
        with patch.object(generate, 'SPEC', spec):
            signer, workspace = generate.operations()
        self.assertEqual((signer['auth'], workspace['auth']), ('aaSignerOrAPI', 'aaAPI'))
        self.assertEqual(workspace['name'], 'TestOperationAsWorkspace')
        self.assertIn('SignerAccessCode', [x[0] for x in signer['args']])
        self.assertNotIn('SignerAccessCode', [x[0] for x in workspace['args']])

    def test_unknown_or_combined_security_is_rejected(self):
        for security in [[{'signer_access_code': []}],
                         [{'apiKeyAuth': [], 'signerAccessCode': []}]]:
            with self.subTest(security=security), self.assertRaises(ValueError):
                self.operation(security)

    def test_path_parameter_must_exist_in_uri(self):
        with self.assertRaises(ValueError):
            self.operation([], parameters=[{'name': 'unexpected', 'in': 'path'}])

    def test_multipart_field_and_encoding_follow_contract(self):
        operation = self.operation([], requestBody={'required': True, 'content': {
            'multipart/form-data': {
                'schema': {'type': 'object', 'required': ['attachment'], 'properties': {
                    'attachment': {'type': 'string', 'format': 'binary'}}},
                'encoding': {'attachment': {'contentType': 'image/png'}},
            }}})
        code = generate.generate_methods([operation])['src/methods.inc']
        self.assertIn("FileName, 'attachment', 'image/png'", code)
        self.assertIn("RequireValue(FileName, 'File name')", code)
        self.assertFalse(operation['custom_media'])

    def test_logo_allows_explicit_part_media_type(self):
        operation = next(op for op in generate.operations() if op['name'] == 'UploadAccountLogo')
        code = generate.generate_methods([operation])
        self.assertIn("ContentType: string = 'application/octet-stream'", code['src/resources.inc'])
        self.assertIn("FileName, 'file', ContentType", code['src/methods.inc'])
        self.assertIn("RequireValue(ContentType, 'File content type')", code['src/methods.inc'])

    def test_request_media_alternatives_are_rejected(self):
        with self.assertRaises(ValueError):
            self.operation([], requestBody={'content': {
                'application/json': {'schema': {'type': 'object'}},
                'image/png': {'schema': {'type': 'string', 'format': 'binary'}},
            }})
        operation = self.operation([], requestBody={'content': {
            'application/json': {'schema': {'type': 'object'}},
            'application/x-www-form-urlencoded': {'schema': {'type': 'object'}},
        }})
        self.assertTrue(operation['body'])
        self.assertEqual(operation['media_type'], 'application/json')

    def test_referenced_required_body_is_checked(self):
        spec = copy.deepcopy(generate.SPEC)
        spec['components']['requestBodies'] = {'TestBody': {
            'required': True, 'content': {'application/json': {'schema': {'type': 'object'}}},
        }}
        with patch.object(generate, 'SPEC', spec):
            operation = self.operation([], requestBody={'$ref': '#/components/requestBodies/TestBody'})
        code = generate.generate_methods([operation])['src/methods.inc']
        self.assertIn("if Body = nil then raise EAssinafyInputError", code)


class GateTests(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory(prefix='assinafy-tools-')
        self.addCleanup(self.folder.cleanup)
        self.root = Path(self.folder.name)
        for name in ['src', 'docs', 'scripts', 'examples', 'delphi']:
            shutil.copytree(ROOT / name, self.root / name,
                            ignore=shutil.ignore_patterns('__pycache__'))
        for name in ['README.md', '.gitignore', '.env.example', 'VERSION', 'LICENSE']:
            shutil.copyfile(ROOT / name, self.root / name)

    def run_gate(self, script='check_contract.py'):
        return subprocess.run([sys.executable, '-O', str(self.root / 'scripts' / script)],
                              capture_output=True, text=True, check=False)

    def test_missing_operation_fails_with_optimization(self):
        path = self.root / 'src/resources.inc'
        path.write_text('\n'.join(path.read_text(encoding='utf-8').splitlines()[2:]) + '\n', encoding='utf-8')
        result = self.run_gate()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Missing or extra API operations', result.stderr)

    def test_authentication_is_checked_independently(self):
        path = self.root / 'src/methods.inc'
        path.write_text(path.read_text(encoding='utf-8').replace("'/users/self', aaAPI", "'/users/self', aaPublic"), encoding='utf-8')
        result = self.run_gate()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('authentication', result.stderr)

    def test_ignored_binary_files_do_not_break_gate(self):
        (self.root / '.DS_Store').write_bytes(b'\xff\x00')
        (self.root / '.env').write_bytes(b'\xff\x00')
        result = self.run_gate()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_readme_examples_fail_with_optimization(self):
        (self.root / 'README.md').write_text('No snippets.\n', encoding='utf-8')
        result = self.run_gate('check_examples.py')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('README must include usage examples', result.stderr)


class ReadmeCompilerTests(unittest.TestCase):
    def test_delphi_uses_utf8_dpr_sources_and_preserves_compiler_arguments(self):
        loader = importlib.util.spec_from_file_location('check_examples', ROOT / 'scripts/check_examples.py')
        examples = importlib.util.module_from_spec(loader)
        loader.loader.exec_module(examples)
        with tempfile.TemporaryDirectory(prefix='assinafy-readme-') as folder:
            root = Path(folder)
            (root / 'README.md').write_text(
                "```pascal\nWriteLn('João 😀');\n```\n```sh\ntrue\n```\n", encoding='utf-8')
            calls = []

            def compiler(arguments, **kwargs):
                calls.append(arguments)
                self.assertEqual(arguments[:2], ['dcc32.exe', '-Udirectory with spaces'])
                source = Path(arguments[-1])
                self.assertEqual(source.suffix, '.dpr')
                self.assertTrue(source.read_bytes().startswith(b'\xef\xbb\xbf'))
                self.assertIn("WriteLn('João 😀')", source.read_text(encoding='utf-8-sig'))
                return SimpleNamespace(returncode=0, stdout='')

            with patch.object(examples, 'ROOT', root), patch.object(examples.subprocess, 'run', compiler), \
                    patch.object(sys, 'argv', ['check_examples.py', '--delphi', 'dcc32.exe', '-Udirectory with spaces']), \
                    contextlib.redirect_stdout(io.StringIO()):
                examples.main()
            self.assertEqual(len(calls), 1)


if __name__ == '__main__':
    unittest.main()
