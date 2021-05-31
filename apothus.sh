#! /bin/bash/


root() {
    if [[ $EUID -ne 0 ]]; then
    echo "Bu scripti calistirabilmek icin root kullanicisi olmalisin! [-]" 
    exit 1
    else
        echo "Root kullanicisin. [+]"
    fi
}

monitoron() {
        echo "Monitor moda geciliyor..."
        iwconfig $1 > /dev/null 2>&1
        if [ "$?" = 250 ]; then
            echo "Boyle bir cihaz yok!"
            exit 1
        fi
        ifconfig $1 down
        iwconfig $1 mode monitor > /dev/null 2>&1
        ifconfig $1 up
        if [[ ! $(iwconfig $1|grep -o "Mode:[A-Za-z]*"|cut -d ":" -f2) == "Monitor" ]]; then
            echo $(iwconfig $1|grep -o "Mode:[A-Za-z]*"|cut -d ":" -f2)
            echo "Lütfen $1 adlı arayüzün sürücülerinin tam veya güncel olduğundan emin olun bundan eminseniz ve hala hata alıyorsanız ya sürücülerinizde ya da $1 adlı arayüzünüz monitor modu desteklemiyor olabilir"
            sleep 2
            exit
        else
            echo "$1.......................MONİTOR"
        fi

}

monitorcheck() {
        if [[ $(iwconfig $1|grep -o "Mode:[A-Za-z]*"|cut -d ":" -f2) == 'Monitor' ]]; then
            echo "Monitor mod'da [+]"
        else
            echo "Monitor mod'da degil."
            monitoron
        fi
}


root
monitorcheck
