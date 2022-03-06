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
function backup_mysql_ () {
cat > /etc/backupmysql.sh <<-"EOF"
ssh -p IPPORT ROOTU@LINE 'bash -s' EEEE
HN=`hostname -s`
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"

function mail_panic_ () {
 { echo "Hi there Admin!" ; echo "" ;echo ""$IPL" *"$IPL"* tried to backup MySQL and have problem with disk space!!! Exiting, Please Check!!!" | sed -e 's/^[ \t]*//' | mail -s "***No Backup on "$IPL" !!! "  -r " <$HN@$DN>" $RM
 }

 mysqlsize=`du -hcs /var/lib/mysql | awk '{print $1}' | head -n 1`
 checkgiga=`echo $mysqlsize | grep 'G' | wc -l`
 if [ "$checkgiga" != "0" ]; then
  mysqlsize=`echo "${mysqlsize%?}"`
 fi

 diskspace=`df -h /root | awk '{print $4}' | tail -n 1`
 checkgigad=`echo $diskspace | grep 'G' | wc -l`
 if [ "$checkgigad" != "0" ]; then
  diskspace=`echo "${diskspace%?}"`
 fi

 if [ "$checkgiga" == "0" ] && [ "$checkgigad" != "0" ]; then
  echo "proceed"
 elif [ "$checkgigad" == "0" ]; then
  mail_panic_ && exit 0
 else
  gap=`expr $diskspace - $mysqlsize`
  if [ "$gap" > "0" ]; then
   echo "procceed"
  else
   mail_panic_ && exit 0
  fi
 fi

HN=`hostname -s`
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
RM='litan.shamir@cglms.com'
DN='cglms.com'
function bckp_sql_ () {
 echo "Backing up SQL.." && sleep 2 && clear
 mysql -unewbckpuser -N -e 'show databases;' |
 while read dbname;
  do
   mkdir -p /root/DB
   echo -e "Running sql backup on "$dbname".."
   mysqldump -unewbckpuser --complete-insert --routines --triggers --single-transaction "$dbname" > /root/DB/"$dbname-$LD".sql;
   rm -rf performance*.sql && rm -rf mysql-*.sql
  done
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
rm -rf /root/hostslisttmp.txt
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
   ROOTU="$(sed -n '3p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   WWWDIR="$(sed -n '5p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   SSLDIR="$(sed -n '6p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   SQLDIR="$(sed -n '7p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
  }
  #
  Backup_Variables_
  check_backup_done_
  #
  hostip="$line"
  function check_remote_disk_ () {
   IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$hostip/$hostip.txt)"
   IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$hostip/$hostip.txt)"
   ROOTU="$(sed -n '3p' /usr/lib/cssam/backup/hosts/$hostip/$hostip.txt)"
   rm -rf /etc/checkremotediskORG.sh
   cp -f /etc/checkremotedisk.sh /etc/checkremotediskORG.sh
   endoffile='<<-"EOF"'
   sed -i "s/EEE/EOF/g" /etc/checkremotedisk.sh
   sed -i "s/EEEE/$endoffile/g" /etc/checkremotedisk.sh
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
  hostip="$line"
  if [ "$WWWDIR" != "" ]; then
   mkdir -p /usr/lib/cssam/backup/hosts/$line/WWW/TMP/
   while IFS= read -r line
    do
     mkdir -p /usr/lib/cssam/backup/hosts/$hostip/WWW/TMP/$line
     mkdir -p /usr/lib/cssam/backup/hosts/$hostip/WWW/$line
     rsync -avzhe "ssh -p $IPPORT" root@$hostip:$WWWDIR/$line /usr/lib/cssam/backup/hosts/$hostip/WWW/TMP
     tar -cvzf /usr/lib/cssam/backup/hosts/$hostip/WWW/$line/$line_www${LD}.tar.gz /usr/lib/cssam/backup/hosts/$hostip/WWW/TMP/$line;
     rm -rf /usr/lib/cssam/backup/hosts/$hostip/WWW/TMP
    done < /usr/lib/cssam/backup/hosts/$line/sitelist.txt

   mkdir -p /usr/lib/cssam/backup/hosts/$hostip/SSL/TMP
   rsync -avzhe "ssh -p $IPPORT" root@$hostip:$SSLDIR /usr/lib/cssam/backup/hosts/$hostip/SSL/TMP
   tar -cvzf /usr/lib/cssam/backup/hosts/$hostip/SSL/$hostip_ssl${LD}.tar.gz /usr/lib/cssam/backup/hosts/$hostip/SSL/TMP;
   rm -rf /usr/lib/cssam/backup/hosts/$hostip/SSL/TMP

   mkdir -p /usr/lib/cssam/backup/hosts/$hostip/HTTPD/TMP
   rsync -avzhe "ssh -p $IPPORT" root@$hostip:/etc/httpd/conf /usr/lib/cssam/backup/hosts/$hostip/HTTPD/TMP
   tar -cvzf /usr/lib/cssam/backup/hosts/$hostip/HTTPD/$hostip_httpd${LD}.tar.gz /usr/lib/cssam/backup/hosts/$hostip/HTTPD/TMP;
   rm -rf /usr/lib/cssam/backup/hosts/$hostip/HTTPD/TMP
  fi
  #
  if [ "$SQLDIR" != "" ]; then
   rm -rf /etc/backupmysqlORG.sh
   IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$hostip/$hostip.txt)"
   IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$hostip/$hostip.txt)"
   ROOTU="$(sed -n '3p' /usr/lib/cssam/backup/hosts/$hostip/$hostip.txt)"
   endoffile='<<-"EOF"'
   cp -f /etc/backupmysql.sh /etc/backupmysqlORG.sh
   sed -e "s/IPPORT/$IPPORT/g" /etc/backupmysql.sh
   sed -e "s/ROOTU/$ROOTU/g" /etc/backupmysql.sh
   sed -e "s/LINE/$IPADDR/g" /etc/backupmysql.sh
   sed -i "s/EEE/EOF/g" /etc/backupmysql.sh
   sed -e "s/EEEE/$endoffile/g" /etc/backupmysql.sh
   chmod +x /etc/backupmysql.sh
   /./etc/backupmysql.sh
   rm -rf /etc/backupmysql.sh
   mv /etc/backupmysqlORG.sh /etc/backupmysql.sh
   rm -rf /etc/backupmysqlORG.sh
   mkdir -p /usr/lib/cssam/backup/hosts/$line/SQL
   rsync -avzhe "ssh -p $IPPORT" root@$hostip:/root/DB /usr/lib/cssam/backup/hosts/$hostip/SQL
  fi
  #
  function rm_old_bckp_ () {
   DELL=130
   DELLLESS=30
   CHK=`find /usr/lib/cssam/backup/hosts/$hostip/SQL/ -mtime +$DELLESS | wc -l` > /dev/null 2>&1 && clear
   if [ "$CHK" != "0" ]; then
    find /usr/lib/cssam/backup/hosts/$hostip/SQL/*.* -mtime +$DEL -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$hostip/WWW/*.*/*.* -mtime +$DEL -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$hostip/SSL/*.* -mtime +$DELLESS -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$hostip/HTTPD/*.* -mtime +$DELLESS -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$hostip/SSL/*.* -mtime +$DELLESS -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$hostip/HTTPD/*.* -mtime +$DELLESS -exec rm {} \;
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
install_service_                                                 # (SERVICE G-0)  <=====<
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
##### VARIABLES #####
#*******************#
#
function variables_ () {
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
#*************************#
##### SYSTEM OVERVIEW #####
#*************************#
#
function system_status_start_ () {
unset BANNERLOCKED
unset SSHPORTBAN
unset SELINUXBAN
unset FWBAN
unset IPTABLESBAN
unset FAIL2BAN
unset HTTPDBAN
unset TOMCATBAN
unset PHPBAN && unset MYSQLBAN && unset SYSTEMUSERSBAN
unset CENTOSBAN
unset DIRLOCATION
unset DOMAINBANN
chk_firewalld_
chk_selinux_
chk_iptables_
chk_fail2ban_
chk_ssh_port_
chk_httpd_port_
chk_php_v_
chk_mysql_
chk_sys_active_users_
chk_os_
	printf "\t\t  ${menu}         *****************Server Overview${menu}******************${normal}\n"
	#logo2_
	echo
	echo -e "\t\t   ${menu}        ${menu1}-----------------------${bgwhite}${menu}OS${menu}${menu1}-------------------------${normal}"
	echo -e "\t\t\t   ${green}                    $CENTOSBAN$UBUNTUBAN$SANGOMABAN${normal}"
	# echo -e "${menu}        ${menu1}--------------------------------------------------${normal}\n"
	echo -e "\t\t   ${menu}        ${menu1}----------------------${bgwhite}${menu}Date${menu}${menu1}------------------------${normal}"
	get_server_time_
	# echo -e "${menu}        ${menu1}--------------------------------------------------${normal}\n"
	echo -e "\t\t   ${menu}        ${menu1}--------------------${bgwhite}${menu}Security${menu}${menu1}----------------------${normal}"
	echo -e "\t\t\t   ${menu}$SSHPORTBAN$FWBAN$SELINUXBAN$IPTABLESBAN$FAIL2BAN${normal}"
	# echo -e "${menu}        ${menu1}--------------------------------------------------${normal}\n"
	echo -e "\t\t   ${menu}        ${menu1}---------------------${bgwhite}${menu}Serices${menu}${menu1}----------------------${normal}"
	echo -e "\t\t\t   ${menu}$SAMBABAN$HTTPDBAN$NGINXBAN$ASTERISBAN$PHPBAN$MYSQLBAN$POSTGRESBAN$MONGOBAN$TOMCATBAN ${normal}"
	# echo -e "${menu}        ${menu1}--------------------------------------------------${normal}\n"
	echo -e "\t\t   ${menu}        ${menu1}----------------------${bgwhite}${menu}Users${menu}${menu1}-----------------------${normal}"
	echo -e "${green}${number}\t\t\t   $SYSTEMUSERSBAN\n\t\t\t  $ROOTUSERSBAN \t\t   $CRONBANN     ${normal}"
	echo -e "\t\t   ${menu}        ${menu1}--------------------------------------------------${normal}\n"
	unset BANNER

}
#
current_server_time_centos_ () {
DATECHK=`date | awk '{print  $4, "  |  ", $3, "  |  ", $2,"  |  ", $6 }'`
CHKTIMEZONE=`ls -l /etc/localtime | grep -o -P '(?<=(/usr/share/zoneinfo/)).*(?=$)'`
longstr=`(echo -e "$DATECHK" | awk '{if(length>x){x=length;y=$0}}END{print y}')`
longlen=${#longstr}
edge=$(echo -e "$longstr" | sed 's/./-/g')
#echo -e "            Current Server Time   \n"

#echo -e "\t    ${green}     Time       Day      Month      Year   ${normal}"
echo -e "\t\t\t        +$edge---+${normal}"
while IFS= read -r line; do
 strlen=${#line}
 echo -e -n "\t\t\t        |${normal} ${green}$line${normal}"
 gap=$((longlen - strlen))
 if [ "$gap" > 0 ]; then
  for i in $(seq 1 $gap); do echo -n " "; done
  echo -e "  |${normal}"
 else
  echo -e "|${normal}"
 fi
done < <(printf '%s\n' "$DATECHK")
echo -e "\t\t\t        +$edge---+${normal}"
echo -e "\t\t\t              ${green}[Timezone: $CHKTIMEZONE${green}]${normal}"
}
#
get_server_time_ () {

if [ "$CENTOS" == 1 ]; then
    current_server_time_centos_
elif [ "$UBUNTU" == 1 ]; then
	current_server_time_ubuntu_
fi
}
#
chk_firewalld_ () {
#1 Checl firewall if up or down
if [ "$CENTOS" == 1 ];
  then
         UFWCHK=`systemctl status firewalld | grep -o "Active: active" | wc -l`

if [ "$UFWCHK" == 0 ];
    then
	return 0
        #FWBAN="${grey}[FIREWALL]${normal}"
      else
        FWBAN="${green}[FIREWALL]${normal}"
fi

elif [ "$UBUNTU" == 1 ];
    then
	     UFWCHK=`systemctl status ufw | grep -o "Active: active" | wc -l`
if [ "$UFWCHK" == 0 ];
     then
		FWBAN="${green}[${RED}${blink}FIREWALL OFF${normal}${green}]${normal}"
     else
        FWBAN="${green}[FIREWALL]${normal}"
fi

fi
}
#
chk_selinux_ () {
#1 Checl selinux if up or down
SESTATUS1=`ls  /etc/selinux | grep config | wc -l`


if [ "$SESTATUS1" != 0 ] ;
  then
  SESTATUS=`sestatus | grep -o disabled | wc -l`
  if [ "$SESTATUS" == 1 ];
  then
  return 0
    #SELINUXBAN="${grey}[SELINUX]${normal}"
      else

    SELINUXBAN="${green}[SELINUX]${normal}"
	fi
fi
}
#
chk_iptables_ () {
#1 Checl selinux if up or down
IPTABLESSTAT=`systemctl | grep iptables | wc -l`
if [ "$IPTABLESSTAT" != 0 ]  ;
  then
     IPTABLESSTAT1=`systemctl status iptables | grep -o "Active: active" | wc -l`
	 if [ "$IPTABLESSTAT1" == 1 ];
	 then
	 IPTABLESBAN="${green}[IPTABLES]${normal}"
    else
	IPTABLESBAN="${green}[${normal}${fgred}IPTABLES OFF${normal}${green}]${normal}"
	fi
     else
	 IPTABLESBAN="${green}[${normal}${fgred}IPTABLES OFF${normal}${green}]${normal}"
fi
}
#
chk_fail2ban_ () {
#1 Checl selinux if up or down
FAIL2BANSTAT=`systemctl | grep fail2ban | wc -l`
if [ "$FAIL2BANSTAT" != 0 ] ;
  then
  FAIL2BANSTAT1=`systemctl status fail2ban | grep -o "Active: active" | wc -l`
  if [ "$FAIL2BANSTAT1" == 1 ];
	 then
	 FAIL2BAN="${green}[FAIL2BAN-ON]${normal}"
    else
	return 0
	 #FAIL2BAN="${grey}[FAIL2BAN-OFF]${normal}"
	fi
     else
	 return 0
	 # FAIL2BAN="${grey}[FAIL2BAN-OFF]${normal}"
fi
  }
#
chk_ssh_port_ () {
#1 Checl selinux if up or down
SSHPORTCHK=`grep -e "^Port" /etc/ssh/sshd_config | wc -l`
SSHPORTCHK1=`grep -e "^Port" /etc/ssh/sshd_config`
if [ "$SSHPORTCHK" == 1 ] ;
  then
    SSHPORTBAN="${green}[SSH $SSHPORTCHK1]${normal}"
      else
    SSHPORTBAN="${green}[SSH Port 22]${normal}"
fi
}
#
chk_httpd_port_ () {
#1 Checl selinux if up or down
UBUNTUHTTPD=`pgrep -x apache2 | wc -l`
CENTOSHTTPD=`pgrep -x httpd | wc -l`
CHKNGINX=`pgrep -x nginx | wc -l`
CHKTOMCAT=`ps -ef | awk '/[t]omcat/{print $2}' | wc -l`
if [ "$UBUNTUHTTPD" != 0 ] || [ "$CENTOSHTTPD" != 0 ]  || [ "$CHKTOMCAT" != 0 ]  ;
  then
    HTTPDBAN="${green}[APACHE]${normal}"
	elif  [ "$CHKNGINX" != 0 ] ;
	 then
	  HTTPDBAN="${green}[NGINX]${normal}"
	  elif  [ "$CHKTOMCAT" != 0 ] ;
	 then
	  HTTPDBAN="${green}[TOMCAT]${normal}"
	 else
	 return 0
      #HTTPDBAN="${grey}[WEB-SRV]${normal}"
fi
}
#
chk_php_v_ () {
PHPCHK2=`ls /usr/bin | grep php | wc -l`
if [ "$PHPCHK2" != 0 ] ;
  then
  PHPCHK=`php -v | grep -Po '(?<=^PHP )[^ ]+'`
  PHPCHK1=`echo "PHP $PHPCHK"`
    PHPBAN="${green}[$PHPCHK1]${normal}"
      else
	  return 0
    #PHPBAN="${grey}[PHP]${normal}"
fi
}
#
chk_mysql_ () {
#1 Checl selinux if up or down
# MYSQLCHK=`ls /var/lib/mysql/ | wc -l`
# MYSQLCHK1=`systemctl status mariadb | grep -o "Active: active" | wc -l`
MYSQLCHK=`ps -ef | grep [m]ysql | wc -l`
if [ "$MYSQLCHK" != 0 ];
  then
    MYSQLBAN="${green}[MYSQL]${normal}"
      else
	  return 0
    #MYSQLBAN="${grey}[MYSQL]${normal}"
fi
}
#
chk_os_ () {
CENTOS=`awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o CentOS | wc -l`
if [ "$CENTOS" == 1 ];
  then
  CENTOS=1
    CENTOSBAN=`echo -e "[CentOS]"`
	elif [ "$SANGOMA" == 1 ] ;
      then
        CENTOS=1
        CENTOSBAN=`echo -e "[CentOS Sangoma FreePBX]"`

      else
    UBUNTU1=`awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o Ubuntu `
	UBUNTUBAN=`echo -e "[$UBUNTU1]"`
	fi
}
#
chk_sys_active_users_ () {
#1 Checl selinux if up or down
SYSUSERSCHK=`cat /etc/passwd | grep -v nologin | grep -v false | grep -v sync | awk -F':' '{ print $1 }' | wc -l`
SYSTEMUSERSBAN=`echo "${green}${fgred}$SYSUSERSCHK${green} Regular users${normal}"`
}
#
chk_time_ () {

 unset PERMISIONFOLDER
 local CHKTIME=`date +"%M"`
 local CHKTIME1=`curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g' | awk '{print  $5 }' | grep -o -P '(?<=(:)).*(?=:)'`
 if [ "$CHKTIME" != "$CHKTIME1" ];
 then
logo_stop_time_
sudo ntpdate -u 0.asia.pool.ntp.org
 tput reset

clear && echo && clear
 else
  tput reset

clear && echo && clear
 start_
fi
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
 cd /usr/lib/cssam/backup/hosts && ls -A > /root/hostlistview.txt
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
echo -e "                       ${menu1}+$edge---+${normal}"
while IFS= read -r line; do
 strlen=${#line}
 echo -e -n "                       ${menu1}|${normal} ${green}$line${normal}"
 gap=$((longlen - strlen))
 if [ "$gap" > 0 ]; then
  for i in $(seq 1 $gap); do echo -n " "; done
  echo -e "  ${menu1}|${normal}"
 else
  echo -e "  ${menu1}|${normal}"
 fi
done < <(printf '%s\n' "$HOSTSSSHCON")
echo -e "                       ${menu1}+$edge---+${normal}"
}
#
function remove_ssh_host_ () {
  echo -e "\n\t${menu}Please enter ip of host you want to remove${normal}"
  read -e -p "$C660" SSHRIPTOR
  if [[ $SSHRIPTOR = 'b' ]]; then
    start_menu_
  fi
  checkconhost=`cat ~/.ssh/connected_hosts | grep "$SSHRIPTOR" | wc -l`
  if [[ $checkconhost != 0 ]]; then
   sed -i "/$SSHRIPTOR/d" ~/.ssh/connected_hosts
  fi
  checkknohost=`cat ~/.ssh/known_hosts | grep "$SSHRIPTOR" | wc -l`
  if [[ $checkknohost != 0 ]]; then
   sed -i "/$SSHRIPTOR/d" ~/.ssh/known_hosts
  fi
  checkdir=`ls -A /usr/lib/cssam/backup/hosts | grep "$SSHRIPTOR"`
  if [[ $checkdir != 0 ]]; then
   rm -rf "/usr/lib/cssam/backup/hosts/$SSHRIPTOR"
  fi
  start_menu_
}
#
function add_new_server_to_bckp_ () {
  export C660="$(printf "\t${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
  install_mailx_
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
function all_sites_ () {
rm -rf /root/allsites.txt
while IFS= read -r line
 do
  if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
   cat /usr/lib/cssam/backup/hosts/$line/sitelist.txt >> /root/allsites.txt
  fi
 done < /root/hostlistview.txt
}
#
function chk_box_manual_backup_ () {
 unset options
 unset choices
 all_sites_
 clear && echo && clear
 FULL20=`cat /root/allsites.txt`
 declare -a options=($FULL20)
 menu_list_() {
 clear && call_allert_title_
 for z in ${!options[@]}; do
 printf "\n\t\t%3d%s) %s\t\t" $((i+1)) "${choices[z]:- }" "${options[z]}"
 done
 [[ "$msg" ]] && echo -e "\n\n\t\t$msg"; :
 }
 clear && call_allert_title_
 echo -e "\n\t\t\t\t\t   ${menu}${menu1}Manual Backup Menu${normal}\n"
 prompt=`echo -e "\n\n\t\t\t\t${menu}Select${normal} Site to Backup${menu}\n\t\t\t\tWhen done press [${number}Enter${menu}]${normal}\n\t\t\t\t${normal}"`
 while menu_list_ && read -n 1 -rp  "$prompt" num && [[ "$num" ]]; do
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
 [[ "${choices[z]}" ]] && { echo "${options[z]}" > $FULL14; msg="";  }
 done | tee > $FULL11 &&  sed -i 's/^[ \t]*//' $FULL11
 unset options
 unset choices
}
#
function backup_selected_ () {
HN=`hostname -s`
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
DN=cglms.com
RM=litan.shamir@cglms.com
SM=$HN@$DN
#
function mail_done_ () {
 echo "Hi there Admin!" ;echo "" ;echo ""$HN" *"$users"* Backup done" | sed -e 's/^[ \t]*//' | mail -s "***Backup done on "$users" !!! "  -r " <$HN@$DN>" $RM
}
#
function mail_alert_ () {
  echo "Hi there Admin!" ; echo "" ;echo ""$users" *"$users"* Did not backup!!! Exiting, Please Check!!!" | sed -e 's/^[ \t]*//' | mail -s "***No Backup on "$users" !!! "  -r " <$users@$DN>" $RM
 }
#
function check_backup_done_ () {
  YDATE=`date -d "yesterday" '+%d.%m.%Y'`
  CheckYwww=`ls -l /usr/lib/cssam/backup/hosts/$users/WWW/ | grep "$YDATE"`
  CheckYsql=`ls -l /usr/lib/cssam/backup/hosts/$users/SQL/ | grep "$YDATE"`
  if [ "$CheckYwww" == "0" ] && [ "$CheckYsql" == "0" ] && [ -f "/root/backupft.txt" ]; then
   mail_alert_ && sleep 20 && exit 0
  fi
   echo "first time" > /root/backupft.txt
  }
#
function Backup_Variables_ () {
  IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$users/$users.txt)"
  IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$users/$users.txt)"
  ROOTU="$(sed -n '3p' /usr/lib/cssam/backup/hosts/$users/$users.txt)"
  WWWDIR="$(sed -n '5p' /usr/lib/cssam/backup/hosts/$users/$users.txt)"
  SSLDIR="$(sed -n '6p' /usr/lib/cssam/backup/hosts/$users/$users.txt)"
  SQLDIR="$(sed -n '7p' /usr/lib/cssam/backup/hosts/$users/$users.txt)"
 }
#
Backup_Variables_
check_backup_done_
#
function check_remote_disk_ () {
  create_service_chkdisk_
  cp -f /etc/checkremotedisk.sh /etc/checkremotediskORG.sh
  endoffile='<<-"EOF"'
  sed -i "s/EEE/EOF/g" /etc/checkremotedisk.sh
  sed -i "s/EEEE/$endoffile/g" /etc/checkremotedisk.sh
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
function backupmysql_ () {
rm -rf /etc/backupmysql.sh
cat > /etc/backupmysql.sh <<-"EOF"
ssh -p IPPORT ROOTU@LINE 'bash -s' EEEE
HN=`hostname -s`
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
RM='litan.shamir@cglms.com'
DN='cglms.com'
function bckp_sql_ () {
 echo "Backing up SQL.." && sleep 2 && clear
 mysql -unewbckpuser -N -e 'show databases;' |
 while read dbname;
  do
   mkdir -p /root/DB
   echo -e "Running sql backup on "$dbname".."
   mysqldump -unewbckp --complete-insert --routines --triggers --single-transaction "$dbname" > /root/DB/"$dbname-$LD".sql;
   rm -rf performance*.sql && rm -rf mysql-*.sql
  done
EEE
EOF
}
#
if [ "$WWWDIR" != "" ]; then
  mkdir -p /usr/lib/cssam/backup/hosts/$users/WWW/TMP/
  rsync -avzhe ssh -p "$IPPORT" root@$users:$WWWDIR /usr/lib/cssam/backup/hosts/$users/WWW/TMP/
  tar -cvzf /usr/lib/cssam/backup/hosts/$users/WWW/$users-www${LD}.tar.gz /usr/lib/cssam/backup/hosts/$users/WWW/TMP/;
  rm -rf /usr/lib/cssam/backup/hosts/$users/WWW/TMP/

  mkdir -p /usr/lib/cssam/backup/hosts/$users/SSL/TMP/
  rsync -avzhe ssh -p "$IPPORT"  root@$users:$SSLDIR /usr/lib/cssam/backup/hosts/$users/SSL/TMP/
  tar -cvzf /usr/lib/cssam/backup/hosts/$users/SSL/$users-ssl${LD}.tar.gz /usr/lib/cssam/backup/hosts/$users/SSL/TMP/;
  rm -rf /usr/lib/cssam/backup/hosts/$users/SSL/TMP/

  mkdir -p /usr/lib/cssam/backup/hosts/$users/HTTPD/TMP/
  rsync -avzhe ssh -p "$IPPORT"  root@$users:/etc/httpd/conf/ /usr/lib/cssam/backup/hosts/$users/HTTPD/TMP/
  tar -cvzf /usr/lib/cssam/backup/hosts/$users/HTTPD/$users-httpd${LD}.tar.gz /usr/lib/cssam/backup/hosts/$users/HTTPD/TMP/;
  rm -rf /usr/lib/cssam/backup/hosts/$users/HTTPD/TMP/
fi
if [ "$SQLDIR" != "" ]; then
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
  mkdir -p /usr/lib/cssam/backup/hosts/$users/SQL
  rsync -avzhe ssh -p "$IPPORT" $ROOTU@$users:/root/DB/ /usr/lib/cssam/backup/hosts/$users/SQL/
fi
#
function rm_old_bckp_ () {
  DELL=130
  DELLLESS=30
  CHK=`find /usr/lib/cssam/backup/hosts/$users/SQL/ -mtime +$DEL | wc -l` > /dev/null 2>&1 && clear
  if [ "$CHK" != "0" ]; then
   if [ "$SQLDIR" != "" ]; then
    find /usr/lib/cssam/backup/hosts/$users/SQL/*.* -mtime +$DEL -exec rm {} \;
   fi
   if [ "$WWWDIR" != "" ]; then
    find /usr/lib/cssam/backup/hosts/$users/WWW/*.* -mtime +$DEL -exec rm {} \;
   fi
    find /usr/lib/cssam/backup/hosts/$users/SSL/*.* -mtime +$DELLESS -exec rm {} \;
    find /usr/lib/cssam/backup/hosts/$users/HTTPD/*.* -mtime +$DELLESS -exec rm {} \;
    exit 0
  else
   find /usr/lib/cssam/backup/hosts/$users/SSL/*.* -mtime +$DELLESS -exec rm {} \;  > /dev/null 2>&1 && clear
   find /usr/lib/cssam/backup/hosts/$users/HTTPD/*.* -mtime +$DELLESS -exec rm {} \;  > /dev/null 2>&1 && clear
   exit 0
  fi
 }
#
rm_old_bckp_
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
   find_site_dir_
   site_list_
   exclude_from_rsync_
   find_ssl_dir_
  else
   echo -e "\n" >> /root/configbckp.txt
  fi
  }
#
function site_list_ () {
  rm -rf /root/sitelist.txt
  rm -rf /root/sitelisttmp.txt
  cd $dirpath && ls -A > /root/sitelisttmp.txt
  while IFS= read -r line
   do
    if [[ $line != [0-9] ]]; then
      echo $line >> /root/sitelist.txt
    fi
   done < /root/sitelisttmp.txt
}
#
function comparison_site_ () {
i=1 && compare="ok"
lines=`wc -l /root/wwwdirtmp.txt | grep -o '^\S*'`
while IFS= read -r line
 do
  var[$i]=`echo $line | perl -p -e 's/^.*?#//' | awk -F# '{print $1}'`
  if [ "$i" == 1 ]; then
     i=$((i+1)) && x=$((i-1))
  elif [ "${var[$i]}" == "${var[$x]}" ] && [ "$i" != "$lines" ]; then
     export compare="ok"
     i=$((i+1)) && x=$((x+1))
  elif [ "$i" == "$lines" ] && [ "${var[$i]}" == "${var[$x]}" ]; then
     path=$path/${var[$i]}
  else
     export compare="bad"
  fi
 done < "/root/wwwdirtmp.txt"
}
#
function find_site_dir_ () {
 echo > /root/wwwdirtmp.txt
 grep 'Directory "/' /etc/httpd/conf/*.conf | grep -o '\/.*\"' | sed 's#/#\##g' | sed 's/.$//' > /root/wwwdirtmp.txt
 if [ -s /root/wwwdirtmp.txt ]; then
  echo ""
 fi
 compare="ok" && i=1 && path=""
 while [ -s /root/wwwdirtmp.txt ] && [ $compare == "ok" ];
  do
   comparison_site_
   dirpath="$path"
   cat /root/wwwdirtmp.txt | cut -d"#" -f3- | tr " " "\n" | sed 's/^/#/' | tr " " "\n" > /root/wwwtmp.txt && mv -f /root/wwwtmp.txt /root/wwwdirtmp.txt && rm -rf /root/wwwtmp.txt
  done
 echo "$dirpath" >> /root/configbckp.txt
}
function exclude_from_rsync_ () {
  cd "$dirpath" && du -hk * | awk '$1 > 1500000' | awk '{print $2}' > /root/dirsizelist.txt
  cat /root/dirsizelist.txt | sed 's#/#\##g' > /root/dirtemp.txt
  while read line;
   do
    chk=`cat /root/dirtemp.txt | grep "$line" | wc -l`
    if [ "$chk" -gt "1" ]; then
     sed -i -e "s/$line/###/g" /root/dirtemp.txt
     sed -i -e "s/####/$line#/g" /root/dirtemp.txt
     sed -i -e "s/###//g" /root/dirtemp.txt
    fi
   done < /root/dirtemp.txt
  cat /root/dirtemp.txt | sed '/^[[:space:]]*$/d' | sed "s/\#/\//g" > /root/exclude.txt
}
#
function comparison_ () {
i=1 && compare="ok"
lines=`wc -l /root/wwwssltmp.txt | grep -o '^\S*'`
while IFS= read -r line
 do
  var[$i]=`echo $line | perl -p -e 's/^.*?#//' | awk -F# '{print $1}'`
  if [ "$i" == 1 ]; then
     i=$((i+1)) && x=$((i-1))
  elif [ "${var[$i]}" == "${var[$x]}" ] && [ "$i" != "$lines" ]; then
     export comparessl="ok"
     i=$((i+1)) && x=$((x+1))
  elif [ "$i" == "$lines" ] && [ "${var[$i]}" == "${var[$x]}" ]; then
     sslpath=$sslpath/${var[$i]}
  else
     export comparessl="bad"
  fi
 done < "/root/wwwssltmp.txt"
}
#
function find_ssl_dir_ () {
  echo > /root/wwwssltmp.txt
  grep 'SSLCertificateFile ' /etc/httpd/conf/httpd.conf | sed 's#/#\##g' | sed 's/.$//' | awk '$1="";1' > /root/wwwssltmp.txt
  if [ -s /root/wwwssltmp.txt ]; then
   echo ""
  fi
  comparessl="ok" && i=1 && sslpath=""
  while [ -s /root/wwwssltmp.txt ] && [ $comparessl == "ok" ];
   do
    comparison_
    cat /root/wwwssltmp.txt | cut -d"#" -f3- | tr " " "\n" | sed 's/^/#/' | tr " " "\n" > /root/wwwtmpssl.txt && mv -f /root/wwwtmpssl.txt /root/wwwssltmp.txt && rm -rf /root/wwwtmpssl.txt
   done
  echo "$sslpath" >> /root/configbckp.txt
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
  check_sql_exist_
}
#
function check_sql_exist_ () {
  SQLEXIST=`cat /root/configbckptmp.txt | grep 'MySQL exists' | wc -l`
  if [ $SQLEXIST != "0" ]; then
   chk_root_exist_passwd_
  else
   echo -e "\n\n\n\t\tNo MySQL detected on "$IPADDR".. Added to backup!!" && sleep 5 && logo_p_good_ && start_menu_
  fi
  rm -rf /root/configbckptmp.txt
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
#*******************#
##### MAIN MENU #####
#*******************#
#
function start_menu_ () {
install_mailx_
IFS=$'\n'
set -f
export C660="$(printf "\t${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
export C661="$(printf "\t\t\t${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"

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
clear && call_allert_title_ && logo_findme_backup_ && border_ssh_connected_hosts_ && echo -e "\n\n"
CHKL12=`ls -la  ~/.ssh | grep connected_hosts | wc -l`
if [[ $CHKL12 != 0 ]]; then
 echo -e "\n\t\t\t${menu}     Connected hosts${normal}"
 border_ssh_connected_hosts_
else
 echo -e "\n\t\t\t${menu}No connected hosts${normal}"
fi

echo
echo -e "$CHKGALINST"
echo
local P1OPT1=`echo -e "\${number}1. ${menu}Add new Host to backup${normal}\n"`
local P1OPT2=`echo -e "\${number}3. ${menu}Remove Host from backup${normal}"`
local P1OPT3=`echo -e "\${number}3. ${menu}Manually Backup${normal}"`
local P1OPT4=`echo -e "\${number}4. ${menu}Exit${normal}"`


declare -a menu0_main=($P1OPT1 $P1OPT2 $P1OPT3 $P1OPT4)
counter=0
function draw_menu0_ () {
clear && call_allert_title_ && logo_findme_backup_ && border_ssh_connected_hosts_ && echo -e "\n\n"
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
  clear && call_allert_title_ && logo_findme_backup_ && border_ssh_connected_hosts_ && echo -e "\n\n"
draw_menu0_

while read -sn 1 key;

do # 1 char (not delimiter), silent
    # Check for enter/space
    clear && call_allert_title_ && logo_findme_backup_ && border_ssh_connected_hosts_ && echo -e "\n\n"
    if [[ "$key" == "" ]];
	  then

#run comand on selected item
if [ "$counter" == 0 ];
then
add_new_server_to_bckp_
elif [ "$counter" == 1 ] ;
then
remove_ssh_host_
elif [ "$counter" == 2 ] ;
then
chk_box_manual_backup_
elif [ "$counter" == 3 ] ;
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
start_here_                                  # (MENU G-0)  <=====<
#
#***************************#
##### END OF LOCAL MENU #####
#***************************#
#
#*****************#
##### THE END #####
#*****************#
# Tasks:
# CHKMAILX
