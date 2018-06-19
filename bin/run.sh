#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(cd -P $(dirname $0) && pwd )

cd $SCRIPT_DIR/..

ignoreRoot=0
for ARG in $*
do
  if [ "$ARG" = "--root" ]; then
    ignoreRoot=1
  fi
done

#Stop the script if its started as root
if [ "$(id -u)" -eq 0 ] && [ $ignoreRoot -eq 0 ]; then
   echo "You shouldn't start OneTimeSecret as root!"
   echo "Please type 'OneTimeSecret rocks my socks' or supply the '--root' argument if you still want to start it as root"
   read rocks
   if [ ! "$rocks" == "OneTimeSecret rocks my socks" ]
   then
     echo "Your input was incorrect"
     exit 1
   fi
fi

# set port if specified
port=7143
if [ $# -ge 1 ]; then
   port=$1
fi

#start redis server
docker stop myredis
docker run -d --rm -v `pwd`/etc/onetime/redis.conf:/usr/local/etc/redis/redis.conf --name myredis -p 7179:6379 redis:3.2 redis-server /usr/local/etc/redis/redis.conf
sleep 2

echo "Started OneTimeSecret..."

bundle exec thin -e dev -R config.ru -p $port start
