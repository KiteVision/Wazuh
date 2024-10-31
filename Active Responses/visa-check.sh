#!/bin/bash
#
# Pour tester si des numeros au format VISA sont valides selon l'algorithme de Luhn
#
##################### Sources Incluses #####################
#
# From https://ethertubes.com/bash-luhn/
# Returns Luhn checksum for supplied sequence
#
############################################################
luhn_checksum() {
        sequence="$1"
        sequence="${sequence//[^0-9]}" # numbers only plz
        checksum=0
        table=(0 2 4 6 8 1 3 5 7 9)

        # Quicker to work with even number of digits
        # prepend a "0" to sequence if uneven
        i=${#sequence}
        if [ $(($i % 2)) -ne 0 ]; then
                sequence="0$sequence"
                ((++i))
        fi

        while [ $i -ne 0 ];
        do
                # sum up the individual digits, do extra stuff w/every other digit
                checksum="$(($checksum + ${sequence:$((i - 1)):1}))" # Last digit
                # for every other digit, double the value before adding the digit
                 # if the doubled value is over 9, subtract 9
                checksum="$(($checksum + ${table[${sequence:$((i - 2)):1}]}))" # Second to last digit
                i=$((i - 2))

        done
        checksum="$(($checksum % 10))" # mod 10 the sum to get single digit checksum
        echo "$checksum"
}

# Returns Luhn check digit for supplied sequence
luhn_checkdigit() {
        check_digit=$(luhn_checksum "${1}0")
        if [ $check_digit -ne 0 ]; then
                check_digit=$((10 - $check_digit))
        fi
        echo "$check_digit"
}

# Tests if last digit is the correct Luhn check digit for the sequence
# Returns true if valid, false if not
luhn_test() {
        if [ "$(luhn_checksum $1)" == "0" ]; then
                return 0
        else
                return 1
        fi
}
#
############################################
#
# Traitement de l'alerte Wazuh
# TDWH Juillet 2023
#
############################################
# Donnees de sorties vers le fichier active-responses.log
TMP_FILE="/tmp/alert.txt"
LOG_FILE="logs/active-responses.log"
#
# Lecture des donnees presentes dans le JSON de l'alerte (et ecriture dans fichier temporaire)
read -r INPUT_JSON
FULL_LOG=$(echo $INPUT_JSON | jq -r .parameters.alert.full_log)
echo "$FULL_LOG" > ${TMP_FILE}
#
# Tableau pour stocker les lignes, reprises du fichier temporaire
lines=()
Nb_lines=0
while IFS= read -r line; do
    # Ajouter la ligne au tableau
    lines+=("$line")
    ((Nb_lines++))
done < "$TMP_FILE"

# Recherche du numero de visa dans chaque ligne
Nb_numcbs=$((Nb_lines-1))
numcbs=()
i=1
while [ $i -le $((Nb_numcbs+1)) ]; do
    numcbs+=("$(echo "${lines[${i}]}" | cut -d':' -f4)")
    ((i++))
done

# Test Luhn et Ecriture dans fichier temporaire des numeros pour test
echo -n "$Nb_numcbs numeros de VISA detectés dont ceux-ci invalides  " > /tmp/junk.txt
Reponse="ossec: output: 'Valid Visa Number' Dude "
i=0
val=0
while [ $i -lt $Nb_numcbs ]; do
    numcb=("$(echo ${numcbs[${i}]} | xargs)")
     if luhn_test "$numcb" ; then
            # Numero de carte VISA Valide
            Reponse+="-$numcb"
            val=1
        else
            # pour debug :
            # Numero de carte VISA Invalide
            echo -n "-$numcb" >> /tmp/junk.txt
        fi
    ((i++))
done
# pour debug :
echo "$Reponse" > /tmp/cbs.txt
#Ecriture dans fichier active-responses.log
if val==1 ; then
    echo "$Reponse" >> ${LOG_FILE}
fi
