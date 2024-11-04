# Ce fichier peut etre rendu executable avec pyinstaller si le serveur ne dispose pas d'interpreteur Python3 :
# pyinstaller --onefile --add-binary "/usr/lib/x86_64-linux-gnu/libpython3.10.so:." Active-Response-Log.py
# Server Flask ouvert par defaut sur le port 5000
# Permet de creer un webhook local renseignant l'alerte transmise dans le fichier active-responses.log
# Avec 2 routes : /opensearch-alerts et /graylog-alerts
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

@app.route('/graylog-alerts', methods=['POST'])
def handle_graylog_request():
 if request.headers.get('Content-Type') == 'application/json':
  data = request.get_json()
  type = data.get('event_definition_type')
  id   =    data['event']['id']
  time =    data['event']['timestamp']
  message = data['event']['message']
  text = str(type) + ' ' + str(id) + ' ' + str(message) + ' ' + str(time)
  with open('/var/ossec/logs/active-responses.log', 'a') as file:
      file.write('ossec: output: GraylogMonitor: ' + text + '\n')
  return 'OK'


if __name__ == '__main__':
    app.run(host='0.0.0.0')
