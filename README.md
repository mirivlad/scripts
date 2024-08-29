# Scripts

This repository contains scripts written by me at various times to make my work easier or to reduce routine operations

## List scripts and their description

### connect_tunnel.sh
This script interactively accepts input from the user and connects via ssh with tunnel forwarding to a host on a private network

### create_db.sh

This script interactively accepts input from the user, creates a mysql database, the user and gives him rights to this database

### create_host.sh

This script checks whether nginx, php-fpm, mysql are installed on the system, if not, it installs them. Then it interactively accepts input from the user, creates a directory for the site, a configuration file for the web server, a pool for php-fpm, a mysql database, and a user for it. Thus, this script prepares a local or remote server to launch a virtual host for the site to run. Requires running under sudo or as root
  
