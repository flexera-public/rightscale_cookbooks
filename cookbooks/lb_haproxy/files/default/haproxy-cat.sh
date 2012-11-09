#!/usr/bin/env bash
# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set -e
shopt -s nullglob

CONF_FILE=/home/lb/rightscale_lb.cfg

cat /home/lb/rightscale_lb.cfg.head > ${CONF_FILE}

echo "frontend all_requests 127.0.0.1:85" >> ${CONF_FILE}

vhosts=""

for dir in /home/lb/lb_haproxy.d/*
do
  if [ -d ${dir} ]; then
    vhosts=${vhosts}" "`basename ${dir}`
  fi
done

for single_vhost in ${vhosts}
do
  acl=${single_vhost//\./_}"_acl"
  echo "  acl ${acl} hdr_beg(host) -i ${single_vhost}" >> ${CONF_FILE}
done

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  acl=${single_vhost//\./_}"_acl"
  backend=${single_vhost//\./_}"_backend"
  echo "  use_backend ${backend} if ${acl}" >> ${CONF_FILE}
done

echo "" >> ${CONF_FILE}

cat /home/lb/rightscale_lb.cfg.default_backend >> ${CONF_FILE}

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  cat /home/lb/lb_haproxy.d/${single_vhost}.cfg >> ${CONF_FILE}

  if [ $(ls -1A /home/lb/lb_haproxy.d/${single_vhost} | wc -l) -gt 0 ]; then
    cat /home/lb/lb_haproxy.d/${single_vhost}/* >> ${CONF_FILE}
  fi

  echo "" >> ${CONF_FILE}

done
