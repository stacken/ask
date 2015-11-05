#!/bin/sh

usage() {
	echo "usage: createjail.sh -n name_of_jail -i ip -p path/to/www/root -h hostname_of_web_site"
}
#while getopts "n:i:p:" opt; do
while getopts "n:i:p:h:" opt; do
	case "$opt" in
	n) name=$OPTARG ;;
	i) ip=$OPTARG ;;
	p) path=$OPTARG ;;
	h) host=$OPTARG ;;
	esac
done

if [ -z "$name" ]; then
	echo "need name"; usage ; exit 1
elif [ -z "$ip" ]; then
	echo "need ip"; usage ; exit 1
elif [ -z "$path" ]; then
	echo "need path"; usage ; exit 1
elif [ -z "$host" ]; then
	echo "need host"; usage ; exit 1
fi

echo "Jail info:"
echo "  name=${name}"
echo "  ip=${ip}"
echo "  path=${path}"
echo "  host=${host}"

read -p "Create jail (y/N) " REPLY
if [ "$REPLY" = "y" ]; then
	echo creating jail $name at $ip
	ezjail-admin create $name 'bce0|10.0.0.1' 

	echo creating /www directory
	mkdir /usr/jails/$name/www

	echo mounting www directory
	echo $path /usr/jails/$name/www nullfs rw 0 0  >> /etc/fstab
	mount -a

	echo creating resolv.conf
	echo nameserver 8.8.8.8 > /usr/jails/$name/etc/resolv.conf

	echo starting jail $name
	ezjail-admin start $name

	echo installing nginx
	ezjail-admin console -e 'env ASSUME_ALWAYS_YES=YES pkg bootstrap' $name
	ezjail-admin console -e 'pkg install -y nginx php56 php56-extensions-1.0 php56-pdo_mysql' $name
	cp nginx.conf /usr/jails/$name/usr/local/etc/nginx/nginx.conf

	echo enabling stuff
	echo 'nginx_enable="TRUE"' >> /usr/jails/$name/etc/rc.conf
	echo 'php_fpm_enable="TRUE"' >> /usr/jails/$name/etc/rc.conf

	echo starting stuff
	ezjail-admin console -e 'service nginx start' $name
	ezjail-admin console -e 'service php-fpm start' $name

	echo creating reverse proxy
	cat > /usr/local/etc/nginx/hosted_jails/$name.conf \
<<EOF
server {
	listen 80;
	server_name $host www.$host;
	location / {
		proxy_set_header Host \$host;
		proxy_set_header X-Real-IP \$remote_addr;
		proxy_pass http://$ip:80;
	}
}
EOF

	echo reloading reverse proxy
	service nginx reload

fi;

