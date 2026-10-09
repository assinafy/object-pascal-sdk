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


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def dispatch(self):
        path = urlsplit(self.path).path
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
        elif path.endswith('/documents') and self.command == 'POST':
            media = self.headers['Content-Type']
            assert media.startswith('multipart/form-data; boundary=')
            message = BytesParser(policy=policy.default).parsebytes(
                ('Content-Type: ' + media + '\r\n\r\n').encode() + raw)
            parts = list(message.iter_parts())
            assert len(parts) == 1
            part = parts[0]
            value = part.get_payload(decode=True)
            data.update(file_field=part.get_param('name', header='content-disposition'),
                        file_size=len(value), valid_file=value == FILE_BYTES)
        elif path == '/v1/signature':
            assert self.headers['Content-Type'] == 'image/png'
            assert 'signer-access-code=signer-code' in self.path
            data['raw_file_valid'] = raw == FILE_BYTES
        elif self.command == 'PATCH':
            assert self.headers['Content-Type'] == 'application/json'
            data['body'] = json.loads(raw)
        if path == '/v1/documents/binary/download/original':
            content_type = 'application/pdf'
            body = FILE_BYTES
        elif path == '/v1/oauth/token':
            assert not data['key'] and not data['authorization']
            assert json.loads(raw)
            body = json.dumps({'access_token': 'test-access', 'token_type': 'Bearer'}).encode()
        elif path == '/.well-known/oauth-protected-resource':
            assert not data['key'] and not data['authorization']
            body = json.dumps({'resource': 'mock-resource'}).encode()
        elif content_type == 'text/html':
            body = b'<html>unavailable</html>'
        else:
            body = json.dumps({'status': status, 'message': 'ok', 'data': data}).encode()
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('X-Pagination-Current-Page', '1')
        for name, value in extra.items():
            self.send_header(name, value)
        self.end_headers()
        self.wfile.write(body)

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
            threading.Thread(target=server.serve_forever, daemon=True).start()
        try:
            port, tls_port = (server.server_port for server in servers)
            environment = os.environ | {'NO_PROXY': 'localhost,127.0.0.1', 'no_proxy': 'localhost,127.0.0.1'}
            subprocess.run([sys.argv[1], f'http://127.0.0.1:{port}/v1', str(fixture),
                            f'https://localhost:{tls_port}/v1', str(certificate),
                            f'https://127.0.0.1:{tls_port}/v1'], check=True, env=environment, timeout=60)
            assert not servers[0].redirect_followed, 'Credentials followed an HTTP redirect'
        finally:
            for server in servers:
                server.shutdown()
                server.server_close()


if __name__ == '__main__':
    main()
