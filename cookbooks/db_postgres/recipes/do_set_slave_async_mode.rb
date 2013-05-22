#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Run only on master server
# See cookbooks/db/definitions/db_state_assert.rb for the "db_state_assert" definition.
db_state_assert :master

log "  Initializing slave to connect to master in async state..."
# Sets 'sync_state' to 'async' mode on master server.
# See cookbooks/db_postgres/definitions/db_postgres_set_psqlconf.rb
# for the "db_postgres_set_psqlconf" definition.
db_postgres_set_psqlconf "setup_postgresql_conf"

# Setup pg_hba.conf
cookbook_file "#{node[:db_postgres][:confdir]}/pg_hba.conf" do
  source "pg_hba.conf"
  owner "postgres"
  group "postgres"
  mode "0644"
  cookbook "db_postgres"
end

# Reload postgresql to read new updated postgresql.conf
log "  Reload postgresql to read new updated postgresql.conf"
RightScale::Database::PostgreSQL::Helper.do_query('select pg_reload_conf()')
