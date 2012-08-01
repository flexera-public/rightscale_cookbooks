#!/usr/bin/env bash
#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

CONFIG_FILE=/etc/my.cnf

string="
# IMPORTANT: Additional settings that can override those from this file!\n
# The files must end with '.cnf', otherwise they'll be ignored.\n
#\n
!includedir /etc/mysql/conf.d/"

# if /etc/my.cnf already exists
#   check if includedir line is present in the file, else append the line
# if /etc/my.cnf does not exist
#   create it with just the includedir line in it
if [ -e $CONFIG_FILE ]
then
  if ! grep -Eq "\s*\!includedir\s*/etc/mysql/conf\.d" $CONFIG_FILE
  then
    echo -e $string >> $CONFIG_FILE
  fi
else
  echo -e $string > $CONFIG_FILE
fi
