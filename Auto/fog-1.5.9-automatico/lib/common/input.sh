#  FOG is a computer imaging solution.
#  Copyright (C) 2007  Chuck Syperski & Jian Zhang
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
if [[ $guessdefaults == 1 ]]; then
    strSuggestedOS=2

    allinterfaces=$(getAllNetworkInterfaces)
    strSuggestedInterface=$(echo ${allinterfaces} | awk '{print $1}')
    if [[ -z $strSuggestedInterface ]]; then
        echo "ERROR: No hemos encontrado ninguna interficie de red en tu pc."
        exit 1
    fi
    strSuggestedRoute=$(ip route | grep -E "default.*${strSuggestedInterface}|${strSuggestedInterface}.*default" | head -n1 | cut -d' ' -f3 | tr -d [:blank:])
    if [[ -z $strSuggestedRoute ]]; then
        strSuggestedRoute=$(route -n 2>/dev/null | grep -E "^.*UG.*${strSuggestedInterface}$" | head -n1 | awk '{print $2}' | tr -d [:blank:])
    fi
    strSuggestedDNS=""
    [[ -f /etc/resolv.conf ]] && strSuggestedDNS=$(cat /etc/resolv.conf | grep -E "^nameserver" | head -n 1 | tr -d "nameserver" | tr -d [:blank:] | grep "^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$")
    [[ -z $strSuggestedDNS && -d /etc/NetworkManager/system-connections ]] && strSuggestedDNS=$(cat /etc/NetworkManager/system-connections/* | grep "dns" | head -n 1 | tr -d "dns=" | tr -d ";" | tr -d [:blank:] | grep "^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$")
    if [[ -z $strSuggestedDNS ]]; then #If the suggested DNS is still empty, take further steps to get the addresses.
        mkdir -p /tmp > /dev/null 2>&1 #Make sure /tmp exists, this will be the working directory.
        cat /etc/resolv.conf | grep "nameserver" > /tmp/nameservers.txt #Get all lines from reslov.conf that have "nameserver" in them.
        sed -i 's:#.*$::g' /tmp/nameservers.txt #Remove all comments from new file.
        sed -i -- 's/nameserver //g' /tmp/nameservers.txt #Change "nameserver " to "tmpDns="
        sed -i '/^$/d' /tmp/nameservers.txt #Delete blank lines from temp file.
        strSuggestedDNS=$(head -n 1 /tmp/nameservers.txt) #Get first DNS Address from the file.
	rm -f /tmp/nameservers.txt #Cleanup after ourselves.	
    fi
    strSuggestedHostname=$(hostname -f)
fi
displayOSChoices
while [[ -z $installtype ]]; do
    installtype="N"
    echo -e "Tipo de instalacion: Normal"
done
while [[ -z $interface ]]; do
    blInt="N"
    if [[ -z $autoaccept ]]; then
        echo
        echo "  Hemos encontrado la siguiente interficie de red:"
        for i in $allinterfaces
        do
            iip=$(ip -4 addr show $i | awk '$1 == "inet" {print $2}')
            echo "      * $i - $iip"
        done
        echo
        echo "  Quieres cambiar la interfaz de red: $strSuggestedInterface?"
        echo -n "  Si no estas seguro, selecciona No. [y/N] "
        read blInt
    fi
    case $blInt in
        [Nn]|[Nn][Oo]|"")
            interface=$strSuggestedInterface
            ;;
        [Yy]|[Yy][Ee][Ss])
            echo -n "  Que interfaz de red quieres usar? "
            read interface
            ;;
        *)
            echo "  Input invalido, intenta de nuevo."
            ;;
    esac
    ip -4 link show $interface >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo
        echo "   * La interficie llamada $interface no existe."
        interface=""
        continue
    fi
    ipaddress=$(ip -4 addr show $interface | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}')
    if [[ $(validip $ipaddress) -ne 0 ]]; then
        echo
        echo "   * La interfaz $interface no tiene una IP valida configurada."
        interface=""
        continue
    fi
    submask=$(cidr2mask $(getCidr $interface))
    if [[ -z $submask ]]; then
        submask=$(/sbin/ifconfig -a | grep $ipaddress -B1 | awk -F'[netmask ]+' '{print $4}' | head -n2)
        submask=$(mask2cidr $submask)
    fi
done
if [[ $strSuggestedHostname == $ipaddress ]]; then
    strSuggestedHostname=$(hostnamectl --static)
fi

count=0
blRouter=""
blDNS=""
installlang=""
while [[ -z $routeraddress ]]; do
    if [[ -z $autoaccept ]]; then
        blRouter="N"
        echo -e "  No has usado el DHCP"
        break
    fi
done
count=0
while [[ -z $dnsaddress ]]; do
    if [[ -z $autoaccept ]]; then
        blDNS="N"
        echo -e "  El DHCP no cambia el DNS"
        break
    fi
done
while [[ -z $dodhcp ]]; do
    if [[ -z $autoaccept ]]; then
        dodhcp="Y"
        echo -e "  Tu fog servira como servidor DHCP"
        break
    fi
done
while [[ -z $installlang ]]; do
    if [[ -z $autoaccept ]]; then
        installlang="N"
        echo -2 "  No se han instalado paquetes de idioma adicionales"
        break
    fi
done
[[ -z $snmysqlhost ]] && snmysqlhost='localhost'
[[ -z $snmysqluser ]] && snmysqluser='fogmaster'

while [[ -z $dohttps ]]; do
    if [[ -z $autoaccept && -z $shttpproto ]]; then
        echo -e "  No se va a utilizar https en tu fog"
        dohttps=0
        httpproto="http"
        break
    fi
    [[ "$shttpproto" == "https" ]] && dohttps="yes"
done
