#!/bin/bash
cat > /etc/sitesbackup.sh <<-"EOF"
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
RM=it@cglms.com
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
}

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
}
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
echo '
# personal webdav
https://192.168.21.21/webbckp/$SRV/ /var/webbckp 0 0
' >> /etc/fstab && clear
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
 gl_ && mail_done_ && exit 0
else
 find $SSL/*.* -mtime +$DELLESS -exec rm {} \;
 find $APACHE/*.* -mtime +$DELLESS -exec rm {} \;
 gl_ && mail_done_ && exit 0
fi
}
#
function exclude_from_tar_ () {
 cd /var/www/ && du -hk * | awk '$1 > 100000' | awk '{print $2}' > /root/dirsizelist.txt
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
#**************************#
##### Backup functions #####
#**************************#
function bckp_www_ () {
webdav=`df -hk | grep webbckp | awk '{print $6}'`
WWW="$webdav/www"
exclude_from_tar_
echo "Backing up Sites directories.." && sleep 2 && clear
cd /var/www && ls -d -- * | while read dir ;
 do
  echo -e "Backing up "$dir".." && sleep 2 && clear
  echo $dir && tar -cvzf $WWW/$dir-${LD}.tar.gz $dir --exclude="/root/exclude.txt";
 done
mkdir -p $webdav/httpd
tar -cvzf $webdav/httpd/httpd-${LD}.tar.gz /etc/httpd/;
find_ssl_dir_
if [ -z "$path" ]; then
 echo ""
else
 mkdir -p $webdav/SSLtoWWW
 tar -cvzf $webdav/SSLtoWWW/SSLtoWWW-${LD}.tar.gz $path/;
fi
}
#
function bckp_sql_ () {
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
EOF

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
systemctl restart sitesbackup  > /dev/null 2>&1 && clear
systemctl daemon-reload  > /dev/null 2>&1 && clear
fi
systemctl restart sitesbackup  > /dev/null 2>&1 && clear

chmod +x /etc/sitesbackup.sh
sudo /etc/sitesbackup.sh
