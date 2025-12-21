import os
from http.server import HTTPServer, BaseHTTPRequestHandler

VERSION = os.environ.get('VERSION', '1.0.0')
BG_COLOR = os.environ.get('BG_COLOR', '#3498db')
STATUS = os.environ.get('STATUS', 'STABLE')

def load_template():
    with open('templates/index.html', 'r') as f:
        template = f.read()
    return template.format(
        version=VERSION,
        bg_color=BG_COLOR,
        status=STATUS
    )

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        html = load_template()
        self.wfile.write(html.encode())

    def log_message(self, format, *args):
        print(f"[{STATUS}] {args[0]}")

if __name__ == '__main__':
    print(f"Starting server: {STATUS} v{VERSION}")
    HTTPServer(('0.0.0.0', 8080), Handler).serve_forever()
