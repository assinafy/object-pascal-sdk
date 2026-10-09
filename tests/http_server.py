"""Exercise the native SDK against local HTTP and certificate-verifying HTTPS."""

import json
import os
import ssl
import subprocess
import sys
import tempfile
import threading
from email import policy
from email.parser import BytesParser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

FILE_BYTES = b'%PDF-\x00\xfffixture!'


def check(condition, message):
    if not condition:
        raise ValueError(message)


class Handler(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.1'

    def log_message(self, *args):
        pass

    def dispatch(self):
        try:
            self.handle_request()
        except (ValueError, KeyError, TypeError, OSError) as error:
            self.respond(500, json.dumps({'message': str(error)}).encode())

    def handle_expect_100(self):
        if urlsplit(self.path).path == '/v1/snapshot':
            fixture = self.server.fixture
            replacement = fixture.with_suffix('.replacement')
            replacement.write_bytes(b'X' * len(FILE_BYTES))
            replacement.replace(fixture)
        return super().handle_expect_100()

    def respond(self, status, body, content_type='application/json', extra=None):
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('X-Pagination-Current-Page', '1')
        for name, value in (extra or {}).items():
            self.send_header(name, value)
        self.end_headers()
        self.wfile.write(body)

    def handle_request(self):
        path = urlsplit(self.path).path
        check(not self.headers.get('Transfer-Encoding'), 'Fixture requires Content-Length; chunked requests are unsupported')
        raw = self.rfile.read(int(self.headers.get('Content-Length', 0)))
        status = 200
        content_type = 'application/json'
        extra = {}
        data = {
            'method': self.command, 'path': self.path,
            'key': self.headers.get('X-Api-Key', ''),
            'authorization': self.headers.get('Authorization', ''),
        }
        if path == '/v1/documents/redirect':
            status = 302
            extra['Location'] = f'http://127.0.0.1:{self.server.server_port}/trap'
        elif path == '/trap':
            self.server.redirect_followed = True
        elif path == '/v1/documents/rate-limit':
            status = 429
            extra['Retry-After'] = '3'
        elif path == '/v1/documents/html-error':
            status = 503
            content_type = 'text/html'
        elif self.command == 'POST' and (path.endswith(('/documents', '/logo')) or path == '/v1/snapshot'):
            media = self.headers['Content-Type']
            check(isinstance(media, str) and media.startswith('multipart/form-data; boundary='), 'Expected multipart body')
            message = BytesParser(policy=policy.default).parsebytes(
                ('Content-Type: ' + media + '\r\n\r\n').encode() + raw)
            parts = list(message.iter_parts())
            check(len(parts) == 1, 'Expected one file part')
            part = parts[0]
            value = part.get_payload(decode=True)
            data.update(file_field=part.get_param('name', header='content-disposition'),
                        file_size=len(value), valid_file=value == FILE_BYTES,
                        file_name=part.get_filename(), file_media=part.get_content_type())
            if path == '/v1/snapshot':
                self.server.fixture.write_bytes(FILE_BYTES)
        elif path == '/v1/signature':
            check(self.headers['Content-Type'] == 'image/png', 'Expected raw PNG content type')
            check('signer-access-code=signer-code' in self.path, 'Expected signer code')
            data['raw_file_valid'] = raw == FILE_BYTES
        elif self.command == 'PATCH':
            check(self.headers['Content-Type'] == 'application/json', 'Expected JSON content type')
            data['body'] = json.loads(raw)
        if path == '/v1/documents/binary/download/original':
            content_type = 'application/pdf'
            body = FILE_BYTES
        elif path == '/v1/oauth/token':
            check(not data['key'] and not data['authorization'], 'Token exchange must omit workspace credentials')
            check(json.loads(raw), 'Token request must contain a JSON body')
            body = json.dumps({'access_token': 'test-access', 'token_type': 'Bearer'}).encode()
        elif path == '/v1/documents/protocol-error/assignments':
            status = 201
            body = b'{"data":{"id":"created-id","name":"\\u0000"}}'
        elif path == '/.well-known/oauth-protected-resource':
            check(not data['key'] and not data['authorization'], 'Metadata must omit workspace credentials')
            body = json.dumps({'resource': 'mock-resource'}).encode()
        elif content_type == 'text/html':
            body = b'<html>unavailable</html>'
        else:
            body = json.dumps({'status': status, 'message': 'ok', 'data': data}).encode()
        self.respond(status, body, content_type, extra)

    do_GET = dispatch
    do_POST = dispatch
    do_PUT = dispatch
    do_PATCH = dispatch
    do_DELETE = dispatch


def main():
    with tempfile.TemporaryDirectory(prefix='assinafy-http-') as folder:
        folder = Path(folder)
        certificate, key = folder / 'cert.pem', folder / 'key.pem'
        subprocess.run(['openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-nodes',
                        '-keyout', str(key), '-out', str(certificate), '-days', '1',
                        '-subj', '/CN=localhost', '-addext', 'subjectAltName=DNS:localhost'],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        fixture = folder / 'fixture.pdf'
        fixture.write_bytes(FILE_BYTES)
        servers = [ThreadingHTTPServer(('127.0.0.1', 0), Handler) for _ in range(2)]
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.minimum_version = ssl.TLSVersion.TLSv1_2
        context.load_cert_chain(certificate, key)
        servers[1].socket = context.wrap_socket(servers[1].socket, server_side=True)
        for server in servers:
            server.redirect_followed = False
            server.fixture = fixture
            threading.Thread(target=server.serve_forever, daemon=True).start()
        try:
            port, tls_port = (server.server_port for server in servers)
            environment = os.environ | {'NO_PROXY': 'localhost,127.0.0.1', 'no_proxy': 'localhost,127.0.0.1'}
            subprocess.run([sys.argv[1], f'http://127.0.0.1:{port}/v1', str(fixture),
                            f'https://localhost:{tls_port}/v1', str(certificate),
                            f'https://127.0.0.1:{tls_port}/v1'], check=True, env=environment, timeout=60)
            check(not servers[0].redirect_followed, 'Credentials followed an HTTP redirect')
        finally:
            for server in servers:
                server.shutdown()
                server.server_close()


if __name__ == '__main__':
    main()
