#!/bin/sh

#
# Script Name:: apache2-take-ubuntu.sh
#
# Copyright 2013, CREATIONLINE, INC.
#

#
# Value
#
PORT=8080

#
# check OSTYPE
#
if [	x`lsb_release -si 2> /dev/null` = "xDebian" -o \
	x`lsb_release -si 2> /dev/null` = "xUbuntu" ]; then
	OSTYPE=DEBIAN
else
	echo "OSTYPE does not Debian/Ubuntu"
	exit 1
fi

#
# install required packages
#
apt-get update && \
apt-get install -y apache2 git curl unzip && \
dpkg -l apache git curl unzip 1> /dev/null 2> /dev/null
#
if [ "x$?" != "x0" ]; then
	echo "cannot install required packages"
	exit 1
fi

#
# start apache2
#
/etc/init.d/apache2 start && \
/etc/init.d/apache2 status
#
if [ "x$?" != "x0" ]; then
	echo "cannot start apache2"
	exit 1
fi

#
# change port
#
cp -f /etc/apache2/ports.conf /etc/apache2/ports.conf.bak && \
sed -e "s/^Listen 80$/Listen ${PORT}/; s/^NameVirtualHost \*:80$/NameVirtualHost *:${PORT}/" /etc/apache2/ports.conf.bak > /etc/apache2/ports.conf && \
cp -f /etc/apache2/sites-available/default /etc/apache2/sites-available/default.bak && \
sed -e "s/^<VirtualHost \*:80>$/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/default.bak > /etc/apache2/sites-available/default
#
if [ "x$?" != "x0" ]; then
	echo "cannot change port"
	exit 1
fi

#
# check change port
#
grep -qE "^Listen ${PORT}$" /etc/apache2/ports.conf && \
grep -qE "^NameVirtualHost \*:${PORT}$" /etc/apache2/ports.conf && \
grep -qE "^<VirtualHost \*:${PORT}>$" /etc/apache2/sites-available/default
#
if [ "x$?" != "x0" ]; then
	echo "cannot change port"
	exit 1
fi

#
# set content
#
cd /tmp && \
git clone https://github.com/cl-lab-k/apache2-take-sample-page && \
cp -f /tmp/apache2-take-sample-page/index.html /var/www/index.html && \
curl -o /tmp/apache2-take-sample-image.zip -L https://github.com/cl-lab-k/apache2-take-sample-image/archive/master.zip 2> /dev/null && \
unzip -d /tmp /tmp/apache2-take-sample-image.zip && \
mv /tmp/apache2-take-sample-image-master/ /var/www/img/
#
if [ "x$?" != "x0" ]; then
	echo "cannot set content"
	exit 1
fi

#
# check content
#
if [ ! -f /var/www/index.html -a \
     ! -d /var/www/img/ ]; then
	echo "cannot set content"
	exit 1
fi

#
# restart apache2
#
/etc/init.d/apache2 restart && \
/etc/init.d/apache2 status
#
if [ "x$?" != "x0" ]; then
	echo "cannot restart apache2"
	exit 1
fi

#
# normal exit
#
exit 0

#
# [EOF]
#
