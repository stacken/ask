# ask
freebsd jails för webhosting med nginx som reverse proxy

Install nginx and copy `nginx_proxy.conf` to `/usr/local/etc/nginx/nginx.conf`.

run `createjail.sh -n jailname -h hostname -i ipaddress -p path/to/www/root`

(ezjail with zfs must be installed and configured)

Please rename the network interface in createjail.sh
