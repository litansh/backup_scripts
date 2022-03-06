#!/bin/bash
cat > /etc/sitesbackup.sh <<-"EOF"
#!/bin/bash
#!/bin/sh -
#**************************#
##### Prerequisitions ######
#**************************#
#                          #
# sites_directory=/var/www #
# ping_to_webdav           #
# mysql_backup_user=bckp   #
#                          #
#**************************#
#

EOF
#
#*******************#
##### Variables #####
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
##### Banners #####
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
                                         /,|`--._,-^|            ,
                                         \_| |`-._/||          ,'|
                                           |  `-, / |         /  /
                                           |     || |        /  /
                                            `r-._||/   __   /  /
                                        __,-<_     )`-/  `./  /
                                       '  \   `---'   \   /  /
                                      /    |           |./  /
                                      \    /  Backup   //  /
                                      \_/' \          |/  /
                                        |    |   _,^-'/  /
                                        |    , ``  (\/  /_
                                         \,.->._    \X-=/^
                                         (  /   `-._//^`
                                          `Y-.____(__}
                                           |     {__)
                                                  ()`
EOF
}
#
function call_allert_title_ () {
    clear && echo && clear
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}${menu1}                                          ${bgwhite}${menu}Database Backup${menu}${menu1}                                               ${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	unset TIMEMENUBANNER
}
#
function call_allert_title_restore_ () {
    clear && echo && clear
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}${menu1}                                        ${bgwhite}${menu}Restore Site Menu${menu}${menu1}                                               ${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	unset TIMEMENUBANNER
}
#
function logo_p_good_ () {
clear && clear && clear
cat << "EOF"
















                                 Packed up and good to GO Boss!!!
                                 -------------------------------------------
                                 \
                                  \
                                        .--.   ,||
                                       |o_o |  ({O'
                                       |:_/ |   /
                                      //   \ \ /
                                     (|     |
                                    /'\_   _/`\
                                    \___)=(___/
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
##### System Overview #####
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
#1 Checl selinux if up or down
SANGOMA=`awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o Sangoma | wc -l`
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
##### Alerts #####
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
function mail_no_webdav_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* is not connected to webdav". ;$E "Server Details:" ;$E "Local ip: "$IP"" ;$E "Public ip: $PIP" ;$E "Name: $HN" ; $E "Geo Location: $GL2" ; $E "" ; $E  "$DU1 " ; $E ""$TD"" ; $E "Exact time of event:" ; $E "$D" ; $E "Creating mount to WEBDAV" ; $E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***On server "$HN" no WEBDAV !!! "  -r " <$HN@$DN>" $RM
mount_webdav_
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
#******************#
##### CheckBox #####
#******************#
#
function chk_box_choose_site_ () {
clear && echo && clear
declare -a options=($FULL11)

menu_list_() {
for z in ${!options[@]}; do
printf "\n\t\t%3d%s) %s\t\t" $((i+1)) "${choices[z]:- }" "${options[z]}"
done
[[ "$msg" ]] && echo -e "\n\n\t\t$msg"; :
}
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
prompt=`echo -e "\n\n\t\t\t\t   ${menu}Select${normal} Sites from list to ${fgred}Restore${menu}\n\t\t\t\t   When done press [${number}Enter${menu}]${normal}"`
while menu_list_ && read -n 1 -rp  "$prompt" num && [[ "$num" ]]; do
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
[[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) ||
{
msg="Invalid option: $num"; continue
}
clear && echo && clear
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
local CHOICE=`echo -e "[${fgred}+${normal}]"`
((num--));
[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="$CHOICE"
done
clear && echo && clear
for z in ${!options[@]}; do
FULL12='/tmp/path/bckp/tmp.log'
[[ "${choices[z]}" ]] && { echo "${options[z]}" >>  $FULL12; msg="";  }
done | tee > $FULL11 &&  sed -i 's/^[ \t]*//' $FULL11
sed '1d' $FULL11 > tmpfile && mv -f tmpfile $FULL11
unset options
unset choices
}
#
function chk_box_choose_directory_ () {
clear && echo && clear
declare -a options=($FULL11)
menu_list_() {
for z in ${!options[@]}; do
printf "\n\t\t%3d%s) %s\t\t" $((i+1)) "${choices[z]:- }" "${options[z]}"
done
[[ "$msg" ]] && echo -e "\n\n\t\t$msg"; :
}
clear && echo && clear
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
prompt=`echo -e "\n\n\t\t\t\t${menu}Select${normal} Site Directory date to ${fgred}Restore${menu}\n\t\t\t\tWhen done press [${number}Enter${menu}]${normal}\n\t\t\t\t${fgred}***Only the last marked date will count!!!!${normal}"`
while menu_list_ && read -n 1 -rp  "$prompt" num && [[ "$num" ]]; do
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
[[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) ||
{
msg="Invalid option: $num"; continue
}
clear && echo && clear
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
local CHOICE=`echo -e "[${fgred}+${normal}]"`
((num--));
[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="$CHOICE"
done
clear && echo && clear
for z in ${!options[@]}; do
FULL14='/tmp/path/bckp/tmpdir.log'
[[ "${choices[z]}" ]] && { echo "${options[z]}" >  $FULL14; msg="";  }
done | tee > $FULL11 &&  sed -i 's/^[ \t]*//' $FULL11
unset options
unset choices
}
#
function chk_box_choose_sql_ () {
clear && echo && clear
declare -a options=($FULL11)
menu_list_() {
for z in ${!options[@]}; do
printf "\n\t\t%3d%s) %s\t\t" $((i+1)) "${choices[z]:- }" "${options[z]}"
done
[[ "$msg" ]] && echo -e "\n\n\t\t$msg"; :
}
clear && echo && clear
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
prompt=`echo -e "\n\n\t\t\t\t${menu}Select${normal} Site SQL database date to ${fgred}Restore${menu}\n\t\t\t\tWhen done press [${number}Enter${menu}]${normal}\n\t\t\t\t${fgred}***Only the last marked date will count!!!!${normal}"`
while menu_list_ && read -n 1 -rp  "$prompt" num && [[ "$num" ]]; do
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
[[ "$num" != *[![:digit:]]* ]] && (( num > 0 && num <= ${#options[@]} )) ||
{
msg="Invalid option: $num"; continue
}
clear && echo && clear
call_allert_title_restore_
echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
local CHOICE=`echo -e "[${fgred}+${normal}]"`
((num--));
[[ "${choices[num]}" ]] && choices[num]="" || choices[num]="$CHOICE"
done
clear && echo && clear
for z in ${!options[@]}; do
FULL15='/tmp/path/bckp/tmpsql.log'
[[ "${choices[z]}" ]] && { echo "${options[z]}" >  $FULL15; msg="";  }
done | tee > $FULL11 &&  sed -i 's/^[ \t]*//' $FULL11
unset options
unset choicess
}
#
#*************************#
##### Check functions #####
#*************************#
#
function install_mailx_ () {
if [[ $MAILXCHK == 0 ]]; then
  yum -y install mailx
fi
}
#
function chk_root_exist_passwd_ () {
TMP="/tmp/path/bckp/bckptmp.log"
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)"
sqllocal="$(find $pathtobp -type f -name "*.sql" | wc -l)"
if [ "$sqllocal" != "0" ]; then
while true;
 do
  clear && clear && clear
  call_allert_title_
  echo -e "\n\t\t\t    ${menu}${menu1}Database backup first time configuration${normal}\n"
  logo_findme_
  echo -e "\t\t\t\t${number}   Step 1${menu}: ${menu}Enter MySQL super user:${normal}"
  local C1="$(printf "\t\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
  read -e -p "$C1" usr
  clear && clear && clear
  call_allert_title_
  echo -e "\n\t\t\t    ${menu}${menu1}Database backup first time configuration${normal}\n"
  logo_findme_
  echo -e "\t\t\t${number}   Step 2${menu}: ${menu}Enter MySQL super user password:${normal}"
  local C2="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
  read -s -p "$C2" passwd
  local x="$(mysql -u$usr -p"$passwd" -N -e 'SELECT User,Host FROM mysql.user;' | grep localhost | wc -l)"
  clear
  echo
  if [ $x == 0 ]; then
   clear
   echo -e "\n\n\n\t\t\t${menu}You have entered ${fgred}${blink}wrong ${normal}${menu}pasword for user${fgred}${blink} "$usr" ${normal}${menu}please enter again${normal}"
   sleep 2
  else
   echo "$usr" >> $TMP
   echo "$passwd" >> $TMP
   return 0 && break
  fi
 done
else
	echo "No MySQL Onboard"
fi
sleep 1
clear
}
#
function comparison_ () {
i=1 && compare="ok"
lines=`wc -l /root/wwwdirtmp.txt | grep -o '^\S*`
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
 timer_
}
#
function find_ssl_dir_ () {
grep 'SSLCertificateFile ' /etc/httpd/conf/httpd.conf | sed 's#/#\##g' | sed 's/.$//' | awk '$1="";1' > /root/wwwdirtmp.txt
if [ -s /root/wwwdirtmp.txt ]; then
 echo ""
fi
compare="ok" && i=1 && path=""
while [ -s /root/wwwdirtmp.txt ] && [ $compare == "ok" ];
 do
  comparison_
  cat /root/wwwdirtmp.txt | cut -d"#" -f3- | tr " " "\n" | sed 's/^/#/' | tr " " "\n" > /root/wwwtmp.txt && mv -f /root/wwwtmp.txt /root/wwwdirtmp.txt && rm -rf /root/wwwtmp.txt
 done
sslpath="$path"
timer_
}
#
function mount_webdav_ () {                       ### Remove
CHCKDAV=`ls /usr/sbin | grep "dav" | wc -l`
if [ $CHCKDAV == "0" ]; then
 yum install davfs2 -y
fi
SRV=`hostname -s`
mkdir -p /var/webbckp/$SRV
CK=`sudo curl -u bckp:NewPass123$ --insecure https://192.168.21.21/webbckp/ --list-only | grep -oP 'href=\K.*?(?=/")' | cut -c 2- | sed '/^[[:space:]]*$/d' | grep $SRV | wc -l`
if [ $CK == "0" ]; then
 sudo curl -u bckp:NewPass123$ --insecure -X MKCOL "https://192.168.21.21/webbckp/$SRV" > /dev/null 2>&1 && clear
fi
echo -ne 'bckp\nNewPass123$\ny' |  sudo mount -t davfs -o noexec https://192.168.21.21/webbckp/$SRV/ /var/webbckp/$SRV > /dev/null 2>&1 && clear
echo '
# personal webdav
https://192.168.21.21/webbckp/$SRV/ /var/webbckp 0 0
' >> /etc/fstab && clear
check_webdav_mount_
timer_
}
#
function check_webdav_mount_ () {                    ### Remove
SRV=`hostname -s`
webdav=`df -hk | grep webbckp | awk '{print $6}'`
chkwd=`echo "$webdav" | grep "$SRV" | wc -l`
 if [ -z "$webdav" ]; then
  gl_ && mail_no_webdav_
 elif [ "$chkwd" == "0" ]; then
  mount_webdav_
  if [ -d /var/lib/mysql/ ]; then
   mkdir -p $webdav/sql
   SQL="$webdav/sql"
  fi
  if [ -d /var/www/ ]; then
   mkdir -p $webdav/www
   WWW="$webdav/www"
  fi
 fi
timer_
}
#
function chk_df_mnt_space_ () {
CHK=`df -h | grep -o -P '.{0,3}%' | sed -n '1!p' | tr -d '%' | awk -F: '{if($1>90)print$1}' | wc -l`
if [ "$CHK" != 0 ]; then
 gl_ && mail_panic_ && exit 0
else
 chkwww_ && chksql_ && rm_old_bckp_
 echo sleeping && sleep 30
 f_main
fi
timer_
}
#
function chksql_ () {
if [ -d /var/lib/mysql/ ]; then
 bckp_sql_
else
 return 0
fi
timer_
}
#
function chkwww_ () {
if [ -d /var/www/ ]; then
 bckp_www_
else
 return 0
fi
timer_
}
#
function rm_old_bckp_ () {                              ### Change to local
webdav=`df -hk | grep webbckp | awk '{print $6}'`
WWW="$webdav/www" && SQL="$webdav/sql" && SSL="$webdav/SSLtoWWW" && APACHE="$webdav/httpd"
CHK=`find $SQL -mtime +$DEL | wc -l` > /dev/null 2>&1 && clear
if [ "$CHK" != 0 ]; then
 if [ -d /var/lib/mysql/ ];then
  find $SQL/*.* -mtime +$DEL -exec rm {} \;
 fi
 if [ -d /var/www/ ];then
  find $WWW/*.* -mtime +$DEL -exec rm {} \;
 fi
 find $SSL/*.* -mtime +$DELLESS -exec rm {} \;
 find $APACHE/*.* -mtime +$DELLESS -exec rm {} \;
 gl_ && exit 0
else
 find $SSL/*.* -mtime +$DELLESS -exec rm {} \;  > /dev/null 2>&1 && clear
 find $APACHE/*.* -mtime +$DELLESS -exec rm {} \;  > /dev/null 2>&1 && clear
 gl_ && exit 0
fi
timer_
}
#
function exclude_from_tar_ () {                          ### Change to local
cd /var/www/ && du -hk * | awk '$1 > 1500000' | awk '{print $2}' > /root/dirsizelist.txt
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
timer_
}
#
function timer_ () {
chtime=`date +"%H"`
cmtime=`date +"%M"`
hgap=`expr $shtime - $chtime`
mgap=`expr $smtime - $cmtime`
if [ "$hgap" == "0" ] && [ "$mgap" > 30 ]; then
 mail_timeout_ && sleep 20 && exit 0
elif [ "$hgap" > 0 ] && [ "$mgap" > -45 ]; then
 mail_timeout_ && sleep 20 && exit 0
fi
}
#
function check_backup_done_ () {                            ### Change to local
YDATE=`date -d "yesterday" '+%d.%m.%Y'`
CheckYwww=`sudo curl -u bckp:NewPass123$ --insecure https://192.168.21.21/webbckp/$SRV/www/ --list-only | grep "$YDATE"`
CheckYsql=`sudo curl -u bckp:NewPass123$ --insecure https://192.168.21.21/webbckp/$SRV/sql/ --list-only | grep "$YDATE"`
if [ "$CheckYwww" == "0" ] && [ "$CheckYsql" == "0" ] && [ -f "/root/backupft.txt" ]; then
 mail_alert_ && sleep 20 && exit 0
fi
echo "first time" > /root/backupft.txt
}
#
#*************#
##### SSH #####
#*************#
#
function border_ssh_connected_hosts_galera_ () {
HOSTSSSHCON=`cat ~/.ssh/connected_hosts | sed '/^$/d' | awk '!_[$0]++'`
longstr=`(echo "$HOSTSSSHCON" | awk '{if(length>x){x=length;y=$0}}END{print y}')`
longlen=${#longstr}
edge=$(echo "$longstr" | sed 's/./-/g')
echo -e "\t             ${menu1}+$edge---+${normal}"
while IFS= read -r line; do
 strlen=${#line}
 echo -e -n "\t             ${menu1}|${normal} ${green}$line${normal}"
 gap=$((longlen - strlen))
 if [ "$gap" > 0 ]; then
  for i in $(seq 1 $gap); do echo -n " "; done
  echo -e "  ${menu1}|${normal}"
 else
  echo -e "  ${menu1}|${normal}"
 fi
done < <(printf '%s\n' "$HOSTSSSHCON")
echo -e "\t             ${menu1}+$edge---+${normal}"
}
# Menu "Remove Host"
 function remove_ssh_host_ () {
  ssh_title_
  logo_findme_galera_
  border_ssh_connected_hosts_galera_
  echo -e "\n\t${menu}Please enter ip of host you want to remove${normal}"
  read -e -p "$C660" SSHRIPTOR
  sed -i "/$SSHRIPTOR/d" ~/.ssh/connected_hosts
  sed -i "/$SSHRIPTOR/d" ~/.ssh/known_hosts
  ssh_title_
  logo_findme_galera_
  border_ssh_connected_hosts_galera_
  start_menu_
}
# Menu "Connect new Host"
function connect_new_ssh_host_ () {
  ssh_title_
  logo_findme_galera_
  echo -e "\n\t${menu}Please enter ip of host you want to connect${normal}"
  read -e -p "$C660" SSHRIP
  echo -e "\n\t${menu}Please enter SSH port${normal}"
  read -e -p "$C660" SSHPORT
  ssh-copy-id -o StrictHostKeyChecking=no -p "$SSHPORT" $USRL@$SSHRIP

  ssh_title_
  logo_findme_galera_
  echo -e "\n\t\t\t${menu}Connect to remote host${normal}"
  echo -e "\n\t\t ssh -p "$SSHPORT" "$USRL@$SSHRIP""
  echo -e "ssh -p "$SSHPORT" "$USRL@$SSHRIP"" | tee >> ~/.ssh/connected_hosts
  #cat ~/.ssh/connected_hosts
  pause_witout_exit_
  start_menu_
clear && echo && clear
}
#
function run_sh_script_on_remote_host_ () {
ssh -p 11255 root@192.168.77.99  'bash -s' < /usr/lib/cssam/galeramon/galeramonR1.sh
}
#
#**************************#
##### Backup functions #####
#**************************#
#
function bckp_www_ () {                            ### Change to local + rsync and tar
webdav=`df -hk | grep webbckp | awk '{print $6}'`
WWW="$webdav/www"
echo > /root/exclude.txt
exclude_from_tar_
clear && echo "Backing up Sites directories.." && sleep 2 && clear
cd /var/www && ls -d -- * | while read dir ;
 do
  clear && echo -e "Backing up "$dir".." && sleep 2 && clear
  echo $dir && tar -cvzf $WWW/$dir-${LD}.tar.gz $dir --exclude="/root/exclude.txt";
 done
mkdir -p $webdav/httpd
tar -cvzf $webdav/httpd/httpd-${LD}.tar.gz /etc/httpd/;
find_ssl_dir_
if [ -z "$sslpath" ]; then
 echo ""
else
 mkdir -p $webdav/SSLtoWWW
 tar -cvzf $webdav/SSLtoWWW/SSLtoWWW-${LD}.tar.gz $path/;
fi
timer_
}
#
function bckp_sql_ () {                               ###  rsync and remove
webdav=`df -hk | grep webbckp | awk '{print $6}'`
SQL="$webdav/sql"
echo "Backing up SQL.." && sleep 2 && clear
cd $SQL && mysql -ubckp -N -e 'show databases;' |
while read dbname;
 do
  echo -e "Running sql backup on "$dbname".."
  mysqldump -ubckp --complete-insert --routines --triggers --single-transaction "$dbname" > $SQL/"$dbname-$LD".sql;
  rm -rf performance*.sql && rm -rf mysql-*.sql
 done
timer_
}
#
function startsql_on_remote_ () {
ssh -p SSHPORT root@SSHRIP 'bash -s' << EOF
sed -i 's/safe_to_bootstrap: 0/safe_to_bootstrap: 1/g' /var/lib/mysql/grastate.dat
sed -i 's+wsrep_cluster_address="gcomm://192+#wsrep_cluster_address="gcomm://192+g' /etc/my.cnf.d/galera.cnf
sed -i 's+#wsrep_cluster_address="gcomm://"+wsrep_cluster_address="gcomm://"+g' /etc/my.cnf.d/galera.cnf
systemctl restart mariadb
EOF
}
#
#**************#
##### MAIN #####           (G-0)  <=====<
#**************#
#
f_main () {
check_backup_done_
check_webdav_mount_
if [ -d /var/lib/mysql/ ] || [ -d /var/www/ ]; then
 echo "Backup service is starting ..... Hold on!"
 sleep 3 && chk_df_mnt_space_ && return 0
fi
}
#
function add_new_server_to_bckp_ () {
  export C660="$(printf "\t${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
  install_mailx_
  ssh_title_
  logo_findme_galera_
  echo -e "\n\t${menu}Enter Node1 IP address${normal}"
  read -e -p "$C660" SSHRIP
  echo -e "\n\t${menu}Enter Node1 SSH port${normal}"
  read -e -p "$C660" SSHPORT
  echo -e "\n\t${menu}Enter admin mail like [admin@domain.com]${normal}"
  read -e -p "$C660" ADMINMAILGALERA
  echo -e "\n\t${menu}Domain to send from like [domain.com]${normal}"
  read -e -p "$C660" DOMAINGALERA

  #--------------------
  ssh-copy-id -o StrictHostKeyChecking=no -p "$SSHPORT" $USRL@$SSHRIP #Automaticaly connect server to ssh
  #-------------------
  install_galera_fixer_
  ssh_title_
  logo_findme_galera_
  echo -e "\n\t\t\t${menu}Connected to remote host $SSHRIP${normal}"

  #cat ~/.ssh/connected_hosts
  pause_witout_exit_
  start_menu_
clear && echo && clear
}
#
#********************#
##### Start here #####
#********************#
#
variables_
f_main
#
#*************#
##### EOS #####
#*************#
#
EOF
#
#*****************#
##### SERVICE #####
#*****************#
#
SERCHK=`systemctl list-units --full -all | grep "sitesbackup.service" | wc -l`
if [ $SERCHK == "0" ]; then
cat > /etc/systemd/system/sitesbackup.service <<- "EOF"
[Unit]
Description=Radmon service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=43200
ExecStart=/bin/sh -c "/etc/sitesbackup.sh"
StandardOutput=null
StandardError=inherit

[Install]
WantedBy=multi-user.target
EOF

chmod +x /etc/systemd/system/sitesbackup.service
systemctl start sitesbackup
systemctl enable sitesbackup
systemctl restart sitesbackup
systemctl daemon-reload
fi
#
rm -rf /usr/lib/cssam/backup/hosts/$BCKPHOSTIP

BCKPHOSTIP='192.168.77.5'
BCKPHOSTPORT=2356
MYSQLUSER=usertest
MYSQLP=Newpass123
mkdir -p /usr/lib/cssam/backup/hosts
touch /usr/lib/cssam/backup/hosts/$BCKPHOSTIP
echo "$BCKPHOSTIP" >> /usr/lib/cssam/backup/hosts/$BCKPHOSTIP
echo "$BCKPHOSTPORT" >> /usr/lib/cssam/backup/hosts/$BCKPHOSTIP
echo "$MYSQLUSER" >> /usr/lib/cssam/backup/hosts/$BCKPHOSTIP
echo "$MYSQLP" >> /usr/lib/cssam/backup/hosts/$BCKPHOSTIP

systemctl restart sitesbackup  > /dev/null 2>&1 && clear
chmod +x /etc/sitesbackup.sh
sudo /etc/sitesbackup.sh
#
#*************#
##### END #####
#*************#
###################################
# TASKS:                          #
# 1. connect to ssh               #
# 2. mkdir local                  #
# 3. run script remotley          #
# 4. copy dir + tar locally       #
# 5. Paths                        #
# 6. Check dir exist              #
###################################
#################################################################
#                                                               #
# GALERAVAR5=`ssh -p SSHPORT root@SSHRIP  'bash -s' << EOF      #
# systemctl status mariadb | grep -o 'active (running)'         #
# EOF`                                                          #
#                                                               #
#################################################################
