#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Master DNS TTL Check - HA Only
#
# Checks the TTL of the Master DNS entry and exits with an error if the
# TTL is greater than 60 seconds. The purpose of this script is to prevent
# future DNS related problems pertaining to your database. For example, if you
# accidentally configure a DNS TTL of 3600 seconds on your Master DB DNS A
# Record, it might work fine at first, but you will experience issues when you
# attempt to promote a Slave-DB to Master-DB. As a best practice you should
# use a low TTL for your database that's less than or equal to 60 seconds.
# Update: for CloudDNS the TTL should be = 300s.
#


MASTER_DB_DNSNAME = node[:db][:dns][:master][:fqdn]
IS_FQDN_LOCALHOST = ( MASTER_DB_DNSNAME == "localhost" )

log "  Checking master database TTL settings..." do
  not_if { IS_FQDN_LOCALHOST }
end

log "  Skipping master database TTL check for FQDN 'localhost'." do
  only_if { IS_FQDN_LOCALHOST }
end

ruby_block "  Master DNS TTL Check" do
  not_if { IS_FQDN_LOCALHOST }
  block do
    OPT_DNS_TTL_LIMIT = "#{node[:db][:dns][:ttl]}"

    dnsttl=`dig #{MASTER_DB_DNSNAME} | grep ^#{MASTER_DB_DNSNAME} | awk '{ print $2}'`
    if dnsttl.to_i > OPT_DNS_TTL_LIMIT.to_i
       raise "Master DB DNS TTL set to high: must be set <= 60 (or <= 300 for CloudDNS). Currently #{dnsttl} for #{MASTER_DB_DNSNAME}"
    end
    Chef::Log.info("Pass: Master DB DNS TTL: #{dnsttl} <= TTL Limit (#{OPT_DNS_TTL_LIMIT}) for #{MASTER_DB_DNSNAME}")
  end
end

# Add database tag
# Let others know we are an active DB
right_link_tag "database:active=true"

# Install server
db node[:db][:data_dir] do
  user node[:db][:admin][:user]
  password node[:db][:admin][:password]
  action :install_server
end

# Determine if server is currently a master or a slave on boot.
# This determines that the instance returned from a Stop/Start
#
# If server already a master, reset node attributes and tags.
if node[:db][:this_is_master] && node[:db][:init_status].to_sym == :initialized
  log "Already set as master and initialized - updating node"
  db_register_master
# Else if server is already a slave, update node and config files
elsif node[:db][:this_is_master] == false && node[:db][:init_status].to_sym == :initialized
  log "Already set as slave and initialized - updating node"
  db_register_slave "Updating slave" do
    action :no_restore
  end
end

# Setting admin and application user privileges
db_set_privileges [
  {:role => "administrator", :username => node[:db][:admin][:user], :password => node[:db][:admin][:password]},
  {:role => "user", :username => node[:db][:application][:user], :password => node[:db][:application][:password]}
]

rightscale_marker :end
