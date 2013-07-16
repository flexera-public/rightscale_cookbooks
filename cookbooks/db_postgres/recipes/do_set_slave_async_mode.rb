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

# Reload postgresql to read new updated postgresql.conf
log "  Reload postgresql to read new updated postgresql.conf"
ruby_block "pg_reload_conf" do
  block do
    RightScale::Database::PostgreSQL::Helper.do_query("select pg_reload_conf()")
  end
end
