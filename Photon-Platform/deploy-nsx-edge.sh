#!/bin/bash
#bdereims@vmware.com

###
### Deploy NSX-T Edge OVA 
###

CONFDIR=./conf.d 
DEFAULT=".default"

[ ! -e ${DEFAULT} ] && echo "error: file '${DEFAULT}' does not exist" && exit 1
CONF=$(cat ${DEFAULT})
[ ! -e ${CONFDIR}/${CONF} ] && echo "error: conf file '${CONFDIR}/${CONF}' does not exist" && exit 1

.  ${CONFDIR}/${CONF}

### Local vars ####

HOSTNAME=nsx-edge-1
NAME=NSX-EDGE-1
OVA=${BITS}/nsx-edge-1.1.0.0.0.4788148.ova
IP=172.18.2.22
DATASTORE=Datastore
TARGET=esx-01.${DOMAIN}

###################

export MYSCRIPT=/tmp/$$

cat << EOF > ${MYSCRIPT}
cd ${OVFDIR}
./ovftool --acceptAllEulas --noSSLVerify --skipManifestCheck \
--X:injectOvfEnv --overwrite --powerOffTarget --allowExtraConfig \
--X:apiVersion=5.5 --X:waitForIp --powerOn --diskMode=thin \
--prop:nsx_ip_0=${IP} \
--prop:nsx_netmask_0=${NETMASK} \
--prop:nsx_gateway_0=${GATEWAY} \
--prop:nsx_dns1_0=${DNS} \
--prop:nsx_domain_0=${DOMAIN} \
--prop:nsx_ntp_0=${NTP} \
--prop:nsx_isSSHEnabled=True \
--prop:nsx_allowSSHRootLogin=True \
--prop:nsx_hostname=${HOSTNAME} \
--prop:nsx_cli_passwd_0=${PASSWORD} \
--prop:nsx_passwd_0=${PASSWORD} \
"--datastore=${DATASTORE}" -n=${NAME} \
"--net:Network 0=${PORTGROUP}" \
"--net:Network 1=${PORTGROUP}" \
"--net:Network 2=${PORTGROUP}" \
"--net:Network 3=${PORTGROUP}" \
${OVA} \
vi://${ADMIN}:'${PASSWORD}'@${TARGET}
EOF

sh ${MYSCRIPT}

rm ${MYSCRIPT}
