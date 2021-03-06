#!/bin/bash 
#bdereims@vmware.com


[ "${1}" == "" ] && echo "usage: ${0} deploy_env" && exit 1

if [ -f "${1}" ]; then
	. ./"${1}"
else
	SUBNET=$( ./cpod_ip.sh ${1} )

	[ $? -ne 0 ] && echo "error: file or env '${1}' does not exist" && exit 1

	CPOD=${1}
	. ./cpod-xxx_env
fi

### Local vars ####

HOSTNAME=${HOSTNAME_VCSA}
NAME=${NAME_VCSA}
IP=${IP_VCSA}
OVA=${OVA_VCSA}
TARGET=${TARGET_VCSA}
DATASTORE=${DATASTORE_VCSA}
PORTGROUP=${PORTGROUP_VCSA}

###################

SEDCMD="s/###PASSWORD###/${PASSWORD}/;s!###TARGET###!${TARGET}!;s/###PORTGROUP###/${PORTGROUP}/;s/###DATASTORE###/${DATASTORE}/;s/###IP###/${IP}/;s/###DNS###/${DNS}/;s/###GATEWAY###/${GATEWAY}/;s/###HOSTNAME###/${HOSTNAME}/;s/###NAME###/${NAME}/"
cat vcsa-65.json | sed "${SEDCMD}"  > /tmp/vcsa-65.json

umount /mnt
mount -o loop $OVA /mnt
cd /mnt/vcsa-cli-installer/lin64
./vcsa-deploy install --no-esx-ssl-verify --accept-eula --acknowledge-ceip /tmp/vcsa-65.json
