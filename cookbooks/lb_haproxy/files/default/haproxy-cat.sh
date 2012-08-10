#!/usr/bin/env bash
# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set -e
shopt -s nullglob

CONF_FILE=/etc/haproxy/haproxy.cfg

cat /etc/haproxy/haproxy.cfg.head > ${CONF_FILE}

echo "frontend all_requests 127.0.0.1:85" >> ${CONF_FILE}

vhosts=""

for dir in /etc/haproxy/lb_haproxy.d/*
do
  if [ -d ${dir} ]; then
    vhosts=${vhosts}" "`basename ${dir}`
  fi
done

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  if [ -e /etc/haproxy/lb_haproxy.d/acl_${single_vhost}.conf ]; then
    cat "/etc/haproxy/lb_haproxy.d/acl_${single_vhost}.conf" >> ${CONF_FILE}
  fi
done

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  # this will add advanced use_backend statements to config file
  if [ -r  /etc/haproxy/lb_haproxy.d/use_backend_${single_vhost}.conf ]; then
    cat /etc/haproxy/lb_haproxy.d/use_backend_${single_vhost}.conf>> ${CONF_FILE}
  fi
done

echo "" >> ${CONF_FILE}

cat /etc/haproxy/haproxy.cfg.default_backend >> ${CONF_FILE}

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  if [ -r  /etc/haproxy/lb_haproxy.d/userlist_backend_${single_vhost}.conf ]; then
    cat /etc/haproxy/lb_haproxy.d/userlist_backend_${single_vhost}.conf>> ${CONF_FILE}
  fi
done

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  cat /etc/haproxy/lb_haproxy.d/${single_vhost}.cfg >> ${CONF_FILE}

  if [ $(ls -1A /etc/haproxy/lb_haproxy.d/${single_vhost} | wc -l) -gt 0 ]; then
    cat /etc/haproxy/lb_haproxy.d/${single_vhost}/* >> ${CONF_FILE}
  fi

  echo "" >> ${CONF_FILE}

done
