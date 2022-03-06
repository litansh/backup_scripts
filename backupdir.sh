#!/bin/bash
cat > /root/backup.sh <<-"EOF"
function send_email_done_ (){
 HN=`hostname`
 SRV=`hostname -s`
 DN='ShamirDrive.com'
 echo "Hi Litan! GREAT SUCCESS!!!" | mail -s "Backup done on "$HN"!!!"  -r " <$SRV@$DN>" litansh@gmail.com
}

function send_email_wrong_ () {
  HN=`hostname`
  SRV=`hostname -s`
  DN='ShamirDrive.com'
  echo "Hi Litan! ALERT!!!" | mail -s "Backup NOT done on "$HN"!!!"  -r " <$SRV@$DN>" litansh@gmail.com
}

cd /home/nextcloud/data/ && ls -d */ | grep -v appdata | grep -v files_external | sed 's/.$//' > exclude.txt
rsync -avze ssh --exclude 'exclude.txt' /home/nextcloud/data/* root@192.168.6.100:/home/shamirdrivebckp01/
if [ "$?" -eq "0" ]; then
 send_email_done_
else
 send_email_wrong_
fi

rm -rf exclude.txt
EOF

chmod +x /root/backup.sh

function add_to_cron_ () {
crontab -l > mycron
echo "
0 1 * * * cd ~ && ./root/backup.sh
0 12 * * * cd ~ && ./root/backup.sh
0 22 * * * cd ~ && ./root/backup.sh
" >> mycron
crontab mycron
}

add_to_cron_
