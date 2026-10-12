"""Exercise the native SDK against local HTTP and certificate-verifying HTTPS."""

import base64
import gzip
import hashlib
import json
import os
import re
import ssl
import subprocess
import sys
import tempfile
import threading
import time
from email import policy
from email.parser import BytesParser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

FILE_BYTES = b'%PDF-\x00\xfffixture!'
ENCODED_BYTES = base64.b64decode('H4sIAAAAAAAC/1MNcHHTZfiflllRUlqUqggAXGVJUQ8AAAA=')


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
        if path.endswith(('/complete-chunked', '/complete-close', '/complete-encoded',
                          '/slow-chunked', '/slow-close', '/slow-encoded')):
            self.close_connection = True
            chunked = path.endswith(('complete-chunked', 'slow-chunked'))
            encoded = path.endswith(('complete-encoded', 'slow-encoded'))
            slow = '/slow-' in path
            if slow:
                self.server.slow_requests += 1
            body = ENCODED_BYTES if encoded else FILE_BYTES
            self.send_response(200)
            self.send_header('Content-Type', 'application/octet-stream')
            if chunked:
                self.send_header('Transfer-Encoding', 'chunked')
            elif encoded:
                self.send_header('Content-Encoding', 'gzip')
                self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            try:
                for offset in range(0, len(body), 1 if slow else len(body)):
                    part = body[offset:offset + (1 if slow else len(body))]
                    if chunked:
                        self.wfile.write(f'{len(part):X}\r\n'.encode() + part + b'\r\n')
                    else:
                        self.wfile.write(part)
                    self.wfile.flush()
                    if slow:
                        time.sleep(0.06)
                if chunked:
                    self.wfile.write(b'0\r\n\r\n')
            except (BrokenPipeError, ConnectionResetError):
                pass
            return
        if path.endswith('/no-timeout'):
            time.sleep(0.3)
        if path.endswith('/truncated-transfer'):
            self.close_connection = True
            self.send_response(200)
            self.send_header('Content-Type', 'application/octet-stream')
            self.send_header('Content-Length', '20')
            self.end_headers()
            self.wfile.write(b'short')
            return
        if path.endswith('/slow-transfer'):
            self.close_connection = True
            self.server.slow_requests += 1
            self.send_response(200)
            self.send_header('Content-Type', 'application/octet-stream')
            self.send_header('Content-Length', '20')
            self.end_headers()
            try:
                for _ in range(20):
                    self.wfile.write(b'x')
                    self.wfile.flush()
                    time.sleep(0.06)
            except (BrokenPipeError, ConnectionResetError):
                pass
            return
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
            extra.update({'Retry-After': '3', 'X-Rate-Limit-Limit': '60',
                          'X-Rate-Limit-Remaining': '0', 'X-Rate-Limit-Reset': '3'})
        elif path == '/v1/documents/html-error':
            status = 503
            content_type = 'text/html'
        elif self.command == 'POST' and (path.endswith(('/documents', '/logo')) or path == '/v1/snapshot'):
            media = self.headers['Content-Type']
            check(isinstance(media, str) and media.startswith('multipart/form-data; boundary='), 'Expected multipart body')
            message = BytesParser(policy=policy.default).parsebytes(
                ('Content-Type: ' + media + '\r\n\r\n').encode() + raw)
            boundary = message.get_boundary()
            check(isinstance(boundary, str) and
                  re.fullmatch(r"[0-9A-Za-z'()+_,./:=? -]{1,70}", boundary) and
                  not boundary.endswith(" "), 'Invalid MIME boundary')
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
    check(gzip.decompress(ENCODED_BYTES) == FILE_BYTES, 'Encoded fixture must decompress to the binary fixture')
    windows_trust = '--windows-store-trust' in sys.argv[2:]
    if windows_trust and sys.platform != 'win32':
        raise SystemExit('Windows certificate-store mode requires Windows')
    with tempfile.TemporaryDirectory(prefix='assinafy-http-') as folder:
        folder = Path(folder)
        certificate, key = folder / 'cert.pem', folder / 'key.pem'
        untrusted, untrusted_key = folder / 'untrusted.pem', folder / 'untrusted-key.pem'
        for cert_path, key_path in [(certificate, key), (untrusted, untrusted_key)]:
            subprocess.run(['openssl', 'req', '-x509', '-newkey', 'rsa:2048', '-nodes',
                            '-keyout', str(key_path), '-out', str(cert_path), '-days', '1',
                            '-subj', '/CN=localhost', '-addext', 'subjectAltName=DNS:localhost'],
                           check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        fixture = folder / 'fixture.pdf'
        fixture.write_bytes(FILE_BYTES)
        servers = [ThreadingHTTPServer(('127.0.0.1', 0), Handler) for _ in range(3)]
        for server, cert_path, key_path in [(servers[1], certificate, key),
                                            (servers[2], untrusted, untrusted_key)]:
            context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
            context.minimum_version = ssl.TLSVersion.TLSv1_2
            context.load_cert_chain(cert_path, key_path)
            server.socket = context.wrap_socket(server.socket, server_side=True)
        for server in servers:
            server.redirect_followed = False
            server.slow_requests = 0
            server.fixture = fixture
            threading.Thread(target=server.serve_forever, daemon=True).start()
        thumbprint = hashlib.sha1(ssl.PEM_cert_to_DER_cert(certificate.read_text(encoding='utf-8'))).hexdigest()
        added = False
        try:
            if windows_trust:
                existing = subprocess.run(['certutil', '-user', '-store', 'Root', thumbprint],
                                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
                check(existing.returncode != 0, 'Fixture certificate already exists in the trust store')
                subprocess.run(['certutil', '-user', '-addstore', 'Root', str(certificate)],
                               check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                added = True
            port, tls_port, untrusted_port = (server.server_port for server in servers)
            environment = os.environ | {'NO_PROXY': 'localhost,127.0.0.1', 'no_proxy': 'localhost,127.0.0.1'}
            subprocess.run([sys.argv[1], f'http://127.0.0.1:{port}/v1', str(fixture),
                            f'https://localhost:{tls_port}/v1', str(certificate),
                            f'https://127.0.0.1:{tls_port}/v1', f'https://localhost:{untrusted_port}/v1'],
                           check=True, env=environment, timeout=60)
            check(not servers[0].redirect_followed, 'Credentials followed an HTTP redirect')
            check(servers[0].slow_requests == 4, 'Each slow framing request must run once without retry')
        finally:
            try:
                if added:
                    subprocess.run(['certutil', '-user', '-delstore', 'Root', thumbprint],
                                   check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            finally:
                for server in servers:
                    server.shutdown()
                    server.server_close()


if __name__ == '__main__':
    main()
