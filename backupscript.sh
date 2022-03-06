#!/bin/bash
#!/bin/sh -
#*************************#
##### Prerequisitions #####
#*************************#
# sites_directory=/var/www
# ping_to_webdav
# mysql_backup_user=bckp
#
#*******************#
##### Variables #####
#*******************#
function variables_ () {
mkdir -p /var/webbckp
M=mail
IP="$(hostname -I)"
SIG1="Have a nice day"
SIG2="Security Assistance"
HN="$(hostname)"
SRV=`hostname -s`
DN=cglms.com
RM=litan@cglms.com
SM=$HN@$DN
D="$(date +"Time:%H:%M:%S" && date +"Date:%d.%m.%Y")"
LD="$(date +"Time-%H:%M:%S-Date-%d.%m.%Y")"
E=echo
F=find
X=xargs
DU1="$(df -h)"
TD="$(fdisk -l | grep -m 1 -o -P '(?<=: ).*(?=B, )')"
DEL=130
}
#
function gl_ () {
TL1=/var/log/geo.log && echo > "$TL1"
PIP="$(curl https://ipinfo.io/ip)"
GL1="$(curl https://ipvigilante.com/$pip | tee >>$TL1)"
GL2="$(cat "$TL1" | grep -m 1 -o -P '(?<=("country_name":)).*(?=,"subdivision_1_name":)'  )"
}
#
#****************#
##### Alerts #####
#****************#
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
#*************************#
##### Check functions #####
#*************************#
function mount_webdav_ () {
CHCKDAV=`ls /usr/sbin | grep "dav" | wc -l`
if [ $CHCKDAV == "0" ]; then
 yum install davfs2 -y
fi
SRV=`hostname -s`
CK=`sudo curl -u bckp:NewPass123$ --insecure https://192.168.21.21/webbckp/ --list-only | grep -oP 'href=\K.*?(?=/")' | cut -c 2- | sed '/^[[:space:]]*$/d' | grep $SRV | wc -l`
if [ $CK == "0" ]; then
 sudo curl -u bckp:NewPass123$ --insecure -X MKCOL "https://192.168.21.21/webbckp/$SRV" > /dev/null 2>&1 && clear
fi
echo -ne 'bckp\nNewPass123$\ny' |  sudo mount -t davfs -o noexec https://192.168.21.21/webbckp/$SRV/ /var/webbckp > /dev/null 2>&1 && clear
cat <<- "EOF" | sudo tee -a /etc/fstab > /dev/null 2>&1 && clear
# personal webdav
https://192.168.21.21/webbckp/$SRV/ /var/webbckp 0 0
EOF
check_webdav_mount_
}
#
function check_webdav_mount_ () {
  webdav=`df -hk | grep webbckp | awk '{print $6}'`
  if [ -z "$webdav" ]; then
    gl_ && mail_no_webdav_
  else
    if [ -d /var/lib/mysql/ ]; then
     mkdir -p $webdav/sql
     SQL="$webdav/sql"
    fi
    if [ -d /var/www/ ]; then
     mkdir -p $webdav/www
     WWW="$webdav/www"
    fi
  fi
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
}
#
function chksql_ () {
if [ -d /var/lib/mysql/ ]; then
 bckp_sql_
else
 return 0
fi
}
#
function chkwww_ () {
if [ -d /var/www/ ]; then
 bckp_www_
else
 return 0
fi
}
#
function rm_old_bckp_ () {
CHK=`find $SQL -mtime +$DEL | wc -l`
webdav=`df -hk | grep webbckp | awk '{print $6}'`
WWW="$webdav/www" && SQL="$webdav/sql"
if [ "$CHK" != 0 ]; then
 if [ -d /var/lib/mysql/ ];then
  find $SQL/*.* -mtime +$DEL -exec rm {} \;
 fi
 if [ -d /var/www/ ];then
  find $WWW/*.* -mtime +$DEL -exec rm {} \;
 fi
 gl_ && mail_done_ && exit 0
else
 gl_ && mail_done_ && exit 0
 f_main
fi
}
#
#**************************#
##### Backup functions #####
#**************************#
function bckp_www_ () {
webdav=`df -hk | grep webbckp | awk '{print $6}'`
WWW="$webdav/www"
cd /var/www && ls -d -- * | while read dir ;
 do
  echo $dir && tar -cvzf $WWW/$dir-${LD}.tar.gz $dir;
 done
}
#
function bckp_sql_ () {
webdav=`df -hk | grep webbckp | awk '{print $6}'`
SQL="$webdav/sql"
cd $SQL && mysql -ubckp -N -e 'show databases;' |
while read dbname;
 do
  echo "Running sql backup.."
  mysqldump -ubckp --complete-insert --routines --triggers --single-transaction "$dbname" > $SQL/"$dbname-$LD".sql;
  rm -rf performance*.sql && rm -rf mysql-*.sql
 done
}
#
#**************#
##### MAIN #####           (G-0)  <=====<
#**************#
f_main () {
check_webdav_mount_
if [ -d /var/lib/mysql/ ] || [ -d /var/www/ ]; then
  echo "Backup service is starting ..... Hold on!"
  sleep 3 && chk_df_mnt_space_ && return 0
fi
}
#
#********************#
##### Start here #####
#********************#
variables_
f_main
#*************#
##### EOS #####
#*************#

# Tasks:
# Long Date
# ls: cannot access /var/www/: No such file or directory
