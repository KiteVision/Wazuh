Ce monitor (a copier en "raw" dans un fichier monitor.json) peut etre ajoute a un cluster opensearch via son api locale, <br> avec admin:P*ssw0rd valides : <br>

      curl -k -u admin:P*ssw0rd -X POST "https://localhost:9200/_plugins/_alerting/monitors" \
      -H "Content-Type: application/json" -d @monitor.json

