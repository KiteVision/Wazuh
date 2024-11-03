
# Server Flask ouvert par defaut sur le port 5000
# Permet de creer un webhook local ecrivant l'alerte transmise dans le fichier active-responses.log
# TDWH 2023

from flask import Flask, request, jsonify
import json

app = Flask(__name__)

@app.route('/opensearch-alerts', methods=['POST'])
def handle_opensearch_request():
 if request.headers.get('Content-Type') == 'text/html':
    text = request.data.decode('utf-8')
    with open('/var/ossec/logs/active-responses.log', 'a') as file:
        file.write('ossec: output: OpenSearchMonitor: ' + text + '\n')
    return 'OK'

if __name__ == '__main__':
    app.run(host='0.0.0.0')
