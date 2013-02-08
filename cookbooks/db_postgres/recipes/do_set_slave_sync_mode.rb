#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Run only on master server
# See cookbooks/db/definitions/db_state_assert.rb for the "db_state_assert" definition.
db_state_assert :master


# Set sync mode on master server

log "  Initializing slave to connect to master in sync state..."
# Updates postgresql.conf for replication
log "  Updates postgresql.conf for replication"
RightScale::Database::PostgreSQL::Helper.configure_postgres_conf(node)

# Reload postgresql to read new updated postgresql.conf
log "  Reload postgresql to read new updated postgresql.conf"
RightScale::Database::PostgreSQL::Helper.do_query('select pg_reload_conf()')

rightscale_marker :end
