#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Run only on master server
# See cookbooks/db/definitions/db_state_assert.rb for the implementation of
# db_state_assert definition.
db_state_assert :master


# Show sync mode status
bash "show sync mode status" do
  user "postgres"
  code <<-EOH
    echo "==================== do_show_slave_mode : Begin =================="

    psql -h #{node[:db][:socket]} -U postgres -c "select application_name, client_addr, sync_state from pg_stat_replication"

    echo "==================== do_show_slave_mode : End ===================="
  EOH
end

rightscale_marker :end
