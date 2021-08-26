#/tmp/config_batch_final.sh $CTM_AGENT_SHORT $CTM_SERVER_NAME $CTM_AGENT_TO_SERVER_PORT $CTM_SERVER_TO_AGENT_PORT
#For testing
#app_ctm_short_name=awsddevcrmsbat
#app_ctm_master_short_name=cmdevv9
#app_ctm_outport=9025
#app_ctm_inport=9026
#app_ctm_home=/opt/ctlm/ctmagentv9

#Code starts here
app_ctm_short_name=$1
app_ctm_master_short_name=$2
app_ctm_outport=$3
app_ctm_inport=$4
app_ctm_home=/opt/ctlm/ctmagentv9

#Configure control-m environment
function ctmConfig() {
  sed -i "
    s/LOGICAL_AGENT_NAME.*/LOGICAL_AGENT_NAME   ${app_ctm_short_name}/
    s/LOCALHOST.*/LOCALHOST   ${app_ctm_short_name}/
    s/CTMSHOST .*/CTMSHOST   ${app_ctm_master_short_name}/
    s/CTMPERMHOSTS .*/CTMPERMHOSTS   ${app_ctm_master_short_name}/
    s/PROTOCOL_VERSION .*/PROTOCOL_VERSION   10/
    s/LOGKEEPDAYS .*/LOGKEEPDAYS   14/
    s/ATCMNDATA .*/ATCMNDATA   ${app_ctm_outport}/
    s/AGCMNDATA .*/AGCMNDATA   ${app_ctm_inport}/
    s/ctm_master_short/${app_ctm_master_short_name}/g
    s/9119/${app_ctm_outport}/g
    s/9229/${app_ctm_inport}/g
      " ${app_ctm_home}/ctm/data/CONFIG.dat

    #delete entries from OS.dat file
    sed -i '/OUTPUT_NAME .*/d' ${app_ctm_home}/ctm/data/OS.dat
    sed -i '/OUTPUT_OWNER .*/d' ${app_ctm_home}/ctm/data/OS.dat
    sed -i '/OUTPUT_MODE .*/d' ${app_ctm_home}/ctm/data/OS.dat


  cat >> ${app_ctm_home}/ctm/data/OS.dat <<EOF
OUTPUT_OWNER   OWNER
OUTPUT_MODE   644
EOF

}

ctmConfig
chkconfig ctmagentv9 on
systemctl enable ctmagentv9 --now
systemctl start ctmagentv9
rm -f /tmp/crms_decrypt
