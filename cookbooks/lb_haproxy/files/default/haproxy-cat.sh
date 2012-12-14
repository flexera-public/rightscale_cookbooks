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

pools=""

for line in $(cat "/etc/haproxy/lb_haproxy.d/pool_list.conf");
do
  pools=${pools}" "${line}
done

echo "" >> ${CONF_FILE}

for single_pool in ${pools}
do
  if [ -e /etc/haproxy/lb_haproxy.d/acl_${single_pool}.conf ]; then
    cat "/etc/haproxy/lb_haproxy.d/acl_${single_pool}.conf" >> ${CONF_FILE}
  fi
done

echo "" >> ${CONF_FILE}

for single_pool in ${pools}
do
  # this will add advanced use_backend statements to config file
  if [ -r  /etc/haproxy/lb_haproxy.d/use_backend_${single_pool}.conf ]; then
    cat /etc/haproxy/lb_haproxy.d/use_backend_${single_pool}.conf>> ${CONF_FILE}
  fi
done

echo "" >> ${CONF_FILE}

cat /etc/haproxy/haproxy.cfg.default_backend >> ${CONF_FILE}

echo "" >> ${CONF_FILE}

for single_pool in ${pools}
do
  if [ -e /etc/haproxy/lb_haproxy.d/backend_${single_pool}.conf ]; then
    cat /etc/haproxy/lb_haproxy.d/backend_${single_pool}.conf >> ${CONF_FILE}

    if [ $(ls -1A /etc/haproxy/lb_haproxy.d/${single_pool} | wc -l) -gt 0 ]; then
      cat /etc/haproxy/lb_haproxy.d/${single_pool}/* >> ${CONF_FILE}
    fi
  fi

  echo "" >> ${CONF_FILE}

done
