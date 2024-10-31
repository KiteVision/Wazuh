Les fichiers de regles ci-dessus sont a placer dans le repertoire /var/ossec/etc/rules

Pour leur prise en compte, redemarrer le service wazuh-manager, apres avoir mis a jour les decodeurs :
systemctl restart wazuh-manager
