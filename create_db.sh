#!/bin/bash
echo -n "DB_User: "
read USER
echo -n "DB_Pass: "
read PASS
echo -n "DB_Name: "
read DB

mysql <<MY_QUERY
USE mysql;
CREATE DATABASE $DB character set utf8mb4 collate utf8mb4_bin;
CREATE USER '$USER'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $DB.* TO '$USER'@'localhost';
FLUSH PRIVILEGES;
MY_QUERY
