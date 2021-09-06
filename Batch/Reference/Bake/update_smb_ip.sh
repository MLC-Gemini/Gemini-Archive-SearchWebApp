PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH
export LD_LIBRARY_PATH=/opt/oracle/instantclient_12_2:$LD_LIBRARY_PATH
export PATH=/opt/oracle/instantclient_12_2:$PATH
export TNS_ADMIN=/opt/oracle/tnsnames
export no_proxy=localhost,169.254.169.254,hip.ext.national.com.au,github.aus.thenational.com,artifactory.ext.national.com.au

sqlplus crms/crms135@devops << EOF
exec crms_config_set('O','SMB-IP','$(hostname -i)','');
EOF

