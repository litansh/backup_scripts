#!/bin/bash

### System Overview‏‏
 
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

get_server_time_ () {

if [ "$CENTOS" == 1 ]; then
    current_server_time_centos_
elif [ "$UBUNTU" == 1 ]; then
	current_server_time_ubuntu_
fi
}

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

chk_sys_active_users_ () { 
#1 Checl selinux if up or down
SYSUSERSCHK=`cat /etc/passwd | grep -v nologin | grep -v false | grep -v sync | awk -F':' '{ print $1 }' | wc -l`
SYSTEMUSERSBAN=`echo "${green}${fgred}$SYSUSERSCHK${green} Regular users${normal}"`
} 

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

### Banners

function unset_banner_ (){
    unset BANNER
	unset FIND
	unset GREPBANN
	unset COUNTFIND
} 

function logo_findme_ () {
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
                                      \    / BCKPauto  //  /     
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

function logo_findme_restore_ () {
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
                                      \    / Restore   //  /     
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

function call_allert_title_ () {
    clear && echo && clear
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}${menu1}                                       ${bgwhite}${menu}Database Backup${menu}${menu1}                                               ${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	unset TIMEMENUBANNER
} 

function call_allert_title_restore_ () {
    clear && echo && clear
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}${menu1}                                       ${bgwhite}${menu}Restore Site Menu${menu}${menu1}                                               ${normal}"
	echo -e "${menu}${menu1}--------------------------------------------------------------------------------------------------------${normal}"
	echo -e "${menu}$BANNER${normal}${green}${normal}${green}$GREPBANN${normal}"
	unset TIMEMENUBANNER
} 

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

### Variables

function variables_ () {
export UBUNTU=`awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o Ubuntu | wc -l`
export CENTOS=`awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o CentOS | wc -l `
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
TL1=/var/geo.log
M=mail
IP="$(hostname -I)"
FIRSTIP=`hostname -I | awk '{print $1,"\n"$2,"\n",$3 }' | sed '/:/d' | awk 'NF > 0' | sed 's/^[ \t]*//' | sed 's/[[:blank:]]*$//' | sed -n '1p'`
SECONDIP=`hostname -I | awk '{print $1,"\n"$2,"\n",$3 }' | sed '/:/d' | awk 'NF > 0' | sed 's/^[ \t]*//' | sed 's/[[:blank:]]*$//' | sed -n '2p'`
SIG1="Have a nice day"
SIG2="Security Assistance"
HN="$(hostname)"
DN=cglms.com
RM=litan@cglms.com
SM=$HN@$DM
D="$(date +"Time:%H:%M:%S" && date +"Date:%d.%m.%Y")"
E=echo     
F=find     
X=xargs
DU1="$(df -h)"
TD="$(fdisk -l | grep -m 1 -o -P '(?<=: ).*(?=B, )')"
DEL=8
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
}

### Alerts

function gl_ () {
TL1=/var/geo.log
PIP="$(curl https://ipinfo.io/ip)"
GL1="$(curl https://ipvigilante.com/$pip | tee >>$TL1)"
GL2="$(cat "$TL1" | grep -m 1 -o -P '(?<=("country_name":)).*(?=,"subdivision_1_name":)'  )"
}

function mail-done_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* Backup done". ;$E "Server Details:"  ; $E "Geo Location: $GL2" ; $E "" ;$E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***Backup done on "$HN" !!! "  -r " <$HN@$DN>" $RM 
}

function mail-restore-done_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* Restoration done". ;$E "Server Details:"  ; $E "Geo Location: $GL2" ; $E "" ;$E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***Restored "${dir[$i]}" on "$HN" !!! "  -r " <$HN@$DN>" $RM 
}

function mail-panic_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* have problem with disk space". ;$E "Server Details:" ;$E "Local ip: "$IP"" ;$E "Public ip: $PIP" ;$E "Name: $HN" ; $E "Geo Location: $GL2" ; $E "" ; $E  "$DU1 " ; $E ""$TD"" ; $E "Exact time of event:" ; $E "$D" ; $E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***On server "$HN" disk '95%' full !!! "  -r " <$HN@$DN>" $RM 
chk-df-mnt-space_ 
}

function mail-panic_backup_not_done_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* Did not backup!!". ;$E "Server Details:" ;$E "Local ip: "$IP"" ;$E "Public ip: $PIP" ;$E "Name: $HN" ; $E "Geo Location: $GL2" ; $E "" ; $E  "$DU1 " ; $E ""$TD"" ; $E "Exact time of event:" ; $E "$D" ; $E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***On server "$HN" Backup NOT done !!! "  -r " <$HN@$DN>" $RM 
}

function chk-df-mnt-space_ () {
local P1="80%"
local P2="81%"
local P3="97%"
local P4="98%"
local CHK="$(df -h | grep -E "$P1|$P2|$P3|$P4" | wc -l)"
if [ "$CHK" != 0 ]; then
 gl_ && mail-panic_ && sleep 5m && f_main
else
 sites_ 
fi
}

function chk-df-mnt-space_restore_ () {
local P1="80%"
local P2="81%"
local P3="97%"
local P4="98%"
local CHK="$(df -h | grep -E "$P1|$P2|$P3|$P4" | wc -l)"
if [ "$CHK" != 0 ]; then
 gl_ && mail-panic_ && exit 0
else
 restore_site_
fi
}

function mail-restore-done_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* Restoration done". ;$E "Server Details:"  ; $E "Geo Location: $GL2" ; $E "" ;$E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***Restored "${dir[$i]}" on "$HN" !!! "  -r " <$HN@$DN>" $RM 
}

### Check server

function selinux_permissive_ () {
sed -i 's/SELINUX=disabled/SELINUX=permissive/' /etc/selinux/config
sudo setenforce 0
}

function htaccess_ () {
checkhtaccess="$(cat $path/${dir[$i]}/.htaccess | grep 'JetCar [OR]' | wc -l)"
if [ $checkhtaccess == 0 ]; then
echo -e " 
# BEGIN WordPress
# The directives (lines) between `BEGIN WordPress` and `END WordPress` are
# dynamically generated, and should only be modified via WordPress filters.
# Any changes to the directives between these markers will be overwritten.
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>

<IfModule mod_rewrite.c>
RewriteCond %{QUERY_STRING} ^author=([0-99]*)
RewriteRule .* http://cloudflare.com/? [L,R=302]
</IfModule>

# END WordPress
##Block bad bots
RewriteEngine On
RewriteCond %{HTTP_USER_AGENT} ^BlackWidow [OR]
RewriteCond %{HTTP_USER_AGENT} ^Bot\ mailto:craftbot@yahoo.com [OR]
RewriteCond %{HTTP_USER_AGENT} ^ChinaClaw [OR]
RewriteCond %{HTTP_USER_AGENT} ^Custo [OR]
RewriteCond %{HTTP_USER_AGENT} ^DISCo [OR]
RewriteCond %{HTTP_USER_AGENT} ^Download\ Demon [OR]
RewriteCond %{HTTP_USER_AGENT} ^eCatch [OR]
RewriteCond %{HTTP_USER_AGENT} ^EirGrabber [OR]
RewriteCond %{HTTP_USER_AGENT} ^EmailSiphon [OR]
RewriteCond %{HTTP_USER_AGENT} ^EmailWolf [OR]
RewriteCond %{HTTP_USER_AGENT} ^Express\ WebPictures [OR]
RewriteCond %{HTTP_USER_AGENT} ^ExtractorPro [OR]
RewriteCond %{HTTP_USER_AGENT} ^EyeNetIE [OR]
RewriteCond %{HTTP_USER_AGENT} ^FlashGet [OR]
RewriteCond %{HTTP_USER_AGENT} ^GetRight [OR]
RewriteCond %{HTTP_USER_AGENT} ^GetWeb! [OR]
RewriteCond %{HTTP_USER_AGENT} ^Go!Zilla [OR]
RewriteCond %{HTTP_USER_AGENT} ^Go-Ahead-Got-It [OR]
RewriteCond %{HTTP_USER_AGENT} ^GrabNet [OR]
RewriteCond %{HTTP_USER_AGENT} ^Grafula [OR]
RewriteCond %{HTTP_USER_AGENT} ^HMView [OR]
RewriteCond %{HTTP_USER_AGENT} HTTrack [NC,OR]
RewriteCond %{HTTP_USER_AGENT} ^Image\ Stripper [OR]
RewriteCond %{HTTP_USER_AGENT} ^Image\ Sucker [OR]
RewriteCond %{HTTP_USER_AGENT} Indy\ Library [NC,OR]
RewriteCond %{HTTP_USER_AGENT} ^InterGET [OR]
RewriteCond %{HTTP_USER_AGENT} ^Internet\ Ninja [OR]
RewriteCond %{HTTP_USER_AGENT} ^JetCar [OR]
RewriteCond %{HTTP_USER_AGENT} ^JOC\ Web\ Spider [OR]
RewriteCond %{HTTP_USER_AGENT} ^larbin [OR]
RewriteCond %{HTTP_USER_AGENT} ^LeechFTP [OR]
RewriteCond %{HTTP_USER_AGENT} ^Mass\ Downloader [OR]
RewriteCond %{HTTP_USER_AGENT} ^MIDown\ tool [OR]
RewriteCond %{HTTP_USER_AGENT} ^Mister\ PiX [OR]
RewriteCond %{HTTP_USER_AGENT} uuuu7u^Navroad [OR]
RewriteCond %{HTTP_USER_AGENT} ^NearSite [OR]
RewriteCond %{HTTP_USER_AGENT} ^NetAnts [OR]
RewriteCond %{HTTP_USER_AGENT} ^NetSpider [OR]
RewriteCond %{HTTP_USER_AGENT} ^Net\ Vampire [OR]
RewriteCond %{HTTP_USER_AGENT} ^NetZIP [OR]
RewriteCond %{HTTP_USER_AGENT} ^Octopus [OR]
RewriteCond %{HTTP_USER_AGENT} ^Offline\ Explorer [OR]
RewriteCond %{HTTP_USER_AGENT} ^Offline\ Navigator [OR]
RewriteCond %{HTTP_USER_AGENT} ^PageGrabber [OR]
RewriteCond %{HTTP_USER_AGENT} ^Papa\ Foto [OR]
RewriteCond %{HTTP_USER_AGENT} ^pavuk [OR]
RewriteCond %{HTTP_USER_AGENT} ^pcBrowser [OR]
RewriteCond %{HTTP_USER_AGENT} ^RealDownload [OR]
RewriteCond %{HTTP_USER_AGENT} ^ReGet [OR]
RewriteCond %{HTTP_USER_AGENT} ^SiteSnagger [OR]
RewriteCond %{HTTP_USER_AGENT} ^SmartDownload [OR]
RewriteCond %{HTTP_USER_AGENT} ^SuperBot [OR]
RewriteCond %{HTTP_USER_AGENT} ^SuperHTTP [OR]
RewriteCond %{HTTP_USER_AGENT} ^Surfbot [OR]
RewriteCond %{HTTP_USER_AGENT} ^tAkeOut [OR]
RewriteCond %{HTTP_USER_AGENT} ^Teleport\ Pro [OR]
RewriteCond %{HTTP_USER_AGENT} ^VoidEYE [OR]
RewriteCond %{HTTP_USER_AGENT} ^Web\ Image\ Collector [OR]
RewriteCond %{HTTP_USER_AGENT} ^Web\ Sucker [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebAuto [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebCopier [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebFetch [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebGo\ IS [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebLeacher [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebReaper [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebSauger [OR]
RewriteCond %{HTTP_USER_AGENT} ^Website\ eXtractor [OR]
RewriteCond %{HTTP_USER_AGENT} ^Website\ Quester [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebStripper [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebWhacker [OR]
RewriteCond %{HTTP_USER_AGENT} ^WebZIP [OR]
RewriteCond %{HTTP_USER_AGENT} ^Wget [OR]
RewriteCond %{HTTP_USER_AGENT} ^Widow [OR]
RewriteCond %{HTTP_USER_AGENT} ^WWWOFFLE [OR]
RewriteCond %{HTTP_USER_AGENT} ^Xaldon\ WebSpider [OR]
RewriteCond %{HTTP_USER_AGENT} ^Zeus
RewriteRule ^.* - [F,L]

" >> $path/${dir[$i]}/.htaccess
fi
}

function show_df_ () {
  echo -e "\n\t\t\t\t ${menu}${menu1}Server partitions : ${normal}\n"
  df -hk
  echo -e "\n\n"
}

function add_to_cron_ () {
 crontab -l > mycron
 echo "0 5 * * * /root/bckp.sh" >> mycron
 crontab mycron
} 

### DB

function restore_from_bckp () {
 pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
 dbhost="$(cd $path/${dir[i]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
 sqllocal="$(find $pathtobp -type f -name "*.sql" | wc -l)"
 WWWsql=${pathtobp}/SQL 
 bckpu="$(sed -n '2p' /tmp/path/bckp/bckp.log)" 
 rm -rf $path/${dir[$i]}/*
 sleep 5
 tar -zxvf $WWWrepl/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".tar.gz -C $path/${dir[$i]}
 sleep 5
 if [ "$dbhost" == "localhost" ] || [ "$dbhost" == "127.0.0.1" ] || [ "$dbhost" == "$SECONDIP" ] || [ "$sqllocal" != "0" ]; then
  mysql -u$bckpu ${dbname[$i]} < $WWWsql/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".sql
  sleep 5
 fi
 mail-restore-done_
}

function check_dir_size_ () {
 gbsize=`du -hcs $WWWrepl/${dir[$i]} | grep GB | wc -l`
 checksize=`du -hcs $WWWrepl/${dir[$i]}  | awk '{print $1}' | head -n 1 | cut -d "M" -f 1`
 if [ $gbsize != "0" ] || [ $checksize > "500" ]; then
   find $WWWrepl/${dir[$i]}/*.* -mtime +7 -exec rm {} \;
 else
   find $WWWrepl/${dir[$i]}/*.* -mtime +60 -exec rm {} \;
 fi
}

function create_db_users_to_show_databases_ () {
usr="$(sed -n '1p' /tmp/path/bckp/bckptmp.log)" 
passwd="$(sed -n '2p' /tmp/path/bckp/bckptmp.log)" 
call_allert_title_
logo_findme_
mysql -u$usr -p$passwd -N <<MYSQL_SCRIPT
CREATE USER 'dbshow'@'localhost' IDENTIFIED BY '@wsxcde3';
GRANT SHOW DATABASES on *.* to 'dbshow'@'localhost';
GRANT SELECT on *.* to 'dbshow'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

clear && clear && clear
 }
 
function bckp-www_ () {
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
dbhost="$(cd $path/${dir[1]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
gbsize="$(du -hcs $WWWrepl/${dir[$i]} | grep GB | wc -l)"
checksizegb="$(du -hcs $WWWrepl/${dir[$i]}  | awk '{print $1}' | head -n 1 | cut -d "G" -f 1)"
WWWrepl=${pathtobp}/REPL
if [ ${dir[$i]} != "" ] && [ $gbsize != "0" ] && [ $checksizegb < "2" ]; then 
   mkdir -p $WWWrepl
   mkdir -p $WWWrepl/${dir[$i]}
   cd $WWWrepl
   tar -cvzf $WWWrepl/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".tar.gz $path/${dir[$i]}
elif [ ${dir[$i]} != "" ] && [ $gbsize != "0" ] && [ $checksizegb > "2" ]; then
   mkdir -p $WWWrepl
   mkdir -p $WWWrepl/${dir[$i]}
   cd $WWWrepl
   tar -czvf $WWWrepl/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".tar.gz $path/${dir[$i]} --exclude="$path/${dir[$i]}/wp-content/uploads"
elif [ ${dir[$i]} != "" ] && [ $gbsize == "0" ]; then
   mkdir -p $WWWrepl
   mkdir -p $WWWrepl/${dir[$i]}
   cd $WWWrepl
   tar -cvzf $WWWrepl/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".tar.gz $path/${dir[$i]}
fi
cd /root/
}

function bckp-sql_ () {
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
dbhost="$(cd $path/${dir[i]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
sqllocal="$(find $pathtobp -type f -name "*.sql" | wc -l)"
WWWsql=${pathtobp}/SQL 
bckpu="$(sed -n '2p' /tmp/path/bckp/bckp.log)" 
 if [ "$dbhost" == "localhost" ] || [ "$dbhost" == "127.0.0.1" ] || [ "$dbhost" == "$SECONDIP" ] || [ "$sqllocal" != "0" ]; then
   mkdir -p $WWWsql
   mkdir -p $WWWsql/${dir[$i]}
   dbname[$i]="$(cd $path/${dir[$i]} && cat wp-config.php | grep "DB_NAME" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d"'")"
   mysqldump -u$bckpu ${dbname[$i]} > $WWWsql/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".sql
 fi
}

function rm-old-bckp_ () {
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
sqllocal="$(find $pathtobp -type f -name "*.sql" | wc -l)"
dbhost="$(cd $path/${dir[i]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
WWWsql=${pathtobp}/SQL
if [ "$sqllocal" != "0" ]; then
  find $WWWsql/${dir[$i]}/*.* -mtime +$DEL -exec rm {} \;
fi
}

function chk_root_exist_passwd_ () {
TMP="/tmp/path/bckp/bckptmp.log"
while true;
 do 
  clear && clear && clear
  call_allert_title_
  echo -e "\n\t\t\t  ${menu}${menu1}Database backup first time configuration${normal}\n"
  logo_findme_
  echo -e "\t\t\t${number}   Step 1${menu}: ${menu}Enter MySQL super user:${normal}"
  local C1="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
  read -e -p "$C1" usr
  clear && clear && clear
  call_allert_title_
  echo -e "\n\t\t\t  ${menu}${menu1}Database backup first time configuration${normal}\n"
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
sleep 1
clear 

}

function chk_root_exist_passwd_restore_ () {
TMP="/tmp/path/bckp/bckptmp.log"
while true;
 do 
  clear && clear && clear
  call_allert_title_restore_
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
  logo_findme_restore_
  echo -e "\t\t\t${number}   Step 1${menu}: ${menu}Enter MySQL super user:${normal}"
  local C1="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
  read -e -p "$C1" usr
  clear && clear && clear
  call_allert_title_restore_
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
  logo_findme_restore_
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
sleep 1
clear 
}

function getdbusers_ () {
echo -e "\n\n"
echo "    Database Users         "
mysql -udbshow -p'@wsxcde3' -N -e  'select host, user from mysql.user;'

}

function getdbusers_exist_ () {
# while true;
 # do 
  echo -e "\n\n"
  echo "    Database Users         "
  mysql -udbshow -p'@wsxcde3' -N -e  'select host, user from mysql.user;' | grep $mysqlbackupuser
  dbuserexist="$(mysql -udbshow -p'@wsxcde3' -N -e  'select host, user from mysql.user;' | grep $mysqlbackupuser | wc -l)"
  if [ $dbuserexist == 0 ]; then
   create_db_users_
  else
   return 0 && break 
  fi
# done
sleep 1
clear 
}

function create_db_users_ () {
  TMP1="/tmp/path/bckp/bckp.log"
  call_allert_title_
  echo -e "\n\t\t\t\t ${menu}${menu1}Database backup first time configuration${normal}\n"
  getdbusers_
  backuppasswd=""
mysql -u$usr -p$passwd -N <<MYSQL_SCRIPT
CREATE USER '$mysqlbackupuser'@'localhost' IDENTIFIED BY '$backuppasswd';
GRANT EVENT, DROP, LOCK TABLES, RELOAD, REPLICATION CLIENT, SELECT, SHOW VIEW, TRIGGER on *.* to '$mysqlbackupuser'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
  clear && echo -e "\n\n\n\t\t\t        ${green}${blink}$mysqlbackupuser password set to blank${normal}${menu} ${normal}" 
   
  printf "\n\n\n\t\t\t        ${green}${blink}Created new user $mysqlbackupuser with correct backup permissions${normal}${menu} ${normal}"
  sleep 2
  clear
 }

### Sites

function comparison_ () {
 i=1 && compare="ok" &&
 lines="$(wc -l /root/wwwdirtmp.txt | grep -o '^\S*')"
 while IFS= read -r line
  do
   var[$i]="$(echo $line | perl -p -e 's/^.*?#//' | awk -F# '{print $1}')"
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

function find_site_dir_ () {
 grep 'Directory "/' /etc/httpd/conf/*.conf | grep -o '\/.*\"' | sed 's#/#\##g' | sed 's/.$//' > /root/wwwdirtmp.txt
 if [ -s /root/wwwdirtmp.txt ]; then
  echo ""
 else
  grep 'Directory "/' /etc/httpd/conf.d/*.conf | grep -o '\/.*\"' | sed 's#/#\##g' | sed 's/.$//' > /root/wwwdirtmp.txt
 fi
 compare="ok" && i=1 && path=""
 while [ -s /root/wwwdirtmp.txt ] && [ $compare == "ok" ]; 
  do
   comparison_  
   cat /root/wwwdirtmp.txt | cut -d"#" -f3- | tr " " "\n" | sed 's/^/#/' | tr " " "\n" > /root/wwwtmp.txt && mv -f /root/wwwtmp.txt /root/wwwdirtmp.txt && rm -rf /root/wwwtmp.txt
  done
}

function sites_ () {
find_site_dir_
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
WWWsql=${pathtobp}/SQL
ls -d $path/* | grep -oP "\S+$" | sed '/cgi-bin/d' | sed '/tar.gz/d' | sed '/tgz/d' | sed '/REPL/d' | sed '/SQL/d' | grep -v -E '^[0-9]+$' | sed -r 's/.{9}//' | sed 's/[0-9]*//g' | sed '/^[[:space:]]*$/d'  > /root/wwwlistdir.txt
lines="$(wc -l /root/wwwlistdir.txt | grep -o '^\S*')"
sqllocal="$(find $WWWsql -type f -name "*.sql" | wc -l)"
i=1 && x=0
while IFS= read -r line
 do
  if [ $lines > $x ]; then
   dir[$i]="$(echo $line)"
   rm-old-bckp_
   check_dir_size_
   bckp-www_ 
   bckp-sql_
   x=$((x+1))
  else 
   echo "Done"
  fi
 done < /root/wwwlistdir.txt
 mail-done_
}

### Restore Menu

function restore_date_ () {
 pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
 WWWrepl=${pathtobp}/REPL
 ls -l $WWWrepl/$restoresite
}

function restore_sql_ () {
 pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
 WWWsql=${pathtobp}/SQL
 ls -l $WWWsql/$restoresite
}

function restore_site_ () {
 rm -rf $path/$restoresite/*
 sleep 3
 tar -zxvf $restoredatedir -C $path/$restoresite/
 sleep 3
 mysql -ureplica $restoresite < $WWWsql/$restoredatesql
 sleep 3
 mail-restore-done_
 sleep 3
}

function main_bckp_restore_ () {
 variables_
 find_site_dir_
while true;
  do
   chk_root_exist_passwd_restore_
   clear
   call_allert_title_restore_
   echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
   system_status_start_
   ls -l $path | awk '{print $9}'
   echo -e "\n\n\t\t\t${number}   Step 1${menu}: ${menu}Please enter a site to restore:${normal}"
   local C1="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
   read -e -p "$C1" restoresite
   clear
   call_allert_title_restore_
   echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
   restore_date_
   echo -e "\n\n\t\t\t${number}   Step 2${menu}: ${menu}Please select which replication to restore to:${normal}"
   local C2="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
   read -e -p "$C2" restoredatedir
   clear
   call_allert_title_restore_
   echo -e "\n\t\t\t\t ${menu}${menu1}Restore Menu${normal}\n"
   restore_sql_
   echo -e "\n\n\t\t\t${number}   Step 3${menu}: ${menu}Please select which .sql to restore:${normal}"
   local C3="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
   read -e -p "$C3" restoredatesql
   chk-df-mnt-space_restore_
   sleep 5
   return 0 && break  
  done
}

### Main

function f_main () {
 cat > /root/backup.sh <<-"EOF"
#!/bin/bash

### Variables

function variables_ () {
export UBUNTU=`awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o Ubuntu | wc -l`
export CENTOS=`awk -F= '/^NAME/{print $2}' /etc/os-release | grep -o CentOS | wc -l `
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
TL1=/var/geo.log
M=mail
IP="$(hostname -I)"
FIRSTIP=`hostname -I | awk '{print $1,"\n"$2,"\n",$3 }' | sed '/:/d' | awk 'NF > 0' | sed 's/^[ \t]*//' | sed 's/[[:blank:]]*$//' | sed -n '1p'`
SECONDIP=`hostname -I | awk '{print $1,"\n"$2,"\n",$3 }' | sed '/:/d' | awk 'NF > 0' | sed 's/^[ \t]*//' | sed 's/[[:blank:]]*$//' | sed -n '2p'`
SIG1="Have a nice day"
SIG2="Security Assistance"
HN="$(hostname)"
DN=cglms.com
RM=litan@cglms.com
SM=$HN@$DM
D="$(date +"Time:%H:%M:%S" && date +"Date:%d.%m.%Y")"
E=echo     
F=find     
X=xargs
DU1="$(df -h)"
TD="$(fdisk -l | grep -m 1 -o -P '(?<=: ).*(?=B, )')"
DEL=60
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
}

### Alerts

function gl_ () {
TL1=/var/geo.log
PIP="$(curl https://ipinfo.io/ip)"
GL1="$(curl https://ipvigilante.com/$pip | tee >>$TL1)"
GL2="$(cat "$TL1" | grep -m 1 -o -P '(?<=("country_name":)).*(?=,"subdivision_1_name":)'  )"
}

function mail-restore-done_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* Restoration done". ;$E "Server Details:"  ; $E "Geo Location: $GL2" ; $E "" ;$E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***Restored "${dir[$i]}" on "$HN" !!! "  -r " <$HN@$DN>" $RM 
}

function mail-panic_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* have problem with disk space". ;$E "Server Details:" ;$E "Local ip: "$IP"" ;$E "Public ip: $PIP" ;$E "Name: $HN" ; $E "Geo Location: $GL2" ; $E "" ; $E  "$DU1 " ; $E ""$TD"" ; $E "Exact time of event:" ; $E "$D" ; $E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***On server "$HN" disk '95%' full !!! "  -r " <$HN@$DN>" $RM 
chk-df-mnt-space_ 
}

function mail-panic_backup_not_done_ () {
{ $E "Hi there !" ;$E "" ;$E ""$HN" *"$IP"* Did not backup!!". ;$E "Server Details:" ;$E "Local ip: "$IP"" ;$E "Public ip: $PIP" ;$E "Name: $HN" ; $E "Geo Location: $GL2" ; $E "" ; $E  "$DU1 " ; $E ""$TD"" ; $E "Exact time of event:" ; $E "$D" ; $E "  " ; $E "" ; $E "Yours", ; $E "$SIG2" ; } | sed -e 's/^[ \t]*//' | $M -s "***On server "$HN" Backup NOT done !!! "  -r " <$HN@$DN>" $RM 
}

### Main

function f_main () {
  echo -e "${menu}Backup service is starting . Hold on!${normal}"
  sleep 1
  echo -e "${menu}Backup service is starting .. Hold on!${normal}"
  sleep 1
  echo -e "${menu}Backup service is starting ... Hold on!${normal}"
  sleep 1
  echo -e "${menu}Backup service is starting .... Hold on!${normal}"
  sleep 1
  echo -e "${menu}Backup service is starting ..... Hold on!${normal}"
  sleep 1  
  clear && clear && clear
  variables_
  chk-df-mnt-space_
  rm -rf $TL1
 }
 
function chk-df-mnt-space_ () {
local P1="80%"
local P2="81%"
local P3="97%"
local P4="98%"
local CHK="$(df -h | grep -E "$P1|$P2|$P3|$P4" | wc -l)"
if [ "$CHK" != 0 ]; then
 gl_ && mail-panic_ && exit 0
else
 gl_ && sites_ 
fi
}

### DB

function restore_from_bckp () {
 pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
 dbhost="$(cd $path/${dir[i]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
 sqllocal="$(find $pathtobp -type f -name "*.sql" | wc -l)"
 WWWsql=${pathtobp}/SQL 
 bckpu="$(sed -n '2p' /tmp/path/bckp/bckp.log)" 
 rm -rf $path/${dir[$i]}/*
 sleep 5
 tar -zxvf $WWWrepl/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".tar.gz -C $path/${dir[$i]}
 sleep 5
 if [ "$dbhost" == "localhost" ] || [ "$dbhost" == "127.0.0.1" ] || [ "$dbhost" == "$SECONDIP" ] || [ "$sqllocal" != "0" ]; then
  mysql -u$bckpu ${dbname[$i]} < $WWWsql/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".sql
  sleep 5
 fi
 mail-restore-done_
}

function bckp-www_ () {
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
dbhost="$(cd $path/${dir[1]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
gbsize="$(du -hcs $WWWrepl/${dir[$i]} | grep GB | wc -l)"
checksizegb="$(du -hcs $WWWrepl/${dir[$i]}  | awk '{print $1}' | head -n 1 | cut -d "G" -f 1)"
WWWrepl=${pathtobp}/REPL
if [ ${dir[$i]} != "" ] && [ $gbsize != "0" ] && [ $checksizegb < "2" ]; then 
   mkdir -p $WWWrepl
   mkdir -p $WWWrepl/${dir[$i]}
   tar -cvzf $WWWrepl/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".tar.gz $path/${dir[$i]}
elif [ ${dir[$i]} != "" ] && [ $gbsize != "0" ] && [ $checksizegb > "2" ]; then
   mkdir -p $WWWrepl
   mkdir -p $WWWrepl/${dir[$i]}
   tar -czvf $WWWrepl/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".tar.gz $path/${dir[$i]} --exclude="$path/${dir[$i]}/wp-content/uploads"
elif [ ${dir[$i]} != "" ] && [ $gbsize == "0" ]; then
   mkdir -p $WWWrepl
   mkdir -p $WWWrepl/${dir[$i]}
   tar -cvzf $WWWrepl/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".tar.gz $path/${dir[$i]}
fi
}

function bckp-sql_ () {
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
dbhost="$(cd $path/${dir[i]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
sqllocal="$(find $pathtobp -type f -name "*.sql" | wc -l)"
WWWsql=${pathtobp}/SQL 
bckpu="$(sed -n '2p' /tmp/path/bckp/bckp.log)" 
 if [ "$dbhost" == "localhost" ] || [ "$dbhost" == "127.0.0.1" ] || [ "$dbhost" == "$SECONDIP" ] || [ "$sqllocal" != "0" ]; then
   mkdir -p $WWWsql
   mkdir -p $WWWsql/${dir[$i]}
   dbname[$i]="$(cd $path/${dir[$i]} && cat wp-config.php | grep "DB_NAME" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d"'")"
   mysqldump -u$bckpu ${dbname[$i]} > $WWWsql/${dir[$i]}/"${dir[$i]}-$(date +%d-%m-%Y)".sql
 fi
}

function rm-old-bckp_ () {
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
sqllocal="$(find $pathtobp -type f -name "*.sql" | wc -l)"
dbhost="$(cd $path/${dir[i]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
WWWsql=${pathtobp}/SQL
if [ "$sqllocal" != "0" ]; then
  find $WWWsql/${dir[$i]}/*.* -mtime +$DEL -exec rm {} \;
fi
}

function chk_root_exist_passwd_restore_ () {
TMP="/tmp/path/bckp/bckptmp.log"
while true;
 do 
  clear && clear && clear
  call_allert_title_restore_
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
  logo_findme_restore_
  echo -e "\t\t\t${number}   Step 1${menu}: ${menu}Enter MySQL super user:${normal}"
  local C1="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
  read -e -p "$C1" usr
  clear && clear && clear
  call_allert_title_restore_
  echo -e "\n\t\t\t\t\t   ${menu}${menu1}Restore Menu${normal}\n"
  logo_findme_restore_
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
sleep 1
clear 
}

### Sites

function comparison_ () {
 i=1 && compare="ok" &&
 lines="$(wc -l /root/wwwdirtmp.txt | grep -o '^\S*')"
 while IFS= read -r line
  do
   var[$i]="$(echo $line | perl -p -e 's/^.*?#//' | awk -F# '{print $1}')"
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

function find_site_dir_ () {
 grep 'Directory "/' /etc/httpd/conf/*.conf | grep -o '\/.*\"' | sed 's#/#\##g' | sed 's/.$//' > /root/wwwdirtmp.txt
 if [ -s /root/wwwdirtmp.txt ]; then
  echo ""
 else
  grep 'Directory "/' /etc/httpd/conf.d/*.conf | grep -o '\/.*\"' | sed 's#/#\##g' | sed 's/.$//' > /root/wwwdirtmp.txt
 fi
 compare="ok" && i=1 && path=""
 while [ -s /root/wwwdirtmp.txt ] && [ $compare == "ok" ]; 
  do
   comparison_  
   cat /root/wwwdirtmp.txt | cut -d"#" -f3- | tr " " "\n" | sed 's/^/#/' | tr " " "\n" > /root/wwwtmp.txt && mv -f /root/wwwtmp.txt /root/wwwdirtmp.txt && rm -rf /root/wwwtmp.txt
  done
}

function sites_ () {
find_site_dir_
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)" 
WWWsql=${pathtobp}/SQL
ls -d $path/* | grep -oP "\S+$" | sed '/cgi-bin/d' | sed '/tar.gz/d' | sed '/tgz/d' | sed '/REPL/d' | sed '/SQL/d' | grep -v -E '^[0-9]+$' | sed -r 's/.{9}//' | sed 's/[0-9]*//g' | sed '/^[[:space:]]*$/d'  > /root/wwwlistdir.txt
lines="$(wc -l /root/wwwlistdir.txt | grep -o '^\S*')"
sqllocal="$(find $WWWsql -type f -name "*.sql" | wc -l)"
i=1 && x=0
while IFS= read -r line
 do
  if [ $lines > $x ]; then
   dir[$i]="$(echo $line)"
   rm-old-bckp_
   check_dir_size_
   bckp-www_ 
   bckp-sql_
   x=$((x+1))
  else 
   echo "Done"
  fi
 done < /root/wwwlistdir.txt
 mail-done_
}

f_main
  
EOF
chmod +x /root/backup.sh
./root/backup.sh
rm -rf $TL1
}

function first_time_configuration_ () {
  while true;
  do
   mkdir -p /tmp/path/bckp
   chk_root_exist_passwd_
   create_db_users_to_show_databases_
   clear && clear && clear 
   clear && clear && clear
   call_allert_title_
   echo -e "\n\t\t\t\t ${menu}${menu1}Database backup first time configuration${normal}\n"
   system_status_start_
   echo -e "\t\t\t${number}   Step 3${menu}: ${menu}Enter path to backup MySQL and Replicas:${normal}"
   local C1="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
   read -e -p "$C1" pathtobckp
   clear && clear && clear
   call_allert_title_
   echo -e "\n\t\t\t\t ${menu}${menu1}Database backup first time configuration${normal}\n"
   getdbusers_
   echo -e "\n\n\t\t\t${number}   Step 4${menu}: ${menu}Enter mysql backup user OR type new backup user:${normal}"
   local C2="$(printf "\t\t\t   ${bggrey}${black}${blink}===>${normal}${menu}: ${normal}")"
   read -e -p "$C2" mysqlbackupuser
   getdbusers_exist_
   pathtobckp=${pathtobckp%/}
   echo "$pathtobckp" >> /tmp/path/bckp/bckp.log
   echo "$mysqlbackupuser" >> /tmp/path/bckp/bckp.log
   clear && clear && clear
   logo_p_good_
   f_main
   return 0 && break  
  done
}

### Start

function start_ () {
gl_
variables_
local chkip=`ls /tmp/path/bckp | wc -l`
if [ "$chkip" == 0 ]; then
 selinux_permissive_
 first_time_configuration_
fi
rm -rf /tmp/path/bckp/bckptmp.log
main_bckp_restore_
rm -rf /tmp/path/bckp/bckptmp.log
}

start_

##### Tasks:
### Restore function                    
### du
### 2GB                                 V
### if no sql -> do not run             V
### Clone prdweb                        V
### Clone prddb                         V
### 60.180 to DEBCKP                    V
### Check prdweb                        
### Check prddb    
### Service


