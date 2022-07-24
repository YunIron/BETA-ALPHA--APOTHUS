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
    echo "$wlan | $namecard"
    xterm -hold -title "STORM BREAKER WİFİ SCANNER" -geometry 110x50 -sb -sl 1000 -e "sudo airodump-ng -w input --output-format "csv" $wlan"
	while IFS= read -r line
	do
        echo "$line"
    done < data-01.csv
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
    if [[ -e "$(pwd)/data-01.csv") ]]; then
        rm -rf $(pwd)/data-01.csv
    else
        echo ""
    fi
}

wlan=$1
root
monitorcheck
