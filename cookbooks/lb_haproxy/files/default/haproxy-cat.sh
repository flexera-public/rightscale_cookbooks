#!/usr/bin/env bash
#
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set -e
shopt -s nullglob

CONF_FILE=/home/lb/1_rightscale_lb.cfg

cat /home/lb/rightscale_lb.cfg.head > ${CONF_FILE}

echo "frontend all_requests 127.0.0.1:85" >> ${CONF_FILE}

vhosts=""

for dir in /home/lb/lb_haproxy.d/*
do
  if [ -d ${dir} ]; then
    vhosts=${vhosts}" "`basename ${dir}`
      echo "! $vhosts"
  fi
done

for single_vhost in ${vhosts}
do
  acl=${single_vhost//\./_}"_acl"
  echo "  acl ${acl} hdr_dom(host) -i ${single_vhost}" >> ${CONF_FILE}

  # this will add advanced acls to config file
  if [ -e /home/lb/lb_haproxy.d/${single_vhost}/advanced_configs/acl.conf ]; then
    cat "/home/lb/lb_haproxy.d/$tmp_vhost/advanced_configs/acl.conf" >> ${CONF_FILE}
  fi

  
done

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  acl=${single_vhost//\./_}"_acl"
  backend=${single_vhost//\./_}"_backend"
  echo "  use_backend ${backend} if ${acl}" >> ${CONF_FILE}

  # this will add advanced use_backend statements to config file
  if [ -r  /home/lb/lb_haproxy.d/${tmp_vhost}/advanced_configs/use_backend.conf ];
  then
    cat /home/lb/lb_haproxy.d/${tmp_vhost}/advanced_configs/use_backend.conf>> ${CONF_FILE}
  fi
done

echo "" >> ${CONF_FILE}

cat /home/lb/rightscale_lb.cfg.default_backend >> ${CONF_FILE}

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  if [ $(ls -1A --ignore=advanced_configs /home/lb/lb_haproxy.d/${single_vhost} | wc -l) -gt 0 ]; then
     echo "backend ${single_vhost}_backend" >> ${CONF_FILE}
     cat /home/lb/lb_haproxy.d/${single_vhost}.cfg >> ${CONF_FILE}
     for single_config in /home/lb/lb_haproxy.d/${single_vhost}/*
     do
       if [ -f  $single_config  ]; then
        cat ${single_config} >> ${CONF_FILE}
       fi
     done
  fi
  echo "" >> ${CONF_FILE}
  for pool_cfg in /home/lb/lb_haproxy.d/${single_vhost}/advanced_configs/pool_*
  do
    current_pool=`basename ${pool_cfg}`
    echo "" >> ${CONF_FILE}
    echo "backend ${current_pool}" >> ${CONF_FILE}
    cat /home/lb/lb_haproxy.d/${single_vhost}.cfg >> ${CONF_FILE}
    cat /home/lb/lb_haproxy.d/${single_vhost}/advanced_configs/${current_pool}>> ${CONF_FILE}
  done
done


