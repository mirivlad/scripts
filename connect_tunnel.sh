#!/bin/bash
echo -n "Key_name (~/.key): "
read KEY
echo -n "LOCAL_PORT: "
read LOCAL_PORT
echo -n "PRIVATE_IP: "
read PRIVATE_IP
echo -n "PRIVATE_PORT: "
read PRIVATE_PORT
echo -n "SSH_SERVER: "
read SSH_SERVER
echo -n "SSH_PORT: "
read SSH_PORT
echo -n "SSH_USER: "
read SSH_USER

ssh -i ~/.key/$KEY -L 127.0.0.1:$LOCAL_PORT:$PRIVATE_IP:$PRIVATE_PORT $SSH_USER@$SSH_SERVER -p $SSH_PORT
