from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib import parse
import base64
import json
import shutil

class Server(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_OPTIONS(self):
        self.send_response(200, "ok")
        self.send_header('Access-Control-Allow-Credentials', 'true')
        self.send_header('Access-Control-Allow-Origin', 'http://192.168.0.89:5173')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header("Access-Control-Allow-Headers", "X-Requested-With, Content-type")

    def do_HEAD(self):
        self._set_headers()

    # GET sends back a Hello world message
    def do_GET(self):
        files = {
            "/": "msn-data.json",
            "/restore": "backup-msn-data.json",
        }

        if self.path == "/favicon.ico": # Ignore favicon requests
            return False
        elif self.path == "/restore": # Restore backup data
            print("Restoring data...")
            message = { "message" : "MSN Data Servers mission data restored"}

            shutil.copy(files['/restore'], files['/']) # Overwrite data with backup

            self._set_headers()
            self.wfile.write(json.dumps(message).encode('utf-8'))
        else:
            with open(files[self.path]) as file:
                data = {}
                shopData = json.load(file)

                # If not intel, strip msn meta data
                if SHOP == "intel":
                    data[SHOP] = shopData
                else:
                    data[SHOP] = {key:shopData[key] for key in shopData if key == 'status'}

                self._set_headers()
                self.wfile.write(json.dumps(data).encode('utf-8'))

                file.close()

    def do_POST(self):
        if self.path == "/":
            with open("log", "a") as log:
                content = self.rfile.read(int(self.headers.get("Content-Length")))
                log.write(f'{content.decode()}\n')

                self._set_headers()
                self.wfile.write(content)

                log.close()
        elif self.path == "/updateMsn":
            base64_content = parse.unquote_plus(self.rfile.read(int(self.headers.get("Content-Length"))).decode("utf-8").split("data=")[1])
            new_content = json.loads(base64.b64decode(base64_content))
            content = {}

            # Read file
            with open("msn-data.json", "r") as msnfile:
                content = json.load(msnfile)
                msnfile.close()

            # Update content
            for key in new_content:
                content[key] = new_content[key]

            # Write file
            with open("msn-data.json", "w") as msnfile:
                json.dump(content, msnfile)
                msnfile.close()

            message = { "message" : "Intel mission data updated"}

            self._set_headers()
            self.wfile.write(json.dumps(message).encode('utf-8'))

def run(server_class=HTTPServer, handler_class=Server, port='8008', shop='unk'):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)

    print('Starting %s Data Server on port %d...' % (shop.upper(), port))
    httpd.serve_forever()

if __name__ == '__main__':
    from sys import argv

    try:
        PORT = int(argv[1])
        SHOP = str(argv[2])
        run(port=PORT, shop=SHOP)

    except:
        print('Missing args:')
        print('> python3 data-server.py [PORT] [SHOP]')
