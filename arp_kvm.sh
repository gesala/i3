#!/bin/bash

# Script que utilizo para realizar una arp de las maquinas virtuales que utilizan conexiones tipo bridge wireless

# Para configurar el dispositivo Bridge: https://unix.stackexchange.com/questions/159191/setup-kvm-on-a-wireless-interface-on-a-laptop-machine

#Configuración

#Una maquina en ejecución esta en el estado "virsh list"
STATE=ejecutando

#La red de bridge....Importante el ultimo punto
NET=192.168.1.

#Tarjeta wireless
WLAN=wlp82s0

#Maquinas Virtuales en ejecucion
NODES=`virsh list |grep ejecutando |awk '{print $2}'`
echo "$NODES" > /tmp/arp_kvm.log
for VM in `echo $NODES`
do
	#Esta la máquina en el rango de nuestra red?
	VM_IP=`virsh domifaddr $VM | grep -F $NET|awk '{print $4}'`
	echo "$VM: $VM_IP" >> /tmp/arp_kvm.log
	if [ "$VM_IP" != "" ]
	then
		#Si esta en nuestra red, transformamos un poquito la ip para quitarle el CIDR
		#y lanzamos el arp	
		ARP_IP=`echo $VM_IP|cut -f1 -d"/"`
		/usr/sbin/arp -i $WLAN -Ds $ARP_IP $WLAN pub
		echo "$VM: $ARP_IP en $WLAN --> arp" >> /tmp/arp_kvm.log
	fi
done
