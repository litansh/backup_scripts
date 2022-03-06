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
MYSQLCHK01=`ps -ef | grep [m]ysql | wc -l`
if [ "$MYSQLCHK01" != "0" ]; then
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
fi
}

function rm-old-bckp_ () {
MYSQLCHK01=`ps -ef | grep [m]ysql | wc -l`
if [ "$MYSQLCHK01" != "0" ]; then
pathtobp="$(sed -n '1p' /tmp/path/bckp/bckp.log)"
sqllocal="$(find $pathtobp -type f -name "*.sql" | wc -l)"
dbhost="$(cd $path/${dir[i]} && cat wp-config.php | grep "DB_HOST" | awk '{print $3}' | cut -d "'" -f 2 | cut -f1 -d":")"
WWWsql=${pathtobp}/SQL
if [ "$sqllocal" != "0" ]; then
  find $WWWsql/${dir[$i]}/*.* -mtime +$DEL -exec rm {} \;
fi
fi
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
  grep 'Directory "/' /etc/httpd/conf/*.conf | grep -o '\/.*\"' | sed 's#/#\##g' | cut -d ' ' -f 2- > /root/wwwdirtmp.txt
 if [ -s /root/wwwdirtmp.txt ]; then
  echo ""
 else
  grep 'Directory "/' /etc/httpd/conf.d/*.conf | grep -o '\/.*\"' | sed 's#/#\##g' | cut -d ' ' -f 2- > /root/wwwdirtmp.txt
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
