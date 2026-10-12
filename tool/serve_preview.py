"""Serve the local build without keeping stale application files in browsers."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit
import re

class PreviewHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        path = urlsplit(self.path).path
        version_file = Path(self.directory) / 'build-version.txt'
        if re.fullmatch(r'/app-[a-f0-9]+\.html', path) and version_file.exists():
            current = version_file.read_text().strip()
            latest = f'/app-{current}.html'
            if path != latest:
                self.send_response(302)
                self.send_header('Location', latest)
                self.end_headers()
                return
        super().do_GET()

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, max-age=0')
        super().end_headers()

if __name__ == '__main__':
    root = Path(__file__).resolve().parent.parent / 'build' / 'web'
    ThreadingHTTPServer(('127.0.0.1', 8765), partial(PreviewHandler, directory=str(root))).serve_forever()
