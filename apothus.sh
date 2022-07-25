#!/bin/bash

root() {
    if [[ $EUID -ne 0 ]]; then
    echo "Bu scripti calistirabilmek icin root kullanicisi olmalisin! [-]" 
    exit 1
    else
        echo "Root kullanicisin. [+]"
    fi
}

main(){
    checkdata
    namecard=$(airmon-ng| grep -n "phy"| cut -c25-66)
    echo "$wlan | $namecard |"
    xterm -hold -title "SCANNER" -geometry 110x50 -sb -sl 1000 -e "sudo airodump-ng -w data --output-format "csv" $wlan"
    counter=1


    while IFS=, read -r line
	do

        ESSID=""
        BSSID=""

        if [[  $line =~ " " ]]; then
            bssid=$(echo $line|cut -d "," -f1|sed -e "s| |-|g")
            essid=$(echo $line|cut -d "," -f14)
           for x in $essid; do
                if [ "$x" == "ESSID" ] || [  $x == null  ]; then
                    echo ""
                else
                   ESSID[$counter]=$x
               fi
            done
            for x in $bssid; do
                if [ "$x" == "BSSID" ] || [ $x == null ]; then
                    echo ""
                elif [[ ${line:0:7} == "Station" ]]; then
                    break
              else
                   BSSID[$counter]=$x
               fi
           done
           ((counter++))
        fi
    done < data-01.csv
    echo "geldi"

    for ((i=0;i<${#CH[@]};i++)); do
        echo -e "${BSSID[$i]} = ${MAC[$i]}"
    done
}


monitoron() {
        echo "Monitor moda geciliyor..."
        iwconfig $1 > /dev/null 2>&1
        if [ "$?" = 237 ]; then
            echo "Boyle bir cihaz yok!"
            exit
        fi
        ifconfig "$wlan" down
        iwconfig "$wlan" mode monitor > /dev/null 2>&1
        ifconfig "$wlan" up
        if [[ ! $(iwconfig "$wlan"|grep -o "Mode:[A-Za-z]*"|cut -d ":" -f2) == "Monitor" ]]; then
            echo "Lütfen $wlan adlı arayüzün sürücülerinin tam veya güncel olduğundan emin olun bundan eminseniz ve hala hata alıyorsanız ya sürücülerinizde ya da $1 adlı arayüzünüz monitor modu desteklemiyor olabilir"
            sleep 2&
            wait
            exit
        else
            clear
            echo "$wlan.......................MONİTOR"
            main
        fi

}

monitorcheck() {
        if [[ $(iwconfig "$wlan"|grep -o "Mode:[A-Za-z]*"|cut -d ":" -f2) == 'Monitor' ]]; then
            echo "Monitor mod'da [+]"
            main
        else
            echo "Monitor mod'da degil."
            monitoron
        fi
}

checkdata() {
    if [[ -e "$(pwd)/data-01.csv" ]]; then
        rm -rf $(pwd)/data-01.csv
    else
        echo ""
    fi
}

wlan=$1
root
monitorcheck
