#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Used to find master db. When a slave database starts, it needs to determine
# which database it should use as master. If there is only one DB tagged as
# master, it will be chosen. Lineage is used to restore the database from a
# backup created by the master.  Master DBs can contain it's lineage in it's
# "rs_dbrepl:master_active" tag. This definition uses this logic to determine
# what database should be master for the slave running it.
#
# @param action [Symbol] restore process to do before becoming a slave.
#   * The +:primary_restore+ action will do a restore from primary backup
#     location then become a slave.
#   * The +:secondary_restore+ action will do a restore from secondary backup
#     location then become a slave.
#   * The +:demote_master+ action will process configs and tags to be a slave.
#   * The +:no_restore+ action will not do a restore of any type then will
#     become a slave.  Used for stop/start where data already exists.
#
# @raise [RuntimeError] if no master DB found
# @raise [RuntimeError] if invalid action type is chosen. must be primary_restore,
#   :secondary_restore or no_restore
#
define :db_register_slave, :action => :primary_restore do

  # Tag the slave server
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RightLinkTag for the "right_link_tag" resource.
  right_link_tag "rs_dbrepl:slave_instance_uuid=#{node[:rightscale][:instance_uuid]}"

  DATA_DIR = node[:db][:data_dir]

  # if we are demoting a master
  if params[:action] == :demote_master

    # See cookbooks/db_<provider>/providers/default.rb for the
    # "enable_replication" action.
    db DATA_DIR do
      restore_process :no_restore
      action :enable_replication
    end

  else

    # See cookbooks/rightscale/providers/server_collection.rb for the "load" action.
    r = rightscale_server_collection "master_servers" do
      tags 'rs_dbrepl:master_instance_uuid'
      mandatory_tags ['rs_dbrepl:master_active', 'server:private_ip_0']
      action :nothing
    end
    # See cookbooks/rightscale/providers/server_collection.rb for the "load" action.
    r.run_action(:load)

    # Finds the master matching lineage and sets the node attributes for
    #   node[:db][:current_master_uuid]
    #   node[:db][:current_master_ip]
    #   node[:db][:this_is_master]
    #   node[:db][:current_master_ec2_id] - for 11H1 migration
    r = ruby_block "find current master" do
      block do

        # Declare vars before block to persist after 'each do' loop.
        selected_master_info = {}
        lineage = ""
        # Using reverse order to end with first found master
        # if no DB tagged with lineage.
        ip_tag =
          case node[:db][:replication][:network_interface]
          when "private"
           "server:private_ip_0"
          when "public"
           "server:public_ip_0"
          when "vpn"
           "server:vpn_ip_0"
          else
           raise "\"#{node[:db][:replication][:network_interface]}\"" +
             " is not a valid network interface."
          end
        # Using reverse order to end with first found master if no DB tagged with lineage.
        node[:server_collection]["master_servers"].reverse_each do |id, tags|
          master_active_tag = tags.detect { |s| s =~ /rs_dbrepl:master_active/ }

          activation_time, lineage = master_active_tag.split('-', 2)

          my_uuid = tags.detect { |u| u =~ /rs_dbrepl:master_instance_uuid/ }
          my_ip_0 = tags.detect { |i| i =~ /#{ip_tag}/ }

          # Following used for detecting 11H1 DB servers
          ec2_instance_id = tags.detect { |e| e =~ /ec2:instance_id/ }

          selected_master_info = {
            :activation_time => activation_time,
            :my_uuid => my_uuid,
            :my_ip_0 => my_ip_0,
            :ec_instance_id => ec2_instance_id,
          }

          # If this master has the right lineage, break, else continue checking.
          if (lineage && lineage == node[:db][:backup][:lineage])
            Chef::Log.info "  #{lineage} : Lineage match found"
            break
          else
            Chef::Log.info "  #{lineage} : Lineage mismatch - checking next"
          end

        end

        # If lineage was not part of the master_active_tag tag
        # use the first (or only) found master
        unless (lineage && lineage == node[:db][:backup][:lineage])
          Chef::Log.info "  Lineage not found, using first discovered master"
        end

        activation_time = selected_master_info[:activation_time]
        current_master_uuid = selected_master_info[:my_uuid]
        current_master_ip = selected_master_info[:my_ip_0]
        current_master_ec2_id = selected_master_info[:ec_instance_id]

        if current_master_uuid =~ /#{node[:rightscale][:instance_uuid]}/
          Chef::Log.info "  This instance is the current master"
          node[:db][:this_is_master] = true
        else
          node[:db][:this_is_master] = false
        end
        if current_master_uuid
          node[:db][:current_master_uuid] =
            current_master_uuid.split(/=/, 2).last.chomp
        else
          node[:db][:current_master_uuid] = nil
          Chef::Log.info "  No current master db found"
        end
        if current_master_ip
          node[:db][:current_master_ip] =
            current_master_ip.split(/=/, 2).last.chomp
        else
          node[:db][:current_master_ip] = nil
          Chef::Log.info "  No current master ip found"
        end

        # following used for detecting 11H1 DB servers
        if current_master_ec2_id
          node[:db][:current_master_ec2_id] =
            current_master_ec2_id.split(/=/, 2).last.chomp
          Chef::Log.info "  Detected #{current_master_ec2_id} - 11H1 migration"
        else
          node[:db][:current_master_ec2_id] = nil
        end

        Chef::Log.info "  Found master: #{node[:db][:current_master_uuid]} " +
          "ip: #{node[:db][:current_master_ip]} active at #{activation_time}" \
          if current_master_uuid && current_master_ip
      end
    end
    r.run_action(:create)

    raise "No master DB found" \
      unless node[:db][:current_master_ip] && node[:db][:current_master_uuid]

    # Populate node with master DB info for later reference.
    # See cookbooks/db/definitions/db_state_set.rb for the "db_state_set" definition.
    db_state_set "Set master/slave state" do
      master_uuid node[:db][:current_master_uuid]
      master_ip node[:db][:current_master_ip]
      is_master node[:db][:this_is_master]
      immediate true
    end

    # Set firewall rules to allow slave to connect to master DB.
    # See cookbooks/db/recipes/request_master_allow.rb for the "db::request_master_allow" recipe.
    include_recipe "db::request_master_allow"

    # After slave has been initialized, run the specified restore recipe, primary or secondary.
    # Stop/start or reboot would pass a no_restore action.
    case params[:action]
    when :primary_restore
      # See cookbooks/db/recipes/do_primary_restore.rb for the "db::do_primary_restore" recipe.
      include_recipe "db::do_primary_restore"
    when :secondary_restore
      # See cookbooks/db/recipes/do_secondary_restore.rb for the "db::do_secondary_restore" recipe.
      include_recipe "db::do_secondary_restore"
    when :no_restore
      log "  No restore"
    else
      raise "invalid parameter"
    end

    # Not needed for stop/start since replication has already been enabled.
    # See cookbooks/db_<provider>/providers/default.rb for the "enable_replication" action.
    db DATA_DIR do
      restore_process params[:action]
      action :enable_replication
    end

    # Force a new backup if this is the initial setup of a slave
    case params[:action]
    when :primary_restore, :secondary_restore
      # See cookbooks/db/definitions/db_request_backup.rb for the "db_request_backup" definition.
      db_request_backup "do backup"
    else
      log "  No backup initiated"
    end
  end

  # See cookbooks/db_<provider>/providers/default.rb for the "setup_monitoring" action.
  db DATA_DIR do
    action :setup_monitoring
  end

  # See cookbooks/db/recipes/do_primary_backup_schedule_enable.rb for the "db::do_primary_backup_schedule_enable" recipe.
  include_recipe "db::do_primary_backup_schedule_enable"

end
