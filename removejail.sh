#!/bin/sh

name=$1

echo stopping jail $name
ezjail-admin stop $name

echo deleting jail $name
ezjail-admin delete $name

echo umounting /www
umount /usr/jails/$name/www

echo destroying zroot/jails/$name
zfs destroy zroot/jails/$name 

echo removing /usr/jails/$name
rmdir /usr/jails/$name

echo removing nginx config
rm /usr/local/etc/nginx/hosted_jails/$name.conf

echo Please remove from fstab
