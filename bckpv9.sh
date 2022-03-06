#!/bin/bash
#!/bin/sh -
#
#************************************************************************************************************************************************************#
# /*/ Numbers in menus represent the line where the variable are located in the host configuration file (/usr/lib/cssam/backup/hosts/HostIP/Host_IP.txt) /*/ #
# /*/ Root password is removed from configuration file.                                                                                                  /*/ #
# Structure:                                                                                                                                                 #
# Local Menu:                                                                                                                                                #
# Central management - Backup a new host, Remove host from backup, backup a site manually.                                                                   #
#                      Step 1: Input IP address, Port, root user, root passwd to host configuraion file.                                                     #
#                      Step 2: Connect to remote host and check for: Disk space, MySQL DB, WWW Dir, SSL, Httpd.                                              #
#                      Step 3: rsync configuration files to localhost, if MySQL detected -> enter root and passwd -> added to backup.                        #
# Service - While host dir in /usr/lib/cssam/backup/hosts/* read configuration files and rsync + tar WWW dir as pre-configured in 'Host_IP.txt'.             #
# EOS                                                                                                                                                        #
#************************************************************************************************************************************************************#
#
#**************************#
##### START OF SERVICE #####
#**************************#
#
 #*************************************#
 # Step 4:                             #
 # loop ip directories                 #
 # Check backup done yesterday         #
 # Connect via ssh                     #
 # Check disk space + alert            #
 # disconnect ssh                      #
 # rsync dir                           #
 # tar dir                             #
 # rsync sql                           #
 # rsync ssl                           #
 # rsync httpd                         #
 # remove old backups                  #
 #*************************************#
#
function main_service_ () {
SERCHK=`systemctl list-units --full -all | grep "backupme.service" | wc -l`
if [ "$SERCHK" == "0" ]; then
cat > /etc/systemd/system/backupme.service <<-"EOF"
[Unit]
Description=Radmon service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=43200
ExecStart=/bin/sh -c "/etc/backupme.sh"
StandardOutput=null
StandardError=inherit

[Install]
WantedBy=multi-user.target
EOF

systemctl start backupme
systemctl enable backupme
systemctl restart backupme
systemctl daemon-reload
create_service_chkdisk
backup_mysql_
create_service_
fi

systemctl restart backupme
}
#
function create_service_chkdisk_ () {
cat > /etc/checkremotedisk.sh <<-"EOF"
#!/bin/bash
#!/bin/sh -
ssh -p IPPORT ROOTU@LINE 'bash -s' EEEE
function check_disk_space_ () {
 RM='litan.shamir@cglms.com'
 HN=`hostname -s`
 DN='cglms.com'
 SSHRIP="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
 CHK=`df -h | grep -o -P '.{0,3}%' | sed -n '1!p' | tr -d '%' | awk -F: '{if($1>90)print$1}' | wc -l`
 if [ "$CHK" != 0 ]; then
  { echo "Hi there !" ;echo "" ;echo ""$HN" *"$SSHRIP"* have problem with disk space".;} | sed -e 's/^[ \t]*//' | mail -s "***On server "$HN" disk above '90%' full !!! "  -r " <$HN@$DN>" $RM }
  exit 0
 else
  echo ""
 fi
}
EEE
EOF
}
#
function create_service_ () {
cat > /etc/backupme.sh <<-"EOF"
HN=`hostname -s`
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
DN=cglms.com
RM=litan.shamir@cglms.com
SM=$HN@$DN
LD="$(date +"Time-%H:%M:%S-Date-%d.%m.%Y")"
#
function mail_done_ () {
 echo "Hi there Admin! "$HN" *"$IPL"* Backup done" | mail -s "***Backup done on "$IPL" !!! "  -r " <$HN@$DN>" $RM
}
#
cd /usr/lib/cssam/backup/hosts && ls -A > /root/hostslist.txt
echo > /root/hostslisttmp.txt
while IFS= read -r line
 do
  if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
   echo $line >> /root/hostslisttmp.txt
  fi
 done < /root/hostslist.txt
mv -f /root/hostslisttmp.txt /root/hostslist.txt
#
while IFS= read -r line
 do
  #
  function mail_alert_ () {
   echo "Hi there Admin!" ; echo "" ;echo ""$line" *"$line"* Did not backup!!! Exiting, Please Check!!!" | sed -e 's/^[ \t]*//' | mail -s "***No Backup on "$line" !!! "  -r " <$line@$DN>" $RM
  }
  #
  function check_backup_done_ () {
   YDATE=`date -d "yesterday" '+%d.%m.%Y'`
   CheckYwww=`ls -l /usr/lib/cssam/backup/hosts/$line/WWW/ | grep "$YDATE"`
   CheckYsql=`ls -l /usr/lib/cssam/backup/hosts/$line/SQL/ | grep "$YDATE"`
   if [ "$CheckYwww" == "0" ] && [ "$CheckYsql" == "0" ] && [ -f "/root/backupft.txt" ]; then
    mail_alert_ && sleep 20 && exit 0
   fi
    echo "first time" > /root/backupft.txt
  }
  #
  function Backup_Variables_ () {
   IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   ROOTU='root'
   WWWDIR="$(sed -n '5p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   SSLDIR="$(sed -n '6p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   SQLDIR="$(sed -n '7p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   LD="$(date +"Time-%H:%M:%S-Date-%d.%m.%Y")"
  }
  #
  Backup_Variables_
  check_backup_done_
  #
  function check_remote_disk_ () {
   Backup_Variables_
   echo > /etc/checkremotediskORG.sh
   IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   ROOTU='root'
   yes | cp -rf /etc/checkremotedisk.sh /etc/checkremotediskORG.sh
   sed -i "s/EEE/EOF/g" /etc/checkremotedisk.sh
   sed -i "s/XXEE/<<-"'"EOF"'"/g" /etc/checkremotedisk.sh
   sed -i "s/IPPORT/$IPPORT/g" /etc/checkremotedisk.sh
   sed -i "s/ROOTU/$ROOTU/g" /etc/checkremotedisk.sh
   sed -i "s/LINE/$IPADDR/g" /etc/checkremotedisk.sh
   chmod +x etc/checkremotedisk.sh
   /./etc/checkremotedisk.sh
   rm -rf /etc/checkremotedisk.sh
   mv /etc/checkremotediskORG.sh /etc/checkremotedisk.sh
   rm -rf /etc/checkremotediskORG.sh
  }
  #
  check_remote_disk_
  #
  if [ "$WWWDIR" != "" ]; then
   Backup_Variables_
   mkdir -p /usr/lib/cssam/backup/hosts/$line/WWW/TMP
   while IFS= read -r site
    do
     mkdir -p /usr/lib/cssam/backup/hosts/$line/WWW/TMP/$site
     mkdir -p /usr/lib/cssam/backup/hosts/$line/WWW/$site
     rsync -avzhe "ssh -p $IPPORT" root@$line:$WWWDIR/$site /usr/lib/cssam/backup/hosts/$line/WWW/TMP
     cd /usr/lib/cssam/backup/hosts/$line && tar --exclude 'exclude.txt' -cvzf /usr/lib/cssam/backup/hosts/"$line"/WWW/"$site"/"$site"_www_"${LD}".tar.gz /usr/lib/cssam/backup/hosts/$line/WWW/TMP/$site;
     rm -rf /usr/lib/cssam/backup/hosts/$line/WWW/TMP
    done < /usr/lib/cssam/backup/hosts/$line/sitelist.txt

    mkdir -p /usr/lib/cssam/backup/hosts/$line/SSL/TMP
    rsync -avzhe "ssh -p $IPPORT" root@$line:$SSLDIR /usr/lib/cssam/backup/hosts/$line/SSL/TMP
    tar -cvzf /usr/lib/cssam/backup/hosts/"$line"/SSL/"$line"_ssl_"${LD}".tar.gz /usr/lib/cssam/backup/hosts/$line/SSL/TMP/;
    rm -rf /usr/lib/cssam/backup/hosts/$line/SSL/TMP

    mkdir -p /usr/lib/cssam/backup/hosts/$line/HTTPD/TMP
    rsync -avzhe "ssh -p $IPPORT" root@$line:/etc/httpd/conf /usr/lib/cssam/backup/hosts/$line/HTTPD/TMP
    tar -cvzf /usr/lib/cssam/backup/hosts/"$line"/HTTPD/"$line"_httpd_"${LD}".tar.gz /usr/lib/cssam/backup/hosts/$line/HTTPD/TMP/;
    rm -rf /usr/lib/cssam/backup/hosts/$line/HTTPD/TMP
  fi
  #
  function bckp_sql_ () {
  echo  Starting sql beckup ....
   LD2="$(date +"Date-%d.%m.%Y-%H:%M")"
    sleep 3
     mysql -uroot -pI_will_backup_you -N -e 'show databases;' |
      while read dbname;
       do
        cd /home/wwwbckp && mysqldump -uroot -pI_will_backup_you --complete-insert --routines --triggers --single-transaction "$dbname" > "$dbname-$LD2".sql;
         rm -rf performance*.sql
          rm -rf mysql-*.sql
           done
            echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
             echo  MySQL backup finished. Going sleep
  }
  #
  function reset_mariadb_root_p_ () {
  pkill -9 mysqld
   pkill -9 mariadb
    sudo mysqld_safe --skip-grant-tables --skip-networking  >res 2>&1 &
     printf "Resetting password... hold on\n"
      sleep 7
       mysql mysql -e "UPDATE user SET Password=PASSWORD('I_will_backup_you') WHERE User='root' AND host='localhost';FLUSH PRIVILEGES;"
        systemctl stop mariadb
         clear
          pkill -9 mysqld
           pkill -9 mariadb
            clear
              sudo systemctl start mariadb
               echo 'Cleaning up...'
                sleep 3
                 pkill -9 mysqld
                  pkill -9 mariadb
                   systemctl stop mariadb
                    sudo systemctl start mariadb
                     sleep 3
                      bckp_sql_
  }
  #
  function copy_remote_mysql_ () {
   echo "Stoping MySQL"
    systemctl stop mariadb
     rm -rf /var/lib/mysql/*
      rsync -avzhe "ssh -p $IPPORT" --progress root@$SSHRIP:/var/lib/mysql/ /var/lib/mysql/
       chown -R mysql:mysql /var/lib/mysql/
        reset_mariadb_root_p_
  }
  #
  if [ "$SQLDIR" != "" ]; then
   Backup_Variables_
   copy_remote_mysql_
  fi
  #
  function rm_old_bckp_ () {
   Backup_Variables_
   DELL=130
   DELLLESS=30
   CHK=`find /usr/lib/cssam/backup/hosts/$line/DB/ -mtime +$DELLESS | wc -l` > /dev/null 2>&1 && clear
   if [ "$CHK" != "0" ]; then
    find /usr/lib/cssam/backup/hosts/$line/DB/*.* -mtime +$DEL -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$line/WWW/*.*/*.* -mtime +$DEL -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$line/SSL/*.* -mtime +$DELLESS -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$line/HTTPD/*.* -mtime +$DELLESS -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$line/SSL/*.* -mtime +$DELLESS -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$line/HTTPD/*.* -mtime +$DELLESS -exec rm {} \;
    rm -rf /root/hostslist.txt
    exit 0
   fi
  }
  #
  rm_old_bckp_
  #
 done < /root/hostslist.txt
 mail_done_
EOF
}
#
#*********************#
##### RUN SERVICE #####
#*********************#
#
function install_service_ () {
  main_service_
}
#
install_service_                                # (SERVICE G-0)  <=====<
#
#/////////////////\
#\\\\\\\\\\\\\\\\\\\
#////////////////////
#\\\\\\\\\\\\\\\\\\\\\
#
#********************#
#    ()        ()    #
#********************#
##### LOCAL MENU #####
#********************#
#  \     (  )     /  #
# <><><><><><><><><> #
#       |    |       #
#********************#
#
 #*******************#
 ##### VARIABLES #####
 #*******************#
#
function variables_ () {
export PATH1=/
export normal=`echo "\033[m"`
export menu=`echo "\033[36m"` #Blue
export bgmenu=`echo "\033[46m"` #Blue
export number=`echo "\033[33m"` #yellow
export bgred=`echo "\033[41m"`
export fgred=`echo "\033[31m"`
export green=`echo "\033[32m"`
export blink=`echo "\033[5m" `
export lightbggrey=`echo "\033[47m" `
export bggrey=`echo "\033[100m" `
export grey=`echo "\033[90m" `
export menu1=`echo -e "\033[100m"`
export black=`echo -e "\033[30m"`
export bggreen=`echo -e "\033[42m"`
export bgwhite=`echo -e "\033[100m"`
export bold=`echo -e "\033[1m"`
shtime=`date +"%H"`
smtime=`date +"%M"`
mkdir -p /var/webbckp                 ### Create local dir
M=mail
FIRSTIP=`hostname -I | awk '{print $1,"\n"$2,"\n",$3 }' | sed '/:/d' | awk 'NF > 0' | sed 's/^[ \t]*//' | sed 's/[[:blank:]]*$//' | sed -n '1p'`
SECONDIP=`hostname -I | awk '{print $1,"\n"$2,"\n",$3 }' | sed '/:/d' | awk 'NF > 0' | sed 's/^[ \t]*//' | sed 's/[[:blank:]]*$//' | sed -n '2p'`
IP="$(hostname -I)"
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
SIG1="Have a nice day"
SIG2="Security Assistance"
HN="$(hostname)"
SRV=`hostname -s`
DN=cglms.com
RM=litan.shamir@cglms.com
SM=$HN@$DN
D="$(date +"Time:%H:%M:%S" && date +"Date:%d.%m.%Y")"
LD="$(date +"Time-%H:%M:%S-Date-%d.%m.%Y")"
E=echo
F=find
X=xargs
DU1="$(df -h)"
TD="$(fdisk -l | grep -m 1 -o -P '(?<=: ).*(?=B, )')"
DEL=130
DELLESS=30
TL1=/var/geo.log
}
#
function gl_ () {
TL1=/var/log/geo.log && echo > "$TL1"
PIP="$(curl https://ipinfo.io/ip)"
GL1="$(curl https://ipvigilante.com/$pip | tee >>$TL1)"
GL2="$(cat "$TL1" | grep -m 1 -o -P '(?<=("country_name":)).*(?=,"subdivision_1_name":)'  )"
}
#
 #*****************#
 ##### BANNERS #####
 #*****************#
#
function unset_banner_ (){
    unset BANNER
	unset FIND
	unset GREPBANN
	unset COUNTFIND
}
#
function logo_findme_backup_ () {
cat << "EOF"
                                          _,.
                                        ,` -.)
                                      '( _/'-\\-.
                                      /,|`--._,-^|           ,
                                      \_| |`-._/||         ,'|
                                        |  `-, / |        /  /
                                        |     || |       /  /
                                         `r-._||/   _   /  /
                                     _,-<_     )`-/  `./  /
                                   '  \   `---'   \   /  /
                                  /    |           |./  /
                                  \    /  Backup   //  /
                                  \_/' \          |/  /
                                    |    |   _,^-'/  /
                                    |    , ``  (\/  /_
                                     \,.->._    \X-=/^
                                     (  /   `-._//^`
                                         `Y-.__(_}
                                         |     {_)
                                               ()`
EOF
}
#
function call_allert_title_ () {
    clear && echo && clear
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}${menu1}                                          ${bgwhite}${menu}Sites Backup${menu}${menu1}                                                  ${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	unset TIMEMENUBANNER
}
#
function logo_p_good_ () {
clear && clear && clear
cat << "EOF"
















                                 Packed up and good to GO Boss!!!
                                 --------------------------------
                                 \
                                  \
                                        .--.   ,||
                                       |o_o |  ({O'
                                       |:_/ |   /
                                      //   \ \ /
                                     (|     |
                                    /'\_   _/`\
                                    \__)=(__/
EOF
sleep 3
}
#
function border_ () {
# IFS=$'\n'
longstr=`(echo "$FULL11" | awk '{if(length>x){x=length;y=$0}}END{print y}')`
longlen=${#longstr}
edge=$(echo "$longstr" | sed 's/./-/g')
echo -e "\t\t\t\t     ${menu1}+$edge---+${normal}"
while IFS= read -r line; do
 strlen=${#line}
 echo -e -n "\t\t\t\t     ${menu1}|${normal} $line${normal}"
 gap=$((longlen - strlen))
 if [ "$gap" > 0 ]; then
  for i in $(seq 1 $gap); do echo -n " "; done
   echo -e "  ${menu1}|${normal}"
 else
  echo -e "  ${menu1}|${normal}"
 fi
done < <(printf '%s\n' "$FULL11")
echo -e "\t\t\t\t     ${menu1}+$edge---+${normal}\n\n"

}
#
 #****************#
 ##### ALERTS #####
 #****************#
#
function mail_done_ () {
  { $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* Backup done". ;$E "Server Details:"  ; $E "Geo Location: $GL2" ; $E "" ;$E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***Backup done on "$HN" !!! "  -r " <$HN@$DN>" $RM
  }
#
function mail_panic_ () {
  { $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* have problem with disk space". ;$E "Server Details:" ;$E "Local ip: "$IP"" ;$E "Public ip: $PIP" ;$E "Name: $HN" ; $E "Geo Location: $GL2" ; $E "" ; $E  "$DU1 " ; $E ""$TD"" ; $E "Exact time of event:" ; $E "$D" ; $E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***On server "$HN" disk above '90%' full !!! "  -r " <$HN@$DN>" $RM
  }
#
function mail_timeout_ () {
  { $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* TimedOut!!! Exiting, Please Check!!!". ;$E "Server Details:"  ; $E "Geo Location: $GL2" ; $E "" ;$E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***Timed Out "$HN" !!! "  -r " <$HN@$DN>" $RM
  }
#
function mail_alert_ () {
  { $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* Did not backup!!! Exiting, Please Check!!!". ;$E "Server Details:"  ; $E "Geo Location: $GL2" ; $E "" ;$E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***No Backup on "$HN" !!! "  -r " <$HN@$DN>" $RM
  }
#
 #*********************#
 # Step 1:             #
 # IP address        1 #
 # SSH Port          2 #
 # Root User         3 #
 # Root Passwd       4 #
 # echo > own ip dir   #
 #*********************#
#
 #*************#
 ##### SSH #####
 #*************#
#
function border_ssh_connected_hosts_ () {
echo > /root/hostlistview.txt
echo > /root/view.txt
if [ -d "/usr/lib/cssam/backup/hosts" ]; then
 find /usr/lib/cssam/backup/hosts/ -type d | sed -n '1!p' | sed 's|.*/||' > /root/hostlistview.txt
 checkfile=`grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" /root/hostlistview.txt | wc -l`
else
 checkfile="0"
fi
if [ "$checkfile" != "0" ]; then
 echo -e "Host           | Backups\n" >> /root/view.txt
 while IFS= read -r line
  do
   if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    WWWDIR="$(sed -n '5p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
    SQLDIR="$(sed -n '7p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
    if [ "$WWWDIR" != "" ] && [ "$SQLDIR" == 'MySQL exists' ]; then
     echo "$line : Backing up Sites, Httpd, SSL, MySQL" >> /root/view.txt
    elif [ "$WWWDIR" != "" ] && [ "$SQLDIR" != 'MySQL exists' ]; then
     echo "$line : Backing up Sites" >> /root/view.txt
    else
     echo "$line : Backing up MySQL" >> /root/view.txt
    fi
   else
    echo ""
   fi
  done < /root/hostlistview.txt
 HOSTSSSHCON=`cat /root/view.txt`
else
 HOSTSSSHCON=`echo "              No Connections found            "`
fi
longstr=`(echo "$HOSTSSSHCON" | awk '{if(length>x){x=length;y=$0}}END{print y}')`
longlen=${#longstr}
edge=$(echo "$longstr" | sed 's/./-/g')
echo -e "\t\t    ${menu1}+$edge---+${normal}"
while IFS= read -r line; do
 strlen=${#line}
 echo -e -n "\t\t    ${menu1}|${normal} ${green}$line${normal}"
 gap=$((longlen - strlen))
 if [ "$gap" > 0 ]; then
  for i in $(seq 1 $gap); do echo -n " "; done
  echo -e "  ${menu1}|${normal}"
 else
  echo -e "  ${menu1}|${normal}"
 fi
done < <(printf '%s\n' "$HOSTSSSHCON")
echo -e "\t\t    ${menu1}+$edge---+${normal}"
}
#
function border_host_list_ () {
if [ -f "/root/hostconfig1.txt" ]; then
for i in $(seq 1 $x); do
  HOSTSSSHCON=`cat /root/hostconfig$i.txt`
echo -e "\n\t\t\t\t\t$IPADDR\n"
longstr=`(echo "$HOSTSSSHCON" | awk '{if(length>x){x=length;y=$0}}END{print y}')`
longlen=${#longstr}
edge=$(echo "$longstr" | sed 's/./-/g')
echo -e "\t\t\t\t${menu1}+$edge---+${normal}"
while IFS= read -r line; do
 strlen=${#line}
 echo -e -n "\t\t\t\t${menu1}|${normal} ${green}$line${normal}"
 gap=$((longlen - strlen))
 if [ "$gap" > 0 ]; then
  for i in $(seq 1 $gap); do echo -n " "; done
  echo -e "  ${menu1}|${normal}"
 else
  echo -e "  ${menu1}|${normal}"
 fi
done < <(printf '%s\n' "$HOSTSSSHCON")
echo -e "\t\t\t\t${menu1}+$edge---+${normal}"
done
fi
}
#
function remove_ssh_host_ () {
  border_ssh_connected_hosts_
  echo -e "\n\t${menu}Please enter ip of host you want to remove${normal}"
  read -e -p "$C660" SSHRIPTOR
  if [[ $SSHRIPTOR = 'b' ]]; then
    start_menu_
  fi
  checkdir=`ls -A /usr/lib/cssam/backup/hosts | grep "$SSHRIPTOR"`
  if [[ $checkdir != 0 ]]; then
   rm -rf "/usr/lib/cssam/backup/hosts/$SSHRIPTOR" && clear
  fi
  checkconhost=`cat ~/.ssh/connected_hosts | grep "$SSHRIPTOR" | wc -l`
  if [[ $checkconhost != 0 ]]; then
   sed -i "/$SSHRIPTOR/d" ~/.ssh/connected_hosts
  fi
  checkknohost=`cat ~/.ssh/known_hosts | grep "$SSHRIPTOR" | wc -l`
  if [[ $checkknohost != 0 ]]; then
   sed -i "/$SSHRIPTOR/d" ~/.ssh/known_hosts
  fi
  start_menu_
}
#
function add_new_server_to_bckp_ () {
  export C660="$(printf "\t${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
  echo -e "\n\t${menu}Enter Host IP address${normal}"
  read -e -p "$C660" SSHRIP
  if [[ $SSHRIP = 'b' ]]; then
    start_menu_
  fi
  echo -e "\n\t${menu}Enter Host SSH port${normal}"
  read -e -p "$C660" SSHPORT
  if [[ $SSHPORT = 'b' ]]; then
    start_menu_
  fi
#  echo -e "\n\t${menu}Enter root user${normal}"
#  read -e -p "$C660" SSHADMIN
#  echo -e "\n\t${menu}Enter root password${normal}"
#  read -s -p "$C660" SSHPASSWD
  SSHADMIN='root'
  hostexist=`cat /root/.ssh/known_hosts| grep "$SSHRIP" | wc -l`
  hostexistcon=`cat /root/.ssh/connected_hosts| grep "$SSHRIP" | wc -l`
  if [ $hostexistcon == "0" ]; then
   sed -i "/$SSHRIP/d" ~/.ssh/connected_hosts
   sed -i "/$SSHRIP/d" ~/.ssh/known_hosts
   chmod 600  ~/.ssh/id_rsa.pub
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   echo -ne "$SSHPASSWD" | cat ~/.ssh/id_rsa.pub | ssh -p"$SSHPORT" $SSHADMIN@$SSHRIP ' cat >>~/.ssh/authorized_keys'
cat > /root/copyid.sh <<-EOF
ssh-copy-id -o StrictHostKeyChecking=no -p "$SSHPORT" $USRL@$SSHRIP
EOF
   sed -i "s/SSHPORT/$SSHPORT/g" /root/copyid.sh
   sed -i "s/USRL/$USRL/g" /root/copyid.sh
   sed -i "s/SSHRIP/$SSHRIP/g" /root/copyid.sh
   chmod +x /root/copyid.sh
   /./root/copyid.sh
   check_ssh_con_
   echo -e "ssh -p "$SSHPORT" "$USRL@$SSHRIP"" | tee >> ~/.ssh/connected_hosts
   clear && echo -e "\n\n\n\n\t\tSSH connection established!! Checking host..." && sleep 5 && clear
   check_remote_
  else
   clear && echo -e "\n\n\n\n\t\tSSH connection already exists!! Please reconfigure..." && sleep 5 && clear
  fi
}
#
function check_ssh_con_ () {
ssh -p "$SSHPORT" -q $USRL@$SSHRIP exit
RES=$(echo $?)
if [ ${RES} == 0 ];
then
 rm -rf /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
 mkdir -p /usr/lib/cssam/backup/hosts/$SSHRIP
 touch /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
 echo "$SSHRIP" >> /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
 echo "$SSHPORT" >> /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
 echo "" >> /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
 echo "" >> /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
 echo -e "\n\n\n\n\t\tSSH connection established!!"
else
 clear && echo -e "\n\n\n\n\t\tSSH connection NOT established!! Please reconfigure..." && sleep 5 && clear
 add_new_server_to_bckp_
fi
}
#
 #*******************#
 ##### FUNCTIONS #####
 #*******************#
#
function all_hosts_ () {
  echo > /root/hostlistview.txt
  find /usr/lib/cssam/backup/hosts/ -type d | sed -n '1!p' | sed 's|.*/||' > /root/hostlistview.txt
  echo > /root/toremove.txt
  ls /root | grep 'allhostspage' >> /root/toremove.txt
  while IFS= read -r despose
   do
    cd /root
    rm -rf $despose
   done < /root/toremove.txt
  rm -rf /root/toremove.txt

  echo > /root/hostlistcb.txt
  while IFS= read -r line
   do
    if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
     echo $line >> /root/hostlistcb.txt
    fi
  done < /root/hostlistview.txt
  cat /root/hostlistcb.txt | sed '/^$/d' >> /root/hostlistcbtmp.txt && mv -f /root/hostlistcbtmp.txt /root/hostlistcb.txt

  sum=`wc -l /root/hostlistcb.txt | awk '{print $1}'`
  i="1"
  while [[ "$sum" != "" ]];
   do
    if [ "$sum" -gt "9" ]; then
     echo > /root/allhostspage"$i".txt
     head -9 /root/hostlistcb.txt >> /root/allhostspage"$i".txt
     cat /root/allhostspage"$i".txt | sed '/^$/d' >> /root/allhostspage"$i"tmp.txt && mv -f /root/allhostspage"$i"tmp.txt allhostspage"$i".txt
     tail -n +10 /root/hostlistcb.txt >> /root/hostlistcbtmp.txt && mv -f /root/hostlistcbtmp.txt /root/hostlistcb.txt
     i=$(($i+1))
     sum=`wc -l /root/hostlistcb.txt | awk '{print $1}'`
    else
     sum=""
     cat /root/hostlistcb.txt >> /root/allhostspage"$i".txt
     rm -rf /root/hostlistcbtmp.txt
    fi
   done
}
#
function all_sites_ () {
echo > /root/hostlistview.txt
echo > /root/toremove.txt
ls /root | grep 'allsitespage' >> /root/toremove.txt
while IFS= read -r despose
 do
  cd /root
  rm -rf $despose
 done < /root/toremove.txt
rm -rf /root/toremove.txt

echo > /root/allsites.txt
while IFS= read -r line
 do
  if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
   cat /usr/lib/cssam/backup/hosts/$line/sitelist.txt >> /root/allsites.txt
  fi
done < /root/hostlistview.txt
cat /root/allsites.txt | sed '/^$/d' >> /root/allsitestmp.txt && mv -f /root/allsitestmp.txt /root/allsites.txt

sum=`wc -l /root/allsites.txt | awk '{print $1}'`
i="1"
while [[ "$sum" != "" ]];
 do
  if [ "$sum" -gt "9" ]; then
   echo > /root/allsitespage"$i".txt
   head -9 /root/allsites.txt >> /root/allsitespage"$i".txt
   cat /root/allsitespage"$i".txt | sed '/^$/d' >> /root/allsitespage"$i"tmp.txt && mv -f /root/allsitespage"$i"tmp.txt allsitespage"$i".txt
   tail -n +10 /root/allsites.txt >> /root/allsitestmp.txt && mv -f /root/allsitestmp.txt /root/allsites.txt
   i=$(($i+1))
   sum=`wc -l /root/allsites.txt | awk '{print $1}'`
  else
   sum=""
   cat /root/allsites.txt >> /root/allsitespage"$i".txt
   rm -rf /root/allsitestmp.txt
  fi
 done
}
#
function previous_menu_ () {
 if [ "$page" != "1" ]; then
  page=$(($page-1))
 fi
 chk_box_manual_backup_
}
#
function next_menu_ () {
 allsite=`ls /root | grep 'allsitespage' | wc -l`
 if [ "$page" != "$allsite" ]; then
  page=$(($page+1))
 fi
 chk_box_manual_backup_
}
#
function previous_menu_hosts_ () {
 if [ "$page" != "1" ]; then
  page=$(($page-1))
 fi
 chk_box_host_list_
}
#
function next_menu_hosts_ () {
 allhosts=`ls /root | grep 'allhostspage' | wc -l`
 if [ "$page" != "$allhosts" ]; then
  page=$(($page+1))
 fi
 chk_box_host_list_
}
#
function chk_box_manual_backup_ () {
  unset options
  unset choices
  echo > /root/backupmanual.txt
  clear && echo && clear
  FULL20=`cat /root/allsitespage"$page".txt`
  declare -a options=($FULL20)
  menu_list_() {
  clear && call_allert_title_
  for z in ${!options[@]}; do
  printf "\n\t\t%3d%s) %s\t\t" $((z+1)) "${choices[z]:- }" "${options[z]}"
  done
  [[ "$msg" ]] && echo -e "\n\n\t\t$msg"; :
  }
  clear && call_allert_title_
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Manual Backup Menu${normal}\n"
  prompt=`echo -e "\n\n\t\t\t\t${menu}Select${normal} Site to Backup${menu}\n\t\t\t\t1. You may choose up to 9 sites to backup,\n\t\t\t\tBut only from ONE page!!!\n\t\t\t\t2. Move between pages [${number}p=previous n=next${menu}]\n\t\t\t\t3. When done press [${number}Enter${menu}]${normal}\n\t\t\t\t${normal}"`
  while menu_list_ && read -n 1 -rp  "$prompt" num && [[ "$num" ]]; do
  if [[ $num == 'b' ]]; then
    start_menu_
  fi
  if [[ $num == 'p' ]]; then
    previous_menu_
  fi
  if [[ $num == 'n' ]]; then
    next_menu_
  fi
  clear && call_allert_title_
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Manual Backup Menu${normal}\n"
  [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) ||
  {
  msg="Invalid option: $num"; continue
  }
  clear && call_allert_title_
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Manual Backup Menu${normal}\n"
  local CHOICE=`echo -e "[${fgred}+${normal}]"`
  ((num--));
  [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="$CHOICE"
  done
  clear && echo && clear
  for z in ${!options[@]}; do
  FULL14='/root/backupmanual.txt'
  [[ "${choices[z]}" ]] && { echo "${options[z]}" >> $FULL14; msg="";  }
  done | tee > $FULL14 &&  sed -i 's/^[ \t]*//' $FULL14
  unset options
  unset choices

  ls /root | grep 'allsitespage' >> /root/toremove.txt
  while IFS= read -r despose
   do
    cd /root
    rm -rf $despose
   done < /root/toremove.txt
   rm -rf /root/toremove.txt
   backup_selected_
}
#
function chk_box_host_list_ () {
  unset options
  unset choices
  echo > /root/hostlistcb.txt
  FULL20=`cat /root/allhostspage"$page".txt`
  declare -a options=($FULL20)
  menu_list_() {
  call_allert_title_
  echo -e "\n\t\t\t\t\t${menu}${menu1}Connected Hosts${normal}\n"
  border_ssh_connected_hosts_
  border_host_list_
  for z in ${!options[@]}; do
  printf "\n\t\t\t\t   %3d%s) %s   \t\t\t\t" $((z+1)) "${choices[z]:- }" "${options[z]}"
  done
  [[ "$msg" ]] && echo -e "\n\n\t\t$msg"; :
  }
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Manual Backup Menu${normal}\n"
  prompt=`echo -e "\n\n\t\t\t  ${menu}Select a host to view full configuration${menu}\n\t\t\t  1. You may choose up to 9 hosts to view,\n\t\t\t  But only from ONE page!!!\n\t\t\t  2. Move between pages [${number}p=previous n=next${menu}]\n\t\t\t  3. When done press [${number}Enter${menu}]${normal}\n\t\t\t\t${normal}"`
  while menu_list_ && read -n 1 -rp  "$prompt" num && [[ "$num" ]]; do
  if [[ $num == 'b' ]]; then
    start_menu_
  fi
  if [[ $num == 'p' ]]; then
    previous_menu_hosts_
  fi
  if [[ $num == 'n' ]]; then
    next_menu_hosts_
  fi
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Manual Backup Menu${normal}\n"
  [[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) ||
  {
  msg="Invalid option: $num"; continue
  }
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Manual Backup Menu${normal}\n"
  local CHOICE=`echo -e "[${fgred}+${normal}]"`
  ((num--));
  [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="$CHOICE"
  done
  for z in ${!options[@]}; do
  FULL40='/root/hostlistcb.txt'
  [[ "${choices[z]}" ]] && { echo "${options[z]}" >> $FULL40; msg="";  }
  done | tee > $FULL40 &&  sed -i 's/^[ \t]*//' $FULL40
  unset options
  unset choices
  i=1
  cat /root/hostlistcb.txt | sed '/^$/d' | uniq >> /root/hostlistcbtmp.txt && cat /root/hostlistcbtmp.txt > /root/hostlistcb.txt && rm -rf  /root/hostlistcbtmp.txt
  while IFS= read -r host
   do
    echo > /root/hostconfig$i.txt
    IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$host/$host.txt)"
    if [ -z "$IPADDR" ]; then
     echo "Variable empty" && clear
    else
     echo "IP Address: $IPADDR" >> /root/hostconfig$i.txt
    fi
    IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$host/$host.txt)"
    if [ -z "$IPPORT" ]; then
     echo "Variable empty" && clear
    else
     echo "SSH Port: $IPPORT" >> /root/hostconfig$i.txt
    fi
    ROOTU='root'
     echo "Root user: $ROOTU" >> /root/hostconfig$i.txt
    WWWDIR="$(sed -n '5p' /usr/lib/cssam/backup/hosts/$host/$host.txt)"
    if [ -z "$WWWDIR" ]; then
     echo "Variable empty" && clear
    else
     echo "Site directory: $WWWDIR" >> /root/hostconfig$i.txt
    fi
    SSLDIR="$(sed -n '6p' /usr/lib/cssam/backup/hosts/$host/$host.txt)"
    if [ -z "$SSLDIR" ]; then
     echo "Variable empty" && clear
    else
     echo "SSL directory: $SSLDIR" >> /root/hostconfig$i.txt
    fi
    SQLDIR="$(sed -n '7p' /usr/lib/cssam/backup/hosts/$host/$host.txt)"
    if [ -z "$SQLDIR" ]; then
     echo "Variable empty" && clear
    else
     echo "MySQL status: $SQLDIR" >> /root/hostconfig$i.txt
    fi
    i=$(($i+1))
    x=$(($i-1))
   done < /root/hostlistcb.txt
   host_list_
}
#
function backup_selected_ () {
HN=`hostname -s`
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
DN=cglms.com
RM=litan.shamir@cglms.com
SM=$HN@$DN
#
cat /root/backupmanual.txt | sed '/^$/d' >> /root/backupmanualtmp.txt && mv -f /root/backupmanualtmp.txt /root/backupmanual.txt
echo > /root/backupmanualip.txt
while IFS= read -r hosts
 do
  find /usr/lib/cssam/backup/hosts/ | grep "$hosts" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort | uniq > /root/backupmanualip.txt
 done < /root/backupmanual.txt
 cat /root/backupmanualip.txt | sed '/^$/d' >> /root/backupmanualiptmp.txt && mv -f /root/backupmanualiptmp.txt /root/backupmanualip.txt
 rm -rf /root/backupmanualiptmp.txt
#
function mail_done_ () {
 echo "Hi there Admin!" ;echo "" ;echo ""$HN" *"$sitestobckp"* Backup done" | sed -e 's/^[ \t]*//' | mail -s "***Backup done to "$sitestobckp" !!! "  -r " <$HN@$DN>" $RM
}
#
function mail_alert_ () {
  echo "Hi there Admin!" ; echo "" ;echo "Manual backup failed on "$IPL"!!! Exiting, Please Check!!!" | sed -e 's/^[ \t]*//' | mail -s "***No Backup on "$IPL" !!! "  -r " <$users@$DN>" $RM
 }
#
while IFS= read -r line
 do
  function Backup_Variables_ () {
   IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   ROOTU='root'
   WWWDIR="$(sed -n '5p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   SSLDIR="$(sed -n '6p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   SQLDIR="$(sed -n '7p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   LD="$(date +"Time-%H:%M:%S-Date-%d.%m.%Y")"
  }
  #
  Backup_Variables_
  #
  cat /root/backupmanual.txt | sed '/^$/d' >> /root/backupmanualtmp.txt && mv -f /root/backupmanualtmp.txt /root/backupmanual.txt
  sitestobckp=`cat /root/backupmanual.txt`
  rm -rf /root/backupmanualtmp.txt
  #
  if [ "$WWWDIR" != "" ]; then
   Backup_Variables_
    while IFS= read -r site
     do
      mkdir -p /usr/lib/cssam/backup/hosts/$line/WWW/TMP/$site
      mkdir -p /usr/lib/cssam/backup/hosts/$line/WWW/$site
      rsync -avzhe "ssh -p $IPPORT" root@$line:$WWWDIR/$site /usr/lib/cssam/backup/hosts/$line/WWW/TMP
      cd /usr/lib/cssam/backup/hosts/$line && tar --exclude 'exclude.txt' -cvzf /usr/lib/cssam/backup/hosts/"$line"/WWW/"$site"/"$site"_www_"${LD}".tar.gz /usr/lib/cssam/backup/hosts/$line/WWW/TMP/"$site";
      rm -rf /usr/lib/cssam/backup/hosts/$line/WWW/TMP
     done < /root/backupmanual.txt

     mkdir -p /usr/lib/cssam/backup/hosts/$line/SSL/TMP/
     rsync -avzhe ssh -p "$IPPORT"  root@$line:$SSLDIR /usr/lib/cssam/backup/hosts/$line/SSL/TMP/
     tar -cvzf /usr/lib/cssam/backup/hosts/$line/SSL/$line-ssl${LD}.tar.gz /usr/lib/cssam/backup/hosts/$line/SSL/TMP/;
     rm -rf /usr/lib/cssam/backup/hosts/$line/SSL/TMP/

     mkdir -p /usr/lib/cssam/backup/hosts/$line/HTTPD/TMP/
     rsync -avzhe ssh -p "$IPPORT"  root@$line:/etc/httpd/conf/ /usr/lib/cssam/backup/hosts/$line/HTTPD/TMP/
     tar -cvzf /usr/lib/cssam/backup/hosts/$line/HTTPD/$line-httpd${LD}.tar.gz /usr/lib/cssam/backup/hosts/$line/HTTPD/TMP/;
     rm -rf /usr/lib/cssam/backup/hosts/$line/HTTPD/TMP/
  fi
  if [ "$SQLDIR" != "" ]; then
   Backup_Variables_
   backupmysql_
   cp -f /etc/backupmysql.sh /etc/backupmysqlORG.sh
   sed -i "s/IPPORT/$IPPORT/g" /etc/backupmysql.sh
   sed -i "s/ROOTU/$ROOTU/g" /etc/backupmysql.sh
   sed -i "s/LINE/$IPADDR/g" /etc/backupmysql.sh
   sed -i "s/EEE/EOF/g" /etc/backupmysql.sh
   sed -i "s/EEEE/<<-"EOF"/g" /etc/backupmysql.sh
   chmod +x /etc/backupmysql.sh
   /./etc/backupmysql.sh
   rm -rf /etc/backupmysql.sh
   mv /etc/backupmysqlORG.sh /etc/backupmysql.sh
   rm -rf /etc/backupmysqlORG.sh
   mkdir -p /usr/lib/cssam/backup/hosts/$line/DB/
   rsync -avzhe ssh -p "$IPPORT" $ROOTU@$line:/root/DB/ /usr/lib/cssam/backup/hosts/$line/DB/
  fi
  #
 done < /root/backupmanualip.txt
mail_done_
}
#
function chk_df_mnt_space_ () {
CHK=`df -h | grep -o -P '.{0,3}%' | sed -n '1!p' | tr -d '%' | awk -F: '{if($1>90)print$1}' | wc -l`
if [ "$CHK" != 0 ]; then
 gl_ && mail_panic_ && exit 0
else
 echo ""
fi
}
#
function install_mailx_ () {
  MAILXCHK=`mail -e | echo $?`
  if [[ $MAILXCHK != 0 ]]; then
    yum -y install mailx
  fi
}
#
function exit_ () {
whoamiu=`whoami`
clear && echo -e "\n\n\t${menu}Thank you ${number}"$whoamiu" ${menu}for using backup software!!\n\tSee ya next time..${normal}" && sleep 4 && clear
exit 0
}
#
function host_list_ () {
clear && call_allert_title_ && logo_findme_backup_ && echo -e "\n\n"
CHKL12=`ls -la  ~/.ssh | grep connected_hosts | wc -l`
if [[ $CHKL12 != 0 ]]; then
 echo -e "\n\t\t\t${menu}     Connected hosts${normal}"
 border_ssh_connected_hosts_
else
 border_ssh_connected_hosts_
fi
chk_box_host_list_
}
#
 #*****************************#
 # Step 2:                     #
 # Run Script on remote host:  #
 # Connect to ip via ssh       #
 # Check disk space + alert    #
 # Check dir,httpd,sql   5,6   #
 # Check ssl             7     #
 # > /root/temp.txt            #
 # Disconnect ssh              #
 #*****************************#
#
function check_remote_ () {
ssh -p $SSHPORT $USRL@$SSHRIP 'bash -s' <<-"EOF"
rm -rf /root/configbckp.txt
rm -rf /root/wwwdirtmp.txt
rm -rf /root/dirsizelist.txt
rm -rf /root/wwwssltmp.txt
rm -rf /root/exclude.txt
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
#
echo `hostname -s` >> /root/configbckp.txt
function mail_exist_ () {
  MAILXCHK=`mail -e | echo $?`
  if [[ $MAILXCHK != 0 ]]; then
   yum -y install mailx
  fi
 }
#
function check_disk_space_ () {
 RM='litan.shamir@cglms.com'
 HN=`hostname -s`
 DN='cglms.com'
 CHK=`df -h | grep -o -P '.{0,3}%' | sed -n '1!p' | tr -d '%' | awk -F: '{if($1>90)print$1}' | wc -l`
 if [ "$CHK" != 0 ]; then
  { echo "Hi there !" ;echo "" ;echo ""$HN" *"$IPL"* have problem with disk space".;} | sed -e 's/^[ \t]*//' | mail -s "***On server "$HN" disk above '90%' full !!! "  -r " <$HN@$DN>" $RM }
  exit 0
 else
  echo ""
 fi
}
#
function chksql_ () {
  if [ -d /var/lib/mysql/ ]; then
   echo "MySQL exists" >> /root/configbckp.txt
  else
   echo -e "\n" >> /root/configbckp.txt
  fi
  }
#
function chkwww_ () {
  echo > /root/sitelist.txt
  checkdir="0"
  if [ -d "/etc/httpd/conf" ]; then
   checkdir=`grep 'Directory "/' /etc/httpd/conf/*.conf | wc -l`
  fi
  if [ "$checkdir" != "0" ]; then
   echo "WWW exists" >> /root/configbckp.txt
  else
   echo -e "\n" >> /root/configbckp.txt
  fi
  }
#
mail_exist_
check_disk_space_
chkwww_
chksql_
EOF

rsync_tmp_txt_
}
#
 #**************************************************#
 # Step 3:                                          #
 # rsync /root/temp.txt >> own ip dir, and check:   #
 # if sql exist; then                               #
 # Detected MySQL DB ->                             #
 # MySQL root                                   8   #
 # MySQL passwd                                 9   #
 # Check connectivity + alert                       #
 # > own ip dir                                     #
 # else                                             #
 # No sql detected                                  #
 #**************************************************#
#
function rsync_tmp_txt_ () {
  scp -P"$SSHPORT" root@$SSHRIP:/root/configbckp.txt /root/configbckptmp.txt
  scp -P"$SSHPORT" root@$SSHRIP:/root/exclude.txt /root/exclude.txt
  scp -P"$SSHPORT" root@$SSHRIP:/root/sitelist.txt /root/sitelist.txt
  cat /root/configbckptmp.txt >> /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
  cat /root/sitelist.txt >> /usr/lib/cssam/backup/hosts/$SSHRIP/sitelist.txt
  cat /root/exclude.txt >> /usr/lib/cssam/backup/hosts/$SSHRIP/exc$SSHRIP.txt
  check_www_exist_
  check_sql_exist_
}
#
function check_www_exist_ () {
  SITEXIST=`cat /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt | grep 'WWW exists' | wc -l`
  if [ $SITEXIST != "0" ]; then
   explorer_www_dir_
  else
   echo -e "\n\n\n\t\tNo Sites detected on "$IPADDR".. Checking for MySQL..." && sleep 5 && logo_p_good_ && start_menu_
  fi
}
#
function check_sql_exist_ () {
  SQLEXIST=`cat /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt | grep 'MySQL exists' | wc -l`
  if [ $SQLEXIST != "0" ]; then
   copy_remote_mysql_
  else
   echo -e "\n\n\n\t\tNo MySQL detected on "$IPADDR".. Added to backup!!" && sleep 5 && logo_p_good_ && start_menu_
  fi
}
#
function chk_root_exist_passwd_ () {
clear
call_allert_title_
logo_findme_backup_
local C1="$(printf "${menu}MySQL has been detected on host..\n\nEnter MySQL super user: ${normal}\n")"
local C2="$(printf "${menu}Enter MySQL passwd: ${normal}\n")"

while true;
 do
 read -e -p "$C1" usr



    # mysql -h $mysqlserverip -P 3306  -uwwwrobot -p
    read -s -p "$C2" passwd
    local x="$(mysql -h $SSHRIP -P 3306 -u$usr -p"$passwd" -N -e 'SELECT User,Host FROM mysql.user;' | grep "localhost" | wc -l)"
	clear
    echo
if [ $x == 0 ];
 then
 clear
    echo -e "${menu}You enter ${fgred}${blink}wrong ${normal}${menu}pasword for user${fgred}${blink} "$usr" ${normal}${menu}please enter again${normal}"
    sleep 2
  else
     echo "$usr" >> /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
     echo "$passwd" >> /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
     create_db_users_ && clear
     sed -i '8d' /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
     sed -i '9d' /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
  clear && echo -e "\n\n\n\t\t$SSHRIP has been added to backup!!" && sleep 5 && logo_p_good_ && sleep 5
  start_menu_

 fi
done

sleep 1
clear

}
#
function bckp_sql_ () {
mkdir -p /usr/lib/cssam/backup/hosts/$SSHRIP/DB
echo  Starting sql beckup ....
 LD2="$(date +"Date-%d.%m.%Y-%H:%M")"
  sleep 3
   mysql -uroot -pI_will_backup_you -N -e 'show databases;' |
    while read dbname;
     do
      cd /usr/lib/cssam/backup/hosts/$SSHRIP/DB && mysqldump -uroot -pI_will_backup_you --complete-insert --routines --triggers --single-transaction "$dbname" > "$dbname-$LD2".sql;
       rm -rf performance*.sql
        rm -rf mysql-*.sql
         done
          echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
           echo  MySQL backup finished. Going sleep
}
#
function reset_mariadb_root_p_ () {
pkill -9 mysqld
 pkill -9 mariadb
  sudo mysqld_safe --skip-grant-tables --skip-networking  >res 2>&1 &
   printf "Resetting password... hold on\n"
    sleep 7
     mysql mysql -e "UPDATE user SET Password=PASSWORD('I_will_backup_you') WHERE User='root' AND host='localhost';FLUSH PRIVILEGES;"
      systemctl stop mariadb
       clear
        pkill -9 mysqld
         pkill -9 mariadb
          clear
            sudo systemctl start mariadb
             echo 'Cleaning up...'
              sleep 3
               pkill -9 mysqld
                pkill -9 mariadb
                 systemctl stop mariadb
                  sudo systemctl start mariadb
                   sleep 3
                    bckp_sql_
}
#
function copy_remote_mysql_ () {
 echo "Stoping MySQL"
  systemctl stop mariadb
   rm -rf /var/lib/mysql/*
    rsync -avzhe "ssh -p $SSHPORT" --progress root@$SSHRIP:/var/lib/mysql/ /var/lib/mysql/
     chown -R mysql:mysql /var/lib/mysql/
      reset_mariadb_root_p_
}
#
function create_db_users_ () {
  mysqlusr="$(sed -n '8p' /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt)"
  mysqlpasswd="$(sed -n '9p' /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt)"
  mysqlbackupuser='newbckpuser'
  backuppasswd=""
mysql -h $SSHRIP -P 3306 -u$mysqlusr -p$mysqlpasswd -N <<MYSQL_SCRIPT
CREATE USER '$mysqlbackupuser'@'localhost' IDENTIFIED BY '$backuppasswd';
GRANT EVENT, LOCK TABLES, RELOAD, SELECT, SHOW VIEW, TRIGGER on *.* to '$mysqlbackupuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
  clear && echo -e "\n\n\n\t\t      ${menu}$mysqlbackupuser password set to blank${normal}"

  printf "\n\n\n\t\t     ${menu}Created new user $mysqlbackupuser with correct backup permissions${normal}${menu} ${normal}"
  sleep 5
  clear
  sed -i '8d' /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
  sed -i '9d' /usr/lib/cssam/backup/hosts/$SSHRIP/$SSHRIP.txt
 }
#
#@@@@@
#|^|^|@
#{ - }@
#  ~
#
 #******************#
 ##### EXPLORER #####
 #******************#
#
function delete_ () {
unset_banner_
#logo_lets_do_this_
 set -f
#Menu 0
if [ "$selector" == "0" ] ;
   then
           echo
		echo
		echo
		echo
          export DIR1=`echo "/${menu0_main[$counter]}" | awk '{print $1}'`
          local C1="$(printf "${menu}This ${fgred}$DIR1${menu} will be ${fgred}added to backup${menu}! Please confirm (y/n): ${normal}\n")"
	      read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	        echo "$DIR1" >> /root/huy1.txt
	       	echo
	        echo -e "${blink}Delete in progres ..... ${normal}"
	        sleep 1
			export  BANNER=`echo -e "Dear "$whoami", \nYou just remove ${fgred}$DIR1${fgred}${normal}"`
            menu0_
   else
	        menu0_
fi
fi
#Menu 1
if [ "$selector" == "1" ] ;
   then
         echo
		echo
		echo
		echo
        export DIR2=`echo "$DIR1/${menu0_main1[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This ${fgred}$DIR2${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR2
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR2 ${normal}"`
         menu0_ && break;
	else
	     menu0_ && break;
fi
fi
#Menu 2
if [ "$selector" == "2" ] ;
   then
         echo
		echo
		echo
		echo
        export DIR3=`echo "/${menu0_main2[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2${fgred}/$DIR3${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2/${fgred}$DIR3 ${normal}"`
         menu1_ && break;
	else
	     menu1_ && break;
fi
fi
#Menu 3
if [ "$selector" == "3" ] ;
   then
        echo
		echo
		echo
		echo
        export DIR4=`echo "/${menu0_main3[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3${fgred}$DIR4${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3${fgred}$DIR4${normal}"`
         menu2_ && break;
	else
	     menu2_ && break;
fi
fi
#Menu 4
if [ "$selector" == "4" ] ;
   then
 echo
		echo
		echo
		echo
        export DIR5=`echo "/${menu0_main4[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3$$DIR4${fgred}$DIR5${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4$DIR5
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3$DIR4${fgred}$DIR5${normal}"`
         menu3_ && break;
	else
	     menu3_ && break;
fi
fi

#Menu 5
if [ "$selector" == "5" ] ;
   then
 echo
		echo
		echo
		echo
        export DIR6=`echo "/${menu0_main5[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3$DIR4$DIR5${fgred}$DIR6${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3$DIR4$DIR5${fgred}$DIR6${normal}"`
         menu4_ && break;
	else
	     menu4_ && break;
fi
fi
#Menu 6
if [ "$selector" == "6" ] ;
   then
 echo
		echo
		echo
		echo
        export DIR7=`echo "/${menu0_main6[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6${fgred}$DIR7${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6${fgred}$DIR7${normal}"`
         menu5_ && break;
	else
	     menu5_ && break;
fi
fi

#Menu 6
if [ "$selector" == "7" ] ;
   then
 echo
		echo
		echo
		echo
        export DIR8=`echo "/${menu0_main7[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7${fgred}$DIR8${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7${fgred}$DIR8${normal}"`
         menu6_ && break;
	else
	     menu6_ && break;
fi
fi

#Menu 8
if [ "$selector" == "8" ] ;
   then
 echo
		echo
		echo
		echo
        export DIR9=`echo "/${menu0_main8[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8${fgred}$DIR9${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8${fgred}$DIR9${normal}"`
         menu7_ && break;
	else
	     menu7_ && break;
fi
fi

#Menu 9
if [ "$selector" == "9" ] ;
   then
 echo
		echo
		echo
		echo
        export DIR10=`echo "/${menu0_main9[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9${fgred}$DIR10${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9${fgred}$DIR10${normal}"`
         menu8_ && break;
	else
	     menu8_ && break;
fi
fi
#Menu 10
if [ "$selector" == "10" ] ;
   then
 echo
		echo
		echo
		echo
        export DIR11=`echo "/${menu0_main10[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10${fgred}$DIR11${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10${fgred}$DIR11${normal}"`
         menu9_ && break;
	else
	     menu9_ && break;
fi
fi
#Menu 11
if [ "$selector" == "11" ] ;
   then
 echo
		echo
		echo
		echo
        export DIR12=`echo "/${menu0_main11[$counter]}" | awk '{print $1}'`
        echo
        local C1="$(printf "${menu}This $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11${fgred}$DIR12${menu} will be ${fgred}deleted${menu}! Please confirm (y/n): ${normal}\n")"
	    read -e -p "$C1" choise2d
if [ "$choise2d" == "y" ] || [ "$choise2d" == "" ];
   then
	    rm -rf $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11$DIR12
		echo
	    echo -e "${blink}Delete in progres ..... ${normal}"
	    sleep 1
		export  BANNER=`echo -e "Dear "$whoami", You just remove ${green}$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11${fgred}$DIR12${normal}"`
         menu10_ && break;
	else
	     menu10_ && break;
fi
fi
}
#Next Dir 0
function menu0_dir1_ () {
local selector=0
     export DIR1=`echo "/${menu0_main[$counter]}" | awk '{print $1}'`
     export CURDIR1=`ls $lsopt  --full-time "$DIR1" |  sed 's/domain //g' |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
     menu1_
	 }
#
function menu0_1_dir1_ () {
local selector=0
echo

	#export CURDIR2=`ls $lsopt "$DIR1/$itemchoice1" -C -1` #<-----------------------------
	export CURDIR1=`ls $lsopt  --full-time "$itemchoice1"  |  sed 's/domain //g' |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR1=`echo "/$itemchoice1"`
	menu2_
	echo
}
#
function menu0_title_ () {
#check_editor_pref_
 nano_banner_
 vim_banner_
 vi_banner_
IFS=$'\n'
  set -f
 CAT=$GREP
#CURDIR=`ls $lsopt $PATH1 -C -1`
CURDIR=`ls $lsopt  --full-time $PATH1 |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`

clear
	printf "${menu}${menu1}------------------------------------------${normal}0${menu}${menu1}-------------------------------------${normal}\n"
#	echo -e  "${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}\n${number}*.${menu}Raplace pattern in file or DB ${menu}  [${number}O${menu}]${normal}       ${number}*.${menu}Back to Main Menu ${menu}      [${number}esc${menu}]${normal}     "
echo -e  "${number}1. ${menu}Add folder to Backup [${number}a${menu}] or [${number}1${menu}] "
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$du"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "\t===> :${green}$PATH1${normal}"
	echo
	echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	export CURLOCATION1=/
}
#
function menu0_file_check_ () {
export DIR1=`echo "/${menu0_main[$counter]}" | awk '{print $1}'`
 if [ -f "$DIR1" ]  ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file [${green}${menu0_main[$counter]}${normal}] ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu0_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1
else
menu0_
fi
menu0_
#To change-----
fi
}
#
function menu0_ () {
  variables_
check_editor_pref_
 local selector=0
 menu0_title_



declare -a menu0_main=("<--" $CURDIR)
counter=0
function draw_menu0_ () {
    local DMENU=0

     for i in "${menu0_main[@]}"; do

    if [[ ${menu0_main[$counter]} == $i ]];
	then
            tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0

    else
       echo -e "\t    ${normal}$i ${normal}"   ;

     fi

      done

}
export localitemname=${menu0_main[$counter]}
function clear_menu0_()
{
      for i in "${menu0_main[@]}";
	     do
	      tput cuu1 setaf 0;
	    done
	 tput ed setaf 0
}

function select_from_list_ () {

local selector=0
    draw_menu0_
     while read -sn 1  key;
    do

 if [[ "$key" == "" ]] ;
	then
	    #echo "Debug1 menu 0" && sleep 1
		#ls -L $DIR1 --color=auto --group-directories-first
        export DIR1=`echo "/${menu0_main[$counter]}/"  | awk '{print $1}'`
		 # echo "/$DIR1" && sleep 3
		# cd /$DIR1 && ls -lhaF
		 # sleep 6
menu0_file_check_
if [[ "$counter" == 0 ]];
   then
     menu0_
	 break;
fi
	menu0_dir1_
	break;
fi
    read -sn2 -t 0.0005 k1 2>/dev/null >&2; read -sN1 -t 0.0009 k2 2>/dev/null >&2; read -sn2 -t 0.0005 k3 2>/dev/null >&2
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
		"\e[?1000;1006;1015h") menu1_ ;;
		# call next menu with <> keys
		#left
		$'\e[D'|$'\e0D')   if [[ "$counter" == 0 ]];
                                           then
                                           menu0_
                                           fi
                                            ;; #menu12_      ;; #left  go back to main menu0_
		#right
	    $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										          # menu0_file_check_
                                            share_this_folder_         #menu0_
                                           fi
		                                   share_this_folder_    #  menu0_file_check_
					                           #  menu0_dir1_
										   ;; #right  go to menu1_
		0) custom_permission_ ;;
		L) disable-hiden_ && menu0_ ;;
		H) enable-hiden_ && menu0_ ;;
		# use delete key on keybord to delete selected item
		3|$'\e[3~') delete_  ;;
		v) cat_ ;;
        a) vi_ && menu0_ && menu0_	;;
		b) vim_ && menu0_	&& menu0_ ;;
		c) nano_ && menu0_ && menu0_ ;;
		1|d) create_dir_  ;;
		2|f) create_file_  ;;
		6|i) find_file_folder_ ;;
		v) cat_ ;;
		m|M) unset_banner_ && menu0_ ;;
        a) vi_ && menu0_	;;
		b) vim_ && menu0_	;;
		c) nano_ && menu0_ ;;
		k|K) clone_ ;;
		U|u) main_user_managment_samba_microsoft_ ;;
        O) find_and_replace_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		7|p) find_pattern_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # countersor down, next item
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main[@]}-1)) && ((counter++)) ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main[@]}-1));;
         # q, carriage return: quit
        x|q|'') exit_ ;;
    esac

    # Redraw menu
      clear_menu0_
      draw_menu0_
    done

}
select_from_list_
local selector=0
}
#Next Dir 1
function menu1_dir2_ () {
local selector=1
echo
     export DIR2=`echo "/${menu0_main1[$counter]}"  | awk '{print $1}'`
     export CURDIR2=`ls $lsopt  --full-time "$DIR1/$DIR2" |  sed 's/domain //g' |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`

	menu2_
	echo
}
#
function menu1_1_dir2_ () {
local selector=1
echo

	#export CURDIR2=`ls $lsopt "$DIR1/$itemchoice1" -C -1` #<-----------------------------
	export CURDIR2=`ls $lsopt  --full-time "$DIR1/$itemchoice1"  |  sed 's/domain //g' |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR2=`echo "/$itemchoice1"`
	menu2_
	echo
}
#
function menu1_title_ () {
 nano_banner_
 vim_banner_
 vi_banner_
    clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}1${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}$FIND${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "\t===> :${green} $DIR1/ ${normal}"
	#echo -e "$du"
	export CURLOCATION1=$DIR1/
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	    echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
}
#
function menu1_file_check_ () {
export DIR2=`echo "/${menu0_main1[$counter]}"  | awk '{print $1}'`
	if  [ -f "$DIR1/$DIR2" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file [${green}${menu0_main1[$counter]}${normal}] ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1/$DIR2 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read  -n 1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu1_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1/$DIR2
menu1_
else
menu1_
fi
menu1_
#To change-----
fi
}
#
function menu1_file1_check_ () {
unset choice


 ls -L $DIR1 --color=auto --group-directories-first  #<------
   printf "$ITEMS50"
	 read -e -p "$C1itemchoice" itemchoice1 #<------
	 #echo Huy1 && sleep 2
	if [ "$itemchoice1" == "" ] ;
	then
	#echo Huy2 && sleep 2
	menu0_
	elif  [ -f "$DIR1/$itemchoice1" ] ;  #<------
then
#echo Huy3 && sleep 2
clear
echo -e "\n\n${menu}Boss,\nThis is a file [${green}$itemchoice1${normal}${menu}] ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n" #<------
cat "$DIR1/$itemchoice1" | more   #<------
pause_file_check_
if [ "$choice" == "" ]; then
#echo Huy1 && sleep 2
menu1_
elif [ "$choice" == "e" ]; then
$EDITOR "$DIR1/$itemchoice1"  #<------
menu1_    #<------
fi
else
menu1_1_dir2_   #<------
fi
}
#
function menu1_ () {
clear
local selector=1
IFS=$'\n'
set -f
menu1_title_
declare -a menu0_main1=("<--" $CURDIR1)
counter=0
local n=100

function draw_menu1_ () {
 DIRCOUNT=`echo "$CURDIR1" | wc -l`
    for i in "${menu0_main1[@]}"; do
	if [ "$DIRCOUNT" -gt "$n" ];
		then
		menu1_file1_check_
		else

		if [[ ${menu0_main1[$counter]} == $i ]] ; then
		 tput setaf 2;
			   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0

    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		fi
		done
}
function clear_menu1_()  {
    for i in "${menu0_main1[@]}"; do
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
local selector=1
draw_menu1_
while read -sn 1  key;
do
if [[ "$key" == "" ]];
	then


menu1_file_check_
	back_to_root_

	menu1_dir2_
break;
fi
    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main1[@]}-1)) && ((counter++)) ;;

	    $'\e[D'|$'\e0D')  if [[ "$counter" == 0 ]];
                                           then
                                           menu0_
                                           fi
		                                    menu0_       ;; #left back to main menu
	       $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu1_file_check_
                                           menu1_
                                           fi
										   menu1_file_check_
										   menu1_dir2_ ;; #right  #<-----------------------------------------------------menu1_dir2_ go to menu menu2_
		3|$'\e[3~') delete_  ;;
		L) disable-hiden_ && menu0_ ;;
		H) enable-hiden_ && menu0_ ;;
		1|d) create_dir_  ;;
		2|f) create_file_  ;;
		6|i) find_file_folder_ ;;
		7|p) find_pattern_ ;;
		v) cat_ ;;
        a) vi_ && menu1_	;;
		b) vim_ && menu1_	;;
		c) nano_ && menu1_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		k|K) clone_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main1[@]}-1));;
         # q, carriage return: quit
        x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu1_
    draw_menu1_
done
}

local selector=1
select_from_list_

}
#Next Dir 2
function menu2_dir3_ () {
	echo
	export DIR3=`echo "/${menu0_main2[$counter]}" | awk '{print $1}'`
	export CURDIR3=`ls $lsopt  --full-time "$DIR1$DIR2/$DIR3"  | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total | column -t`
    echo
	menu3_
}
#
function menu2_2_dir3_ () {
local selector=2
echo
	#export CURDIR3=`ls $lsopt "$DIR1$DIR2/$itemchoice2" -C -1` #<-----------------------------
	export CURDIR3=`ls $lsopt  --full-time "$DIR1$DIR2/$itemchoice2" | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total | column -t`
	export DIR3=`echo "/$itemchoice2"`
	menu3_
	echo
}
#
function menu2_title_ {
 nano_banner_
 vim_banner_
 vi_banner_
clear && echo && clear
local selector=2
 clear
	printf "${menu}${menu1}---------------------------------------${normal}2${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "\t===> :${green}$DIR1$DIR2/${normal}"
	export CURLOCATION1=$DIR1$DIR2/
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	    echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
}
#
function menu_2_file2_check_ () {
unset choice
 cd $DIR1$DIR2 && ls --color=auto --group-directories-first  #<------
   printf "$ITEMS50"
	 read -e -p "$C1itemchoice" itemchoice2 #<------
	if [ "$itemchoice2" == "" ] ;  #<------
	then
	menu1_
	elif  [ -f "$DIR1$DIR2/$itemchoice2" ] ;  #<------
then
clear
echo -e "\n\n${menu}Boss,\nThis is a file ${green}$itemchoice2${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n" #<------
cat "$DIR1$DIR2/$itemchoice2" | more   #<------
pause_file_check_
if [ "$choice" == "" ]; then
menu2_
elif [ "$choice" == "e" ]; then
$EDITOR $DIR1$DIR2/$itemchoice2  #<------
menu2_    #<------
fi
else
menu2_2_dir3_   #<------
fi
}
#
function menu2_file_check_ () {
export DIR3=`echo "/${menu0_main2[$counter]}" | awk '{print $1}'`
	if  [ -f "$DIR1$DIR2/$DIR3" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main2[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2/$DIR3 | more

#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu2_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2/$DIR3
menu2_
else
menu2_
fi
menu2_
fi
#To change-----
}
#
function menu2_ () {
local selector=2
IFS=$'\n'
set -f
menu2_title_
declare -a menu0_main2=("<--" $CURDIR2)
counter=0
n=60
function draw_menu0_ () {  #<------
DIRCOUNT=`echo "$CURDIR2" | wc -l`
    for i in "${menu0_main2[@]}"; do  #<------
	if [ "$DIRCOUNT" -gt "$n" ];
		then
		menu_2_file2_check_   #<------
		else

		if [[ ${menu0_main2[$counter]} == $i ]] ; then #<------
		 tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		fi
		done
}

function clear_menu0_()  {
    for i in "${menu0_main2[@]}"; do
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}

function select_from_list_ () {
local selector=2
draw_menu0_

while read -sn 1  key;
do
if [[ "$key" == "" ]];
	then

menu2_file_check_

	back_to_root_
menu2_dir3_
fi
    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main2[@]}-1)) && ((counter++)) ;;
		3|$'\e[3~') delete_  ;;
	    $'\e[D'|$'\e0D')   if [[ "$counter" == 0 ]];
                                           then
                         ‏                  menu1_
                                           fi
										   menu1_      ;; #left back to previouse menu1_
	      $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu2_file_check_
                                           menu2_
                                           fi
										   menu2_file_check_
										   menu2_dir3_ ;; #right  #<-----------------------------------------------------menu2_dir3_  go to menu menu3_
		1|d) create_dir_  ;;
		L) disable-hiden_ && menu1_ ;;
		H) enable-hiden_ && menu1_ ;;
		2|f) create_file_  ;;
		6|i) find_file_folder_ ;;
		7|p) find_pattern_ ;;
		v) cat_ ;;
        a) vi_ && menu2_	;;
		b) vim_ && menu2_	;;
		c) nano_ && menu2_ ;;
          O) find_and_replace_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main2[@]}-1));;
         # q, carriage return: quit
        x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
done
}
select_from_list_
local selector=2

}
#Next Dir 3
function menu3_dir4_ () {
	echo
	 export DIR4=`echo "/${menu0_main3[$counter]}" | awk '{print $1}' `  #<-----------------------------
     export CURDIR4=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3/$DIR4"  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`

    echo
	menu4_
}
#
function menu3_3_dir4_ () {
local selector=3
echo
	#export CURDIR4=`ls $lsopt "$DIR1$DIR2$DIR3/$itemchoice3" -C -1` #<-----------------------------
	export CURDIR4=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3/$itemchoice3"  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR4=`echo "/$itemchoice3"`
	menu4_
	echo
}
#
function menu3_title_ {
local selector=3
 nano_banner_
 vim_banner_
 vi_banner_
clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}3${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green}$DIR1$DIR2$DIR3/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3/
}
#
function menu3_file_check_ () {
export DIR4=`echo "/${menu0_main3[$counter]}" | awk '{print $1}' `
		if  [ -f "$DIR1$DIR2$DIR3/$DIR4" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main3[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3/$DIR4 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu3_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3/$DIR4
menu3_
else
menu3_
fi
menu3_
#To change-----
fi
}
#
function menu_3_file3_check_ () {
unset choice
 cd $DIR1$DIR2$DIR3 && ls --color=auto --group-directories-first  #<------d
   printf "$ITEMS50"
	 read -e -p "$C1itemchoice" itemchoice3 #<------d
	if [ "$itemchoice3" == "" ] ;  #<------d
	then
	menu2_
	elif  [ -f "$DIR1$DIR2$DIR3/$itemchoice3" ] ;  #<------d
then
clear
echo -e "\n\n${menu}Boss,\nThis is a file ${green}$itemchoice3${number}${normal}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat "$DIR1$DIR2$DIR3/$itemchoice3" | more   #<------d
pause_file_check_
if [ "$choice" == "" ]; then
menu3_   #<------d
elif [ "$choice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3/$itemchoice3  #<------d
menu3_    #<------d
fi
else
menu3_3_dir4_   #<------d
fi
}
#
function menu3_ () {
IFS=$'\n'
set -f
local selector=3
menu3_title_
declare -a menu0_main3=("<--" $CURDIR3) #<-----------------------------
counter=0
function draw_menu0_ () {
DIRCOUNT=`echo "$CURDIR3" | wc -l` #<------d
    for i in "${menu0_main3[@]}"; do  #<------d
	if [ "$DIRCOUNT" -gt "$n" ];
		then
		menu_3_file3_check_   #<------d
		else

		if [[ ${menu0_main3[$counter]} == $i ]] ; then #<------d
		 tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		fi
		done
}
function clear_menu0_()  {
    for i in "${menu0_main3[@]}"; do
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
draw_menu0_
while read -sn 1  key;
do
    if [[ "$key" == "" ]];
	then

menu3_file_check_
	back_to_root_
	menu3_dir4_	#<-----------------------------------------------------menu3_dir4_  go to menu menu4_
	fi
    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
		3|$'\e[3~') delete_  ;;
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main3[@]}-1)) && ((counter++)) ;;
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
                                           menu2_
                                           fi
		                                    menu2_       ;; #left back to previouse menu2_
	       $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu3_file_check_
                                           menu3_
                                           fi
										   menu3_file_check_
										   menu3_dir4_   ;;  #<-----------------------------------------------------menu3_dir4_  go to menu menu4_
	    1|d) create_dir_  ;;
		L) disable-hiden_ && menu2_ ;;
		H) enable-hiden_ && menu2_ ;;
		2|f) create_file_  ;;
		6|i) find_file_folder_ ;;
		v) cat_ ;;
		 O) find_and_replace_ ;;
        a) vi_ && menu3_	;;
		b) vim_ && menu3_	;;
		c) nano_ && menu3_ ;;
		7|p) find_pattern_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main3[@]}-1));;
         # q, carriage return: quit
        x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
done
}
select_from_list_
local selector=3
}
#Next Dir 4
function menu4_dir5_ () {
	echo
	export DIR5=`echo "/${menu0_main4[$counter]}"  | awk '{print $1}' `
	export CURDIR5=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4/$DIR5"  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`

	echo
	menu5_  && break
}
#
function menu4_4_dir5_ () {
local selector=4
echo
	#export CURDIR5=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4/$itemchoice4" -C -1` #<-----------------------------
	export CURDIR5=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4/$itemchoice4"   |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR5=`echo "/$itemchoice4"`
	menu5_
	echo
}
#
function menu4_title_ {
local selector=4
 nano_banner_
 vim_banner_
 vi_banner_
clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}4${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4/
	}
#
function menu_4_file4_check_ () {
unset choice
 cd $DIR1$DIR2$DIR3$DIR4 && ls --color=auto --group-directories-first  #<------d
   printf "$ITEMS50"
	 read -e -p "$C1itemchoice" itemchoice4 #<------d
	if [ "$itemchoice4" == "" ] ;  #<------d
	then
	menu3_
	elif  [ -f "$DIR1$DIR2$DIR3$DIR4/$itemchoice4" ] ;  #<------d
then
clear
echo -e "\n\n${menu}Boss,\nThis is a file ${green}$itemchoice4${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n" #<------d
cat "$DIR1$DIR2$DIR3$DIR4/$itemchoice4" | more   #<------d
pause_file_check_
if [ "$choice" == "" ]; then
menu3_   #<------d
elif [ "$choice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4/$itemchoice4  #<------d
menu4_    #<------d
fi
else
menu4_4_dir5_   #<------d
fi
}
#
function menu4_file_check_ () {
export DIR5=`echo "/${menu0_main4[$counter]}"  | awk '{print $1}' `
		if  [ -f "$DIR1$DIR2$DIR3$DIR4/$DIR5" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main4[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4/$DIR5 | more
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu4_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4/$DIR5
menu4_
else
menu4_
fi
menu4_
#To change-----
fi

}
#
function menu4_ () {
local selector=4
menu4_title_
IFS=$'\n'
set -f
declare -a menu0_main4=("<--" $CURDIR4) #<-----------------------------
counter=0
function draw_menu0_ () {  #<------4
DIRCOUNT=`echo "$CURDIR4" | wc -l` #<------4
    for i in "${menu0_main4[@]}"; do  #<------4
	if [ "$DIRCOUNT" -gt "$n" ];
		then
		menu_4_file4_check_   #<------d
		else

		if [[ ${menu0_main4[$counter]} == $i ]] ; then #<------d
		 tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		fi
		done

}
function clear_menu0_()  {
    for i in "${menu0_main4[@]}"; do
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
selector=4
draw_menu0_
while read -sn 1  key;
do
    if [[ "$key" == "" ]];
	then

menu4_file_check_
	back_to_root_
	menu4_file_check_
	menu4_dir5_  #<-----------------------------------------------------menu3_dir4_  go to menu menu4_
	fi
    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
		3|$'\e[3~') delete_  ;;
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main4[@]}-1)) && ((counter++)) ;;
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
                                           menu3_
                                           fi
										   menu3_      ;; #left back to previouse menu1_
	    $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu4_file_check_
                                           menu4_
                                           fi
										   menu4_file_check_
										   menu4_dir5_  ;; #<------------------------menu3_dir4_  go to menu menu4_
		1|d) create_dir_  ;;
		2|f) create_file_  ;;
		L) disable-hiden_ && menu3_ ;;
		H) enable-hiden_ && menu3_ ;;
        6|i) find_file_folder_ ;;
		7|p) find_pattern_ ;;
		v) cat_ ;;
		O) find_and_replace_ ;;
		O) find_and_replace_ ;;
        a) vi_ && menu3_	;;
		b) vim_ && menu3_	;;
		c) nano_ && menu3_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main4[@]}-1));;
         # q, carriage return: quit
        x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
done
}
selector=4
select_from_list_
}
#Next Dir 5
function menu5_dir6_ () {
	echo
	export DIR6=`echo "/${menu0_main5[$counter]}"  | awk '{print $1}' `
	export CURDIR6=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5/$DIR6" | sed -r 's/^.+\///'  |  awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
    echo
	menu6_
}
#
function menu5_5_dir6_ () {
local selector=5
echo
	#export CURDIR6=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4$DIR5/$itemchoice5" -C -1` #<-----------------------------
	export CURDIR6=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5/$itemchoice5" | sed -r 's/^.+\///'  |  awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR6=`echo "/$itemchoice5"`
	menu6_
	echo
}
#
function menu5_title_ {
local selector=5
 nano_banner_
 vim_banner_
 vi_banner_

clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}5${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4$DIR5/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4$DIR5/
}
#
function menu_5_file5_check_ () {
unset choice
 cd $DIR1$DIR2$DIR3$DIR4$DIR5 && ls --color=auto --group-directories-first  #<------d
   printf "$ITEMS50"
	 read -e -p "$C1itemchoice" itemchoice5 #<------d
	if [ "$itemchoice5" == "" ] ;  #<------d
	then
	menu4_  #<------d
	elif  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5/$itemchoice5" ] ;  #<------d
then
clear
echo -e "\n\n${menu}Boss,\nThis is a file ${green}$itemchoice5${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n" #<------d
cat "$DIR1$DIR2$DIR3$DIR4$DIR5/$itemchoice5" | more   #<------d
pause_file_check_
if [ "$choice" == "" ]; then
menu5_   #<------d
elif [ "$choice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5/$itemchoice5  #<------d
menu5_    #<------d
fi
else
menu5_5_dir6_   #<------d
fi
}
#
function menu5_file_check_ () {
export DIR6=`echo "/${menu0_main5[$counter]}"  | awk '{print $1}' `
		if  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5/$DIR6" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main5[$counter]}${normal}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4$DIR5/$DIR6 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu5_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5/$DIR6
menu5_
else
menu5_
fi
menu5_
#To change-----

fi
}
#
function menu5_ () {
local selector=5
menu5_title_
IFS=$'\n'
set -f
declare -a menu0_main5=("<--" $CURDIR5) #<-----------------------------
counter=0
function draw_menu0_ () {
 menu5_title_  #<------d
DIRCOUNT=`echo "$CURDIR5" | wc -l` #<------d
    for i in "${menu0_main5[@]}"; do  #<------d
	if [ "$DIRCOUNT" -gt "$n" ];
		then
		menu_5_file5_check_   #<------
		else

		if [[ ${menu0_main5[$counter]} == $i ]] ; then #<------
		 tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		fi
		done
}
function clear_menu0_()  {
    for i in "${menu0_main5[@]}"; do #<-----------------------------
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
selector=5
draw_menu0_
while read -sn 1  key;
do # 1 char (not delimiter), silent
    # Check for enter/space
    if [[ "$key" == "" ]];
	then

menu5_file_check_
	back_to_root_
    menu5_dir6_ #<-----------------------------------------------------menu5_dir6_  go to menu menu0_
	fi

    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main5[@]}-1)) && ((counter++)) ;;
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
                                           menu4_
                                           fi
										   menu4_      ;; #left back to previouse menu4_
	   $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu5_file_check_
                                           menu5_
                                           fi
										   menu5_file_check_
										   menu5_dir6_   ;;#<-----------------------------------------------------menu3_dir4_  go to menu menu0_
		1|d) create_dir_  ;;
		2|f) create_file_  ;;
		L) disable-hiden_ && menu4_ ;;
		H) enable-hiden_ && menu4_ ;;
		6|i) find_file_folder_ ;;
		v) cat_ ;;
        a) vi_ && menu5_	;;
		b) vim_ && menu5_	;;
		c) nano_ && menu5_ ;;
		5|r) rename_ ;;
		 O) find_and_replace_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		7|p) find_pattern_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        3|$'\e[3~') delete_  ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main5[@]}-1));;
         # q, carriage return: quit
         x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
	#case_
done
}
selector=5
select_from_list_
}
#Next Dir 6
function menu6_dir7_ () {
	#Replase:
#1. menu6_dir7_ to next one menu7_dir8_
#2. menu0_main6 to menu0_main7
#3. CURDIR6 to CURDIR7
#4. DIR6 to DIR7
#5. menu5_ to menu6_
#6. "Current location 6 is: $DIR1$DIR2$DIR3$DIR4$DIR5/${menu0_main5[$counter]}"    to   echo -e "Current location 6 is: $DIR1$DIR2$DIR3$DIR4$DIR5/${menu0_main5[$counter]}"

	echo
    export DIR7=`echo "/${menu0_main6[$counter]}"  | awk '{print $1}' `
	export CURDIR7=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/$DIR7" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
    echo

	menu7_ && break
}
#
function menu6_6_dir7_ () {
local selector=6
echo
	#export CURDIR7=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/$itemchoice6" -C -1` #<-----------------------------
	export CURDIR7=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/$itemchoice6" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR7=`echo "/$itemchoice6"`
	menu7_
	echo
}
#
function menu6_title_ {
local selector=3
 nano_banner_
 vim_banner_
 vi_banner_
IFS=$'\n'
set -f
clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}6${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/
}
#
function menu6_file_check_ () {
 export DIR7=`echo "/${menu0_main6[$counter]}"  | awk '{print $1}' `
		if  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/$DIR7" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main6[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/$DIR7 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu6_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/$DIR7
menu6_
else
menu6_
fi
menu6_
#To change-----
fi
}
#
function menu6_ () {
local selector=6
menu6_title_
declare -a menu0_main6=("<--" $CURDIR6) #<-----------------------------
counter=0
function draw_menu0_ () {
local DMENU=0
    for i in "${menu0_main6[@]}"; do #<-----------------------------
        if [[ ${menu0_main6[$counter]} == $i ]]; then #<-----------------------------
            tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		done
}
function clear_menu0_()  {
    for i in "${menu0_main6[@]}"; do #<-----------------------------
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
local selector=6
draw_menu0_
while read -sn 1  key;
do # 1 char (not delimiter), silent
    # Check for enter/space
    if [[ "$key" == "" ]];
	then

menu6_file_check_
	back_to_root_
	#!!!Next must be  chenged to | menu7_dir8_
    menu6_dir7_  #<-----------------------------------------------------menu6_dir7_  go to menu menu0_
	fi

    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
		3|$'\e[3~') delete_  ;;
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main6[@]}-1)) && ((counter++)) ;;
		#!!!Next must be  chenged to |
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
                                           menu5_
                                           fi
										   menu5_     ;; #left back to previouse menu4_
	    $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu6_file_check_
                                           menu6_
                                           fi
										   menu6_file_check_
										   menu6_dir7_    ;;#<-----------------------------------------------------menu3_dir4_  go to menu menu0_
		1|d) create_dir_  ;;
		2|f) create_file_  ;;
		L) disable-hiden_ && menu5_ ;;
		H) enable-hiden_ && menu5_ ;;
        6|i) find_file_folder_ ;;
		v) cat_ ;;
        a) vi_ && menu6_	;;
		b) vim_ && menu6_	;;
		c) nano_ && menu6_ ;;
		7|p) find_pattern_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main6[@]}-1));;
         # q, carriage return: quit
         x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
	#case_
done
}
local selector=6
select_from_list_
}
#Next Dir 7
function menu7_dir8_ () {
	#Replase:
#1. menu7_dir7_ to next one menu7_dir8_
#2. menu0_main7_ to menu0_main8
#3. CURDIR6 to CURDIR7
#4. DIR6 to DIR7
#5. menu5_ to menu7_
#6. "Current location 6 is: $DIR1$DIR2$DIR3$DIR4$DIR5/${menu0_main5[$counter]}"    to   echo -e "Current location 6 is: $DIR1$DIR2$DIR3$DIR4$DIR5/${menu0_main5[$counter]}"

	echo
    export DIR8=`echo "/${menu0_main7[$counter]}"  | awk '{print $1}' `
	export CURDIR8=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7/$DIR8" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
    echo

	menu8_  && break
}
#
function menu7_7_dir8_ () {
local selector=7
echo
	#export CURDIR7=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/$itemchoice7" -C -1` #<-----------------------------
	export CURDIR8=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6/$itemchoice7" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR7=`echo "/$itemchoice7"`
	menu8_
	echo
}
#
function menu7_title_ {
local selector=7
 nano_banner_
 vim_banner_
 vi_banner_
IFS=$'\n'
set -f
clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}7${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7/
}
#
function menu7_file_check_ () {
 export DIR8=`echo "/${menu0_main7[$counter]}"  | awk '{print $1}' `
		if  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7/$DIR8" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main7[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7/$DIR8 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -n 1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu7_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7/$DIR8
menu7_
else
menu7_
fi
menu7_
#To change-----
fi
}
#
function menu7_ () {
local selector=7
menu7_title_
declare -a menu0_main7=("<--" $CURDIR7) #<-----------------------------
counter=0
function draw_menu0_ () {
local DMENU=0
    for i in "${menu0_main7[@]}"; do #<-----------------------------
        if [[ ${menu0_main7[$counter]} == $i ]]; then #<-----------------------------
            tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		done
}

function clear_menu0_()  {
    for i in "${menu0_main7[@]}"; do #<-----------------------------
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
local selector=7
draw_menu0_
while read -sn 1  key;
do # 1 char (not delimiter), silent
    # Check for enter/space
    if [[ "$key" == "" ]];
	then

menu7_file_check_
	back_to_root_
	#!!!Next must be  chenged to | menu7_dir8_
    menu7_dir8_  #<-----------------------------------------------------menu7_dir7_  go to menu menu0_
	fi

    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
		3|$'\e[3~') delete_  ;;
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main7[@]}-1)) && ((counter++)) ;;
		#!!!Next must be  chenged to |
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
                                           menu6_
                                           fi
										   menu6_       ;; #left back to previouse menu4_
	    $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu7_file_check_
                                           menu7_
                                           fi
										   menu7_file_check_
										   menu7_dir8_   ;;#<-----------------------------------------------------menu3_dir4_  go to menu menu0_
		1|d) create_dir_  ;;
		2|f) create_file_  ;;
		L) disable-hiden_ && menu6_ ;;
		H) enable-hiden_ && menu6_ ;;
		7|p) find_pattern_ ;;
        6|i) find_file_folder_ ;;
		v) cat_ ;;
        a) vi_ && menu7_	;;
		b) vim_ && menu7_	;;
		c) nano_ && menu7_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main7[@]}-1));;
         # q, carriage return: quit
        x|q|''|$'\e')echo "Aborted.${normal}" && exit;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
	#case_
done
}
local selector=7
select_from_list_
}
#Next Dir 8
function menu8_dir9_ () {

	echo
    export DIR9=`echo "/${menu0_main8[$counter]}"  | awk '{print $1}' `
	export CURDIR9=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8/$DIR9" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
    echo

	menu9_ && break
}
#
function menu8_8_dir9_ () {
local selector=8
echo
	#export CURDIR9=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7/$itemchoice8" -C -1` #<-----------------------------
	export CURDIR9=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7/$itemchoice8" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR9=`echo "/$itemchoice8"`
	menu9_
	echo
}
#
function menu8_title_ {
 nano_banner_
 vim_banner_
 vi_banner_
local selector=8
IFS=$'\n'
set -f
 clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}8${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8/
}
#
function menu8_file_check_ () {
export DIR9=`echo "/${menu0_main8[$counter]}"  | awk '{print $1}' `
		if  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8/$DIR9" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main8[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8/$DIR9 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu8_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8/$DIR9
menu8_
else
menu8_
fi
menu8_
#To change-----
fi
}
#
function menu8_ () {
local selector=8
menu8_title_
declare -a menu0_main8=("<--" $CURDIR8)
counter=0
function draw_menu0_ () {
local DMENU=0
    for i in "${menu0_main8[@]}"; do
        if [[ ${menu0_main8[$counter]} == $i ]]; then
            tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		done
}

function clear_menu0_()  {
local selector=8
    for i in "${menu0_main8[@]}"; do
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
local selector=8
draw_menu0_
while read -sn 1  key;
do # 1 char (not delimiter), silent
    # Check for enter/space
    if [[ "$key" == "" ]];
	then

menu8_file_check_
	back_to_root_
    menu8_dir9_
	fi

    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
		3|$'\e[3~') delete_  ;;
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main8[@]}-1)) && ((counter++)) ;;
		#!!!Next must be  chenged to |
		$'\e[D'|$'\e0D')  if [[ "$counter" == 0 ]];
                                           then
                                           menu7_
                                           fi
                                           menu7_										   ;; #left back to previouse menu4_
	    $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu8_file_check_
                                           menu8_
                                           fi
										   menu8_file_check_
										   menu8_dir9_    ;;#<-----------------------------------------------------menu3_dir4_  go to menu menu0_
	    1|d) create_dir_  ;;
		L) disable-hiden_ && menu7_ ;;
		H) enable-hiden_ && menu7_ ;;
		2|f) create_file_  ;;
		6|i) find_file_folder_ ;;
		7|p) find_pattern_ ;;
		v) cat_ ;;
        a) vi_ && menu8_	;;
		b) vim_ && menu8_	;;
		c) nano_ && menu8_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main8[@]}-1));;
         # q, carriage return: quit
         x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
	#case_
done
}
local selector=8
select_from_list_
}
#Next Dir 9
function menu9_dir10_ () {
	echo
    export DIR10=`echo "/${menu0_main9[$counter]}"  | awk '{print $1}' `
	export CURDIR10=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9/$DIR10" | sed -r 's/^.+\///'  |  awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
    echo

	menu10_ && break
}
#
function menu9_9_dir10_ () {
local selector=9
echo
	#export CURDIR10=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8/$itemchoice9" -C -1` #<-----------------------------
	export CURDIR10=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8/$itemchoice9" | sed -r 's/^.+\///'  |  awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR10=`echo "/$itemchoice9"`
	menu10_
	echo
}
#
function menu9_title_ {
local selector=9
IFS=$'\n'
set -f
 clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}9${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9/
}
#
function menu9_file_check_ () {
export DIR10=`echo "/${menu0_main9[$counter]}"  | awk '{print $1}' `
		if  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9/$DIR10" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main9[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9/$DIR10 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu9_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9/$DIR10
menu9_
else
menu9_
fi
menu9_
#To change-----
fi
}
#
function menu9_ () {
local selector=9
menu9_title_
IFS=$'\n'       # make newlines the only separator
set -f
declare -a menu0_main9=("<--" $CURDIR9) #<-----------------------------
counter=0
function draw_menu0_ () {
local DMENU=0
    for i in "${menu0_main9[@]}"; do #<-----------------------------
        if [[ ${menu0_main9[$counter]} == $i ]]; then #<-----------------------------
            tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		done
}

function clear_menu0_()  {
    for i in "${menu0_main9[@]}"; do #<-----------------------------
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
local selector=9
draw_menu0_
while read -sn 1  key;
do # 1 char (not delimiter), silent
    # Check for enter/space
    if [[ "$key" == "" ]];
	then

menu9_file_check_
	back_to_root_
	#!!!Next must be  chenged to | menu9_dir8_
    menu9_dir10_  #<-----------------------------------------------------menu9_dir7_  go to menu menu0_
	fi

    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
		3|$'\e[3~') delete_  ;;
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main9[@]}-1)) && ((counter++)) ;;
		#!!!Next must be  chenged to |
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
                                           menu8_
                                           fi
                                           menu8_    ;; #left back to previouse menu4_
	    $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu9_file_check_
                                           menu9_
                                           fi
										   menu9_file_check_
										   menu9_dir10_    ;;#<-----------------------------------------------------menu3_dir4_  go to menu menu0_
        1|d) create_dir_  ;;
		L) disable-hiden_ && menu8_ ;;
		H) enable-hiden_ && menu8_ ;;
		7|p) find_pattern_ ;;
		2|f) create_file_  ;;
        6|i) find_file_folder_ ;;
		v) cat_ ;;
        a) vi_ && menu9_	;;
		b) vim_ && menu9_	;;
		c) nano_ && menu9_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main9[@]}-1));;
         # q, carriage return: quit
        x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
	#case_
done
}
local selector=9
select_from_list_
}
#Next Dir 10
function menu10_dir11_ () {
	echo
    export DIR11=`echo "/${menu0_main10[$counter]}"  | awk '{print $1}' `
	export CURDIR11=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10/$DIR11" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
    echo

	menu11_ && break
}
#
function menu10_10_dir11_ () {
local selector=10
echo
export CURDIR11=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9/$itemchoice10" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	#export CURDIR11=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9/$itemchoice10" -C -1` #<-----------------------------
	export DIR11=`echo "/$itemchoice10"`
	menu11_
	echo
}
#
function menu10_title_ {
local selector=10
 nano_banner_
 vim_banner_
 vi_banner_
IFS=$'\n'
set -f
 clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}10${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10/
}
#
function menu10_file_check_ () {
export DIR11=`echo "/${menu0_main10[$counter]}"  | awk '{print $1}' `
		if  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10/$DIR11" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main10[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10/$DIR11 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu10_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10/$DIR11
menu10_
else
menu10_
fi
menu10_
#To change-----
fi
	}
#
function menu10_ () {
local selector=10
menu10_title_
declare -a menu0_main10=("<--" $CURDIR10)
counter=0
function draw_menu0_ () {
local DMENU=0
    for i in "${menu0_main10[@]}"; do
        if [[ ${menu0_main10[$counter]} == $i ]]; then
            tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		done
}

function clear_menu0_()  {
    for i in "${menu0_main10[@]}"; do
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
local selector=10
draw_menu0_
while read -sn 1  key;
do
    if [[ "$key" == "" ]];
	then


	menu10_file_check_
	back_to_root_
    menu10_dir11_
	fi
    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main10[@]}-1)) && ((counter++)) ;;
		#!!!Next must be  chenged to |
		3|$'\e[3~') delete_  ;;
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
                                           menu9_
                                           fi
                                           menu9_       ;; #left back to previouse menu4_
	    $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu10_file_check_
                                           menu10_
                                           fi
										   menu10_file_check_
										   menu10_dir11_    ;;#<-----------------------------------------------------menu3_dir4_  go to menu menu0_
        1|d) create_dir_  ;;
		2|f) create_file_  ;;
		L) disable-hiden_ && menu9_ ;;
		H) enable-hiden_ && menu9_ ;;
          6|i) find_file_folder_ ;;
		  7|p) find_pattern_ ;;
		v) cat_ ;;
        a) vi_ && menu10_	;;
		b) vim_ && menu10_	;;
		c) nano_ && menu10_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main10[@]}-1));;
         # q, carriage return: quit
         x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
	#case_
done
}
local selector=10
select_from_list_
}
#Next Dir 11
function menu11_dir12_ () {
	echo
    export DIR12=`echo "/${menu0_main11[$counter]}"  | awk '{print $1}' `
	export CURDIR12=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11/$DIR12" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
    echo

	menu12_
}
#
function menu11_11_dir12_ () {
local selector=11
echo
	#export CURDIR12=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10/$itemchoice11" -C -1` #<-----------------------------
	export CURDIR12=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10/$itemchoice11" | sed -r 's/^.+\///'  |  sed 's/domain //g' | awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR12=`echo "/$itemchoice11"`
	menu12_
	echo
}
#
function menu11_title_ {
local selector=11
 nano_banner_
 vim_banner_
 vi_banner_
IFS=$'\n'
set -f
 clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}11${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11/
}
#
function menu11_file_check_ () {
export DIR12=`echo "/${menu0_main11[$counter]}"  | awk '{print $1}' `
			if  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11/$DIR12" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main11[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11/$DIR12 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu11_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11/$DIR12
menu11_
else
menu11_
fi
menu11_
#To change-----
fi
}
#
function menu11_ () {
local selector=11
 menu11_title_
declare -a menu0_main11=("<--" $CURDIR11) #<-----------------------------
counter=0
function draw_menu0_ () {
local DMENU=0
    for i in "${menu0_main11[@]}"; do #<-----------------------------
        if [[ ${menu0_main11[$counter]} == $i ]]; then #<-----------------------------
            tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		done
}

function clear_menu0_()  {
    for i in "${menu0_main11[@]}"; do #<-----------------------------
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
local selector=11
draw_menu0_
while read -sn 1  key;
do # 1 char (not delimiter), silent
    # Check for enter/space
    if [[ "$key" == "" ]];
	then

menu11_file_check_
	back_to_root_
    menu11_dir12_  #<-----------------------------------------------------menu9_dir7_  go to menu menu0_
	fi

    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main11[@]}-1)) && ((counter++)) ;;
		#!!!Next must be  chenged to |
		3|$'\e[3~') delete_  ;;
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
										   menu11_file_check_
                                           menu11_
                                           fi
										   menu11_file_check_
                                           menu10_     ;; #left back to previouse menu4_
	    $'\e[C'|$'\e0C') menu11_dir12_ && break   ;;#<-----------------------------------------------------menu3_dir4_  go to menu menu0_
		1|d) create_dir_  ;;
		2|f) create_file_  ;;
		L) disable-hiden_ && menu10_ ;;
		H) enable-hiden_ && menu10_ ;;
		7|p) find_pattern_ ;;
		6|i) find_file_folder_ ;;
		v) cat_ ;;
        a) vi_ && menu11_	;;
		b) vim_ && menu11_	;;
		c) nano_ && menu11_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
        # home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main11[@]}-1));;
         # q, carriage return: quit
         x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
	#case_
done
}
local selector=11
select_from_list_
}
#Next Dir 12
function menu12_dir13_ () {
	#Replase:
#1. menu7_dir7_ to next one menu7_dir8_
#2. menu0_main7_ to menu0_main8
#3. CURDIR6 to CURDIR7
#4. DIR6 to DIR7
#5. menu5_ to menu7_
#6. "Current location 6 is: $DIR1$DIR2$DIR3$DIR4$DIR5/${menu0_main5[$counter]}"    to   echo -e "Current location 6 is: $DIR1$DIR2$DIR3$DIR4$DIR5/${menu0_main5[$counter]}"

	echo

    export DIR13=`echo "/${menu0_main12[$counter]}"  | awk '{print $1}' `
	export CURDIR13=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11$DIR12/$DIR13" | sed -r 's/^.+\///'  |  awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
    echo

	menu11_ && break
}
#
function menu12_12_dir13_ () {
local selector=12
echo
	#export CURDIR13=`ls $lsopt "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11/$itemchoice12" -C -1` #<-----------------------------
	export CURDIR13=`ls $lsopt  --full-time "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11/$itemchoice12" | sed -r 's/^.+\///'  |  awk '{print  $9, " | "  $6, " | " , $3, " | " $4, " | " $1, " | " }'  | grep -v total  | column -t`
	export DIR13=`echo "/$itemchoice12"`
	menu11_ && break
	echo
}
#
function menu12_title_ {
local selector=11
 nano_banner_
 vim_banner_
 vi_banner_
IFS=$'\n'
set -f
clear && echo && clear
	printf "${menu}${menu1}---------------------------------------${normal}12${menu}${menu1}----------------------------------------${normal}"
	echo -e  "\n${number}*.${menu}New dir   [${number}d${menu}] or [${number}1${menu}]                      ${number}*.${menu}Find file or dir [${number}i${menu}] or [${number}6${menu}]\n${number}*.${menu}New file  [${number}f${menu}] or [${number}2${menu}]                      ${number}*.${menu}Find pattern     [${number}p${menu}] or [${number}7${menu}]\n${number}*.${menu}Delete    [${number}delete${menu}] or [${number}3${menu}]${normal}                 ${number}*.${menu}Last file search [${number}v${menu}] or [${number}8${menu}]${normal}\n${number}*.${menu}Edit file [${number}e${menu}] or [${number}4${menu}]                      ${number}*.${menu}Hidden items  $HIDENONBAN ${menu}[${number}H${menu}] or [${number}L${menu}] $HIDENOFFBAN\n${number}*.${menu}Rename    [${number}r${menu}] or [${number}5${menu}]                      ${number}*.${menu}Find large size items   [${number}j${menu}] \n${number}*.${menu}Editor    [${number}a${menu}] ${normal}$VIB${menu} [${number}b${menu}] ${normal}$VIMB${menu} [${number}c${menu}] ${normal}$NANOB${menu}${normal}         ${number}*.${menu}Clone/Copy ${menu}             [${number}k${menu}]${normal}\n${number}*.${menu}Remove banner ${menu}   [${number}m${menu}]${normal}                      ${number}*.${menu}Set chown + chmod www ${menu}  [${number}P${menu}][${number}0${menu}]${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------${normal}"
    echo -e "\t===> :${green} $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11$DIR12/ ${normal}"
		echo -e "\t    Name      Size    Changed    User    Group     Rights "
	echo -e "\t   ------    ------  ---------  ------  -------   --------"
	echo
	export CURLOCATION1=$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11$DIR12/
}
#
function menu12_file_check_ () {
export DIR13=`echo "/${menu0_main12[$counter]}"  | awk '{print $1}' `
				if  [ -f "$DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11DIR12/$DIR13" ] ;
then
echo "file"
clear
echo -e "${menu}Boss,\nThis is a file ${green}${menu0_main12[$counter]}${normal}. ${menu}If you stuck press [${number}ctrl + c${menu}] ${normal}\n\n"
cat $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11DIR12/$DIR13 | more
#To change----
local ENT=`echo -e "\n\n${menu}Press [${number}Enter${menu}] to continue or [${number}e${menu}] to edit ....${normal}\n"`
read -s -n1 -p "$ENT " filechoice
if [ "$filechoice" == "" ]; then
menu12_
elif [ "$filechoice" == "e" ]; then
$EDITOR $DIR1$DIR2$DIR3$DIR4$DIR5$DIR6$DIR7$DIR8$DIR9$DIR10$DIR11DIR12/$DIR13
menu12_
else
menu12_
fi
menu12_
#To change-----
fi
}
#
function menu12_ () {
local selector=12
IFS=$'\n'
set -f
menu12_title_
declare -a menu0_main12=("<--" $CURDIR12) #<-----------------------------
counter=0
function draw_menu0_ () {
local DMENU=0
    for i in "${menu0_main12[@]}"; do
        if [[ ${menu0_main12[$counter]} == $i ]]; then
            tput setaf 2;
	   echo -e "\t===>${menu1}${green}$i${normal}"; tput sgr0
    else
       echo -e "\t    ${normal}$i ${normal}"   ;
        fi
		done
}

function clear_menu0_()  {
    for i in "${menu0_main12[@]}"; do
	tput cuu1 setaf 0;
	done
	tput ed setaf 0
}
function select_from_list_ () {
local selector=12
draw_menu0_
while read -sn 1  key;
do # 1 char (not delimiter), silent
    # Check for enter/space
    if [[ "$key" == "" ]];
	then

menu12_file_check_
	back_to_root_
    menu12_dir13_  #<-----------------------------------------------------menu9_dir7_  go to menu menu0_
	fi

    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}
    case "$key" in
        # countersor up, left: previous item
       $'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;
        # countersor down, right: next item
        $'\e[B'|$'\e0B') ((counter < ${#menu0_main12[@]}-1)) && ((counter++)) ;;
		#!!!Next must be  chenged to |
		$'\e[D'|$'\e0D') if [[ "$counter" == 0 ]];
                                           then
                                           menu11_
                                           fi
                                           menu11_      ;; #left back to previouse menu4_
	    $'\e[C'|$'\e0C')  if [[ "$counter" == 0 ]];
                                           then
										   menu12_file_check_
                                           menu12_
                                           fi
										   menu12_file_check_
										   menu12_dir13_   ;;#<-----------------------------------------------------menu3_dir4_  go to menu menu0_

		1|d) create_dir_  ;;
		2|f) create_file_  ;;
		L) disable-hiden_ && menu11_ ;;
		H) enable-hiden_ && menu11_ ;;
		7|p) find_pattern_ ;;
		6|i) find_file_folder_ ;;
		v) cat_ ;;
        a) vi_ && menu12_	;;
		b) vim_ && menu12_	;;
		c) nano_ && menu12_ ;;
		5|r) rename_ ;;
		P) permission_ ;;
		j) find_large_files_ ;;
		k|K) clone_ ;;
		$'\e') main_menu0_ ;;
		e) edit_file_ ;;
		# home: first item
        $'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        $'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main12[@]}-1));;
         # q, carriage return: quit
         x|q|'') exit_ ;;
    esac
    # Redraw menu
    clear_menu0_
    draw_menu0_
	#case_
done
}
local selector=12
select_from_list_
}
#
#*******************#
##### MAIN MENU #####
#*******************#
#
function start_menu_ () {
install_mailx_
IFS=$'\n'
set -f
export C660="$(printf "     \t${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
export C661="$(printf "     \t\t\t${bggrey}${black}${blink} ===>${normal}${menu}: ${normal}")"

SHOSTNAME=`hostname -s`
USRL=`whoami`
SSHKEY=`echo "$SHOSTNAME-$USRL"`
CHKL=`ls -la  ~/.ssh | grep id_rsa | wc -l`
if [[ $CHKL == 0 ]]; then
 mkdir -p ~/.ssh
 ssh-keygen -b 2048 -f ~/.ssh/id_rsa -P ""
else
 echo ""
fi

echo
echo -e "$CHKGALINST"
echo
local P1OPT1=`echo -e "\${number}          1. ${menu}Show connected Host-List${normal}\n"`
local P1OPT2=`echo -e "\${number}          2. ${menu}Add new Host to backup${normal}\n"`
local P1OPT3=`echo -e "\${number}          3. ${menu}Remove Host from backup${normal}"`
local P1OPT4=`echo -e "\${number}          4. ${menu}Manually run backup${normal}"`
local P1OPT5=`echo -e "\${number}          5. ${menu}Exit${normal}"`


declare -a menu0_main=($P1OPT1 $P1OPT2 $P1OPT3 $P1OPT4 $P1OPT5)
counter=0
function draw_menu0_ () {
clear && call_allert_title_ && logo_findme_backup_ && echo -e "\n\n"
for i in "${menu0_main[@]}";
 do if [[ ${menu0_main[$counter]} == $i ]];
     then
      tput setaf 2;
      echo -e "                ===>${menu1}${green}$i${normal}"; tput setaf 4
    else
      echo -e "                    $i";
    fi

 done
	}

function clear_menu0_()  {
for i in "${menu0_main[@]}"; do
 tput cuu1 setaf 0;
done
 tput ed setaf 0
}

# Draw initial Menu
function select_from_list_ () {
  clear && call_allert_title_ && logo_findme_backup_
draw_menu0_

while read -sn 1 key;

do # 1 char (not delimiter), silent
    # Check for enter/space
    clear && call_allert_title_ && logo_findme_backup_
    if [[ "$key" == "" ]];
	  then

#run comand on selected item
if [ "$counter" == 0 ];
then
cd /root && find . -name '*hostconfig*' -exec rm -rf {} \;
page="1"
all_hosts_
host_list_
elif [ "$counter" == 1 ];
then
add_new_server_to_bckp_
elif [ "$counter" == 2 ] ;
then
remove_ssh_host_
elif [ "$counter" == 3 ] ;
then
page="1"
all_sites_
chk_box_manual_backup_
elif [ "$counter" == 4 ] ;
then
exit_
fi
fi
    # catch multi-char special key sequences

    read -sn2 -t 0.0005 k1; read -sN1 -t 0.0009 k2; read -sn2 -t 0.0005 k3
    key+=${k1}${k2}${k3}

    case "$key" in

		  $'\e') main_menu0_ ;;
		  #left
		$'\e[D'|$'\e0D')   start_menu_ ;;
        # countersor up, left: previous item
        ""|i|j|$'\e[A'|$'\e0A') ((counter > 0)) && ((counter--))  ;;

        # countersor down, right: next item
        ""|k|l|$'\e[B'|$'\e0B'|$'\e[C'|$'\e0C') ((counter < ${#menu0_main[@]}-1)) && ((counter++)) ;;

        # home: first item
       ""|$'\e[1~'|$'\e0H'|$'\e[H')  counter=0;;
        # end: last item
        ""|$'\e[4~'|$'\e0F'|$'\e[F') ((counter=${#menu0_main[@]}-1));;

         # q, carriage return: quit
        #x|q|''|$'\e') color_ && exit_ ;;
		x|q) start_ ;;
    esac
    # Redraw menu

    clear_menu0_
    draw_menu0_
done


}
select_from_list_
#
}
#
#********************#
##### START HERE #####
#********************#
#
function start_here_ () {
variables_
start_menu_
}
#
start_here_                                    # (MENU G-0)  <=====<
#
#***************************#
##### END OF LOCAL MENU #####
#***************************#
#
#*****************#
##### THE END #####
#*****************#
