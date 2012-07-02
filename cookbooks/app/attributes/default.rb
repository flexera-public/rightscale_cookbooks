#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Set a default provider for app to connect with lb cookbook attach/detach
# for application servers without their own provider.
set_unless[:app][:provider] = "app"
# By default listen on port 8000
set_unless[:app][:port] = "8000"
# By default listen on the first private IP
# This is a set instead of set_unless to support start/stop when the IP changes.
set[:app][:ip] = node[:cloud][:private_ips][0]
# IP addrs of loadbalancer requesting firewall ports to be opened to it
set_unless[:app][:lb_ip]  = ""
# The database schema name the app server uses
set_unless[:app][:database_name] = ""
# The database adapter the application uses. By default app servers use MySQL.
set_unless[:app][:db_adapter] = "mysql"
