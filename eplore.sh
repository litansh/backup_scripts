#!/bin/bash

function variables_ () {
 goto="y"
 index=1
 line=1
}

function new_point_ () {
 line=$((line+1))
 echo "==>     $entry"
 goto=$entry
} 

function current_point_ () {
 line=$((line+1))
 echo -e "\t$entry"
}

function dirlist_ (){
line=1
lines="$(ls -1 $currentfullpath | wc -l)"
checkroot="$(echo $currentfullpath | grep root | wc -l)"
if [ "$goto" != "x" ]; then
 if [ -z "$currentfullpath" ] || [ "$checkroot" != "0" ]; then
  cd /
   for entry in /*
    do
     if [ $line != $index ];then
      current_point_
     else
      new_point_
     fi
    done
 elif [ "$currentfullpath" != "/" ] || [ "$exist" != "0" ] || [ "$goto" != "b" ]; then
  for entry in "$currentfullpath"/*
   do
    if [ $line != $index ]; then
     current_point_
    else
     new_point_
    fi
   done
 else
  for entry in "$goto"/*
   do
    if [ $line != $index ]; then
     current_point_
    else
     new_point_
    fi
   done
 fi
else
 clear
 exit
fi
}

function readvar_ (){
 index=1
 read -p -e 'Go To: (exit = x, Go back = b)
 ' key
 currentfullpath="$(echo $PWD)"
 clear
 if [ "$key" == "b" ]; then
  if [ -z "$currentfullpath" ] || [ "$currentfullpath" == "/" ]; then
   currentfullpath="/"
  else
   currentfullpath="$(echo $PWD | sed 's|\(.*\)/.*|\1|')"
  fi
  cd $currentfullpath
  dirlist_
  readvar_
 elif [ "$key" != "x" ]; then
  indexing_
  change_dir_
 fi
}

function up_fun_ () {
  index=$((index+1))
  dirlist_
}

function down_fun_ () {
 if [ $index > 1 ]; then
  index=$((index-1))
  dirlist_
 else 
  readvar_
 fi
}

function change_dir_ () {
 exist="$(ls | grep "$goto" | wc -l)"
  if [ "$exist" != "0" ]; then
   if [ "$currentfullpath" == "/" ];then
    cd $goto
    if [ $? -eq 0 ]; then
     echo "Debugging: OK"
    else
     clear
     echo "Debugging: FAIL, please insert again"
     cd $currentfullpath
     dirlist_
     readvar_
    fi
   else
    cd $currentfullpath/$goto
    if [ $? -eq 0 ]; then
     echo "Debugging: OK"
    else
     clear
     echo "Debugging: FAIL, please insert again"
     cd $currentfullpath
     dirlist_
     readvar_
   fi
  fi
  if [ "$currentfullpath" != "/" ];then
   currentfullpath="$currentfullpath/$goto"
  else
   currentfullpath="/$goto"
  fi
  dirlist_
  readvar_
 else
  dirlist_
  echo "Directory do not exist, please re-enter:"
  readvar_
 fi
line=1
dirlist_
}

function indexing_ () {
 case "$key" in
  $'\e[C'|$'\e0C') up_fun_ ;;
  $'\e[B'|$'\e0B') down_fun_ ;;
  $'\e[C'|$'\e0C') change_dir_ ;;
 esac
}

function start_ () {
variables_
goto=""

while [ "$goto" != "x" ];do
 dirlist_
 cd /
 readvar_
done

clear
}

start_




















