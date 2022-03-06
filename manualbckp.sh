cat > /etc/manualbckp.sh <<-"EOF"
#!/bin/bash
#!/bin/sh -

HN=`hostname -s`
IPL="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep 192.168)"
DN=cglms.com
RM=litan.shamir@cglms.com
SM=$HN@$DN
LD="$(date +"Time-%H:%M:%S-Date-%d.%m.%Y")"

#
function mail_done_ () {
 echo "Hi there Admin! "$HN" *"$IPL"* Manual Backup done to " | mail -s "***Manual Backup done on "$IPL"!!! "  -r " <$HN@$DN>" $RM
}
#
rm -rf /root/allsitestmp.txt
while IFS= read -r line
 do
  if [[ $line =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
   echo $line >> /root/allsitestmp.txt
  fi
 done < /root/allsites.txt
mv -f /root/allsitestmp.txt /root/allsites.txt
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
   CheckYsql=`ls -l /usr/lib/cssam/backup/hosts/$line/DB/ | grep "$YDATE"`
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
   LD="$(date +"Time-%H:%M:%S-Date-%d.%m.%Y")"
  }
  #
  Backup_Variables_
  check_backup_done_
  #
  function check_remote_disk_ () {
   Backup_Variables_
   rm -rf /etc/checkremotediskORG.sh
   IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   ROOTU="$(sed -n '3p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   yes | cp -rf /etc/checkremotedisk.sh /etc/checkremotediskORG.sh
   sed -i "s/EEE/EOF/g" /etc/backupmysql.sh
   sed -i "s/XXEE/<<-"'"EOF"'"/g" /etc/backupmysql.sh
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
  if [ "$SQLDIR" != "" ]; then
   Backup_Variables_
   rm -rf /etc/backupmysqlORG.sh
   IPADDR="$(sed -n '1p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   IPPORT="$(sed -n '2p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   ROOTU="$(sed -n '3p' /usr/lib/cssam/backup/hosts/$line/$line.txt)"
   yes | cp -rf /etc/backupmysql.sh /etc/backupmysqlORG.sh
   sed -i "s/IPPORT/$IPPORT/g" /etc/backupmysql.sh
   sed -i "s/ROOTU/$ROOTU/g" /etc/backupmysql.sh
   sed -i "s/LINE/$IPADDR/g" /etc/backupmysql.sh
   sed -i "s/EEE/EOF/g" /etc/backupmysql.sh
   sed -i "s/XXEE/<<-"'"EOF"'"/g" /etc/backupmysql.sh
   chmod +x /etc/backupmysql.sh
   /./etc/backupmysql.sh
   rm -rf /etc/backupmysql.sh
   mv /etc/backupmysqlORG.sh /etc/backupmysql.sh
   rm -rf /etc/backupmysqlORG.sh
   mkdir -p /usr/lib/cssam/backup/hosts/$line/DB
   rsync -avzhe "ssh -p $IPPORT" root@$line:/root/DB /usr/lib/cssam/backup/hosts/$line
  fi
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
 done < /root/allsites.txt
 mail_done_
EOF
}
