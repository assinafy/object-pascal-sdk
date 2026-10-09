"""Check API operation coverage, documentation links and source hygiene."""

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = json.loads((ROOT / 'docs/openapi.json').read_text())
expected = {(verb.upper(), path) for path, item in spec['paths'].items()
            for verb in item if verb in {'get', 'post', 'put', 'patch', 'delete'}}
declarations = (ROOT / 'src/resources.inc').read_text()
actual = re.findall(r'// (GET|POST|PUT|PATCH|DELETE) (\S+);', declarations)
assert len(actual) == len(set(actual)), 'Duplicate API operation'
assert set(actual) == expected, 'Missing or extra API operations'
names = re.findall(r'function (\w+)\(', declarations) + re.findall(r'function (\w+):', declarations)
implementation = (ROOT / 'src/methods.inc').read_text()
docs = (ROOT / 'docs/API.md').read_text()
for name in names:
    assert implementation.count('TAssinafyClient.' + name + '(') + implementation.count('TAssinafyClient.' + name + ':') == 1, name
    assert '\n## ' + name + '\n' in docs, f'Missing documentation for {name}'
assert (ROOT / 'VERSION').read_text().strip() in (ROOT / 'src/assinafy.pas').read_text(), 'Version mismatch'
for filename in ['AGENTS.md', 'CLAUDE.md']:
    assert '/' + filename in (ROOT / '.gitignore').read_text(), f'{filename} must be ignored'
for path in ROOT.rglob('*'):
    if not path.is_file() or any(part in {'.git', 'build', '__pycache__', '.ruff_cache'} for part in path.parts):
        continue
    text = path.read_text()
    assert all(line.rstrip() == line for line in text.splitlines()), f'Trailing whitespace: {path}'
    if path.suffix in {'.md', '.json', '.pas', '.inc'}:
        for address in re.findall(r'[\w.+-]+@(?:[\w-]+\.)+[A-Za-z]{2,}', text):
            domain = address.rsplit('@', 1)[1]
            assert domain in {'example.com', 'example.net', 'example.org'} or domain.endswith(('.example.com', '.example.net', '.example.org', '.example')), f'Use reserved email domain in {path}'
    if path.suffix == '.md':
        assert not re.search(r'\b(?:audit|comparison|comparision)\b', text, re.IGNORECASE), f'Unwanted commentary in {path}'
        for target in re.findall(r'\]\(([^)]+)\)', text):
            if target.startswith(('https://', 'http://', '#', 'mailto:')):
                continue
            assert (path.parent / target.split('#', 1)[0]).exists(), f'Broken local link in {path}: {target}'
print(f'PASS: {len(expected)} published operations, payload documentation, versions and source hygiene')
