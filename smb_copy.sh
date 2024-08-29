#!/bin/bash
#set -x
#Скрипт копирования с SMB шары
#-s сервер откуда копировать
#-f имя общей папки откуда копировать
#-m папка куда надо смонитировать. Можно не указывать, но для не ascii имен - 
#лучше указать, иначе могут быть проблемы с удалением директорий и отмонтирование общей папки

while [[ "$#" -gt 0 ]]
  do
    case $1 in
      -s|--server) SMB_SERV="$2"; shift;;
      -f|--folder) BACKUP_DIR="$2"; shift;;
      -m|--mount) MOUNTDIR="$2"; shift;;
    esac
    shift
done
if [ -z "${MOUNTDIR}" ]; then

    MOUNTDIR=$BACKUP_DIR

fi
BACKUP_DATE=$(date "+%Y%m%d-%H-%M-%S")
BACKUP_PATH='/back'
CRED="username=user@office.kp.ru,password=pass,iocharset=utf8,file_mode=0777,dir_mode=0777,vers=1.0"
mkdir -p $BACKUP_PATH/$MOUNTDIR
mkdir -p /root/temp_backup/$MOUNTDIR

mount -t cifs  -o $CRED //$SMB_SERV/$BACKUP_DIR /root/temp_backup/$MOUNTDIR

rsync -av --progress /root/temp_backup/$MOUNTDIR/ $BACKUP_PATH/$MOUNTDIR/$BACKUP_DATE/

if [ $? -eq 0 ]; then
/root/bin/telegram.sh "$SMB_SERV/$BACKUP_DIR 
✅ Копирование выполнено успешно"
else
/root/bin/telegram.sh "$SMB_SERV/$BACKUP_DIR 
❌ Неудачное копирование"
fi

umount -t cifs /root/temp_backup/$MOUNTDIR
rm -rf /root/temp_backup/$MOUNTDIR
