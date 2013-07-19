#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

define :db_postgres_set_psqlconf,
  :datadir => nil,
  :confdir => nil,
  :max_connections => nil,
  :shared_buffers => nil,
  :sync_state => "async" do

  # Logs what is being passed into this definition.
  params.each do |parameter, argument|
    log "  '#{parameter.inspect} => #{argument.inspect}' passed into" +
      " 'db_postgres_set_psqlconf' definition." unless parameter == :name
  end

  template "#{node[:db_postgres][:confdir]}/postgresql.conf" do
    source "postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode "0644"
    cookbook "db_postgres"
    variables(
      :datadir => params[:datadir] || node[:db_postgres][:datadir],
      :confdir => params[:confdir] || node[:db_postgres][:confdir],
      :max_connections => params[:max_connections] ||
        node[:db_postgres][:tunable][:max_connections],
      :shared_buffers => params[:shared_buffers] ||
        node[:db_postgres][:tunable][:shared_buffers],
      :sync_state => params[:sync_state]
    )
  end

end
