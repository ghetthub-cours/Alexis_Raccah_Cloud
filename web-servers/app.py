# Simple Flask application to simulate web server
from flask import Flask
import socket
import os

app = Flask(__name__)

# Get container hostname for identification
hostname = socket.gethostname()
server_id = os.environ.get('SERVER_ID', 'unknown')

@app.route('/')
def home():
    return f"<h1>Hello from Web Server {server_id}</h1><p>Container: {hostname}</p>"

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
