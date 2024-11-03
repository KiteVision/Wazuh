Ce monitor (a telecharger dans un fichier monitor.json) peut etre ajoute a un cluster opensearch via son api locale :
      curl -k -u admin:P*ssw0rd -X PUT "https://localhost:9200/_plugins/_alerting/monitors" \
      -H "Content-Type: application/json" \
      -d @monitor.json
