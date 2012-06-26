#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Database
    module MySQL
      module Helper

        require 'timeout'
        require 'yaml'
        require 'ipaddr'

        SNAPSHOT_POSITION_FILENAME = 'rs_snapshot_position.yaml'
        DEFAULT_CRITICAL_TIMEOUT = 7

        # Create numeric UUID
        # MySQL server_id must be a unique number  - use the ip address integer representation
        #
        # Duplicate IP's and server_id's may occur with cross cloud replication.
        def mycnf_uuid
          node[:db_mysql][:mycnf_uuid] = IPAddr.new(node[:cloud][:private_ips][0]).to_i
        end

        # Generate unique filename for relay_log used in slave db.
        # Should only generate once.  Used to create unique relay_log files used for slave
        # Always set to support stop/start
        def mycnf_relay_log
          node[:db_mysql][:mycnf_relay_log] = Time.now.to_i.to_s + rand(9999).to_s.rjust(4,'0') if !node[:db_mysql][:mycnf_relay_log]
          return node[:db_mysql][:mycnf_relay_log]
        end

        # Create new MySQL object
        #
        # @param new_resource [Object] Resource which will be initialized
        #
        # @return [Mysql] MySQL object
        def init(new_resource)
          begin
            require 'rightscale_tools'
          rescue LoadError
            Chef::Log.warn "  This database cookbook requires our 'rightscale_tools' gem."
            Chef::Log.warn "  Please contact Rightscale to upgrade your account."
          end
          mount_point = new_resource.name
          version = node[:db_mysql][:version].to_f > 5.1 ? :mysql55 : :mysql
          Chef::Log.info "  Using version: #{version} : #{node[:db_mysql][:version]}"

          RightScale::Tools::Database.factory(version, new_resource.user, new_resource.password, mount_point, Chef::Log)
        end

        # Helper to load replication information
        # from "rs_snapshot_position.yaml"
        #
        # @param node [Hash] Node name
        def self.load_replication_info(node)
          loadfile = ::File.join(node[:db][:data_dir], SNAPSHOT_POSITION_FILENAME)
          Chef::Log.info "  Loading replication information from #{loadfile}"
          YAML::load_file(loadfile)
        end

        # Loading information about replication master status.
        # If that file exists, the MySQL server has already previously been configured for replication,
        #
        # @param node [Hash] Node name
        def self.load_master_info_file(node)
          loadfile = ::File.join(node[:db][:data_dir], "master.info")
          Chef::Log.info "  Loading master.info file from #{loadfile}"
          file_contents = File.readlines(loadfile)
          file_contents.each {|f| f.rstrip!}
          master_info = Hash.new
          master_info["File"] = file_contents[1]
          master_info["Position"] = file_contents[2]
          master_info["Master_IP"] = file_contents[3]
          return master_info
        end

        # Create new Mysql connection
        #
        # @param node [Hash] Node name
        # @param hostname [String] Hostname FQDN, default is 'localhost'
        #
        # @return [Mysql] MySQL connection
        def self.get_mysql_handle(node, hostname = 'localhost')
          info_msg = "  MySQL connection to #{hostname}"
          info_msg << ": opening NEW MySQL connection."
          con = Mysql.new(hostname, node[:db][:admin][:user], node[:db][:admin][:password])
          Chef::Log.info info_msg
          # this raises if the connection has gone away
          con.ping
          return con
        end

        # Perform sql query to MySql server
        #
        # @param node [Hash] Node name
        # @param hostname [String] Hostname FQDN, default is 'localhost'
        # @param timeout [Integer] Timeout value
        # @param tries [Integer] Connection attempts number
        #
        # @return [Mysql::Result] MySQL query result
        #
        # @raise [TimeoutError] if timeout exceeded
        # @raise [RuntimeError] if connection try attempts limit reached
        def self.do_query(node, query, hostname = 'localhost', timeout = nil, tries = 1)
          require 'mysql'

          loop do
            begin
              info_msg = "  Doing SQL Query: HOST=#{hostname}, QUERY=#{query}"
              info_msg << ", TIMEOUT=#{timeout}" if timeout
              info_msg << ", NUM_TRIES=#{tries}" if tries > 1
              Chef::Log.info info_msg
              result = nil
              if timeout
                SystemTimer.timeout_after(timeout) do
                  con = get_mysql_handle(node, hostname)
                  result = con.query(query)
                end
              else
                con = get_mysql_handle(node, hostname)
                result = con.query(query)
              end
              return result.fetch_hash if result
              return result
            rescue Timeout::Error => e
              Chef::Log.info("  Timeout occured during mysql query:#{e}")
              tries -= 1
              raise "FATAL: retry count reached" if tries == 0
            end
          end
        end

        # Replication process reconfiguration
        #
        # @param node [Hash] Node name
        # @param hostname [String] Hostname FQDN, default is 'localhost'
        # @param newmaster_host [String] FQDN or ip of new replication master
        # @param newmaster_logfile [String] Replication log filename
        # @param newmaster_position [Integer] Last record position in replication log
        def self.reconfigure_replication(node, hostname = 'localhost', newmaster_host = nil, newmaster_logfile=nil, newmaster_position=nil)
          Chef::Log.info "  Configuring with #{newmaster_host} logfile #{newmaster_logfile} position #{newmaster_position}"

          # The slave stop can fail once (only throws warning if slave is already stopped)
          2.times do
            RightScale::Database::MySQL::Helper.do_query(node, "STOP SLAVE", hostname)
          end

          cmd = "CHANGE MASTER TO MASTER_HOST='#{newmaster_host}'"
          cmd +=   ", MASTER_LOG_FILE='#{newmaster_logfile}'" if newmaster_logfile
          cmd +=   ", MASTER_LOG_POS=#{newmaster_position}" if newmaster_position
          Chef::Log.info "Reconfiguring replication on localhost: \n#{cmd}"
          # don't log replication user and password
          cmd +=   ", MASTER_USER='#{node[:db][:replication][:user]}'"
          cmd +=   ", MASTER_PASSWORD='#{node[:db][:replication][:password]}'"
          RightScale::Database::MySQL::Helper.do_query(node, cmd, hostname)

          RightScale::Database::MySQL::Helper.do_query(node, "START SLAVE", hostname)
          started=false
          10.times do
            row = RightScale::Database::MySQL::Helper.do_query(node, "SHOW SLAVE STATUS", hostname)
            slave_IO = row["Slave_IO_Running"].strip.downcase
            slave_SQL = row["Slave_SQL_Running"].strip.downcase
            if( slave_IO == "yes" and slave_SQL == "yes" ) then
              started=true
              break
            else
              Chef::Log.info "  Threads at new slave not started yet...waiting a bit more..."
              sleep 2
            end
          end
          if( started )
            Chef::Log.info "  Slave threads on the master are up and running."
          else
            Chef::Log.info "  Error: slave threads in the master do not seem to be up and running..."
          end
        end
      end
    end
  end
end
