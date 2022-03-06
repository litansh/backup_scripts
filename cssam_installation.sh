::**************************************************#
:: installation flow:                               #
:: 1. write to configuration file                   #
:: 2. copy files ssh (service,modules,audit.rules)  #
:: 3. run installation                              #
:: 4. restart service                               #
::**************************************************#
::
 ::*************#
 :: START BATCH #
 ::*************#
::
@echo off
setlocal enabledelayedexpansion
set count=0
for /f "tokens=*" %%x in (c:\users\walter\desktop\Newfolder\test.txt) do (
 set /a count+=1
 set var[!count!]=%%x
)
::
 ::***********#
 :: VARIABLES #
 ::***********#
::
 set localpath=C:\Users\Walter\Desktop\Newfolder
 set hostpath=var/testonik
 set localdir=Newfolder
 set admin=%var[1]%
 echo %admin% > %localpath%\config.txt
 set user=%var[2]%
 set passwd=%var[3]%
 set host=%var[4]%
 set port=%var[5]%
::
 ::************#
 :: COPY FILES #
 ::************#
::
 pscp -pw "%passwd%" -P %port% -r -i %localpath% %localdir%\ %user%@%host%:/%hostpath%
::
 ::********************#
 :: RUN ON REMOTE HOST #
 ::********************#
::
 putty -ssh %user%@%host% %port% -pw "%passwd%" -m "%localpath%\installation.sh"
::
 DEL %localpath%\config.txt
::
 ::***********#
 :: END BATCH #
 ::***********#
::
#
#
#
 #***************#
 # START SERVICE #
 #***************#
#
 #*****************#
 # INSTALL SERVICE #
 #*****************#
#
###
#
 #*******************#
 # FILES PERMISSIONS #
 #*******************#
#
 chmod +x ///
#
 #*****************#
 # RESTART SERVICE #
 #*****************#
#
 sudo service auditd restart
#
 #*************#
 # END SERVICE #
 #*************#
#
#
#
 #*********#
 # THE END #
 #*********#
#
