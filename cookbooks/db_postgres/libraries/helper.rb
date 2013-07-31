#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

module RightScale
  module Database
    module PostgreSQL
      module Helper

        require 'timeout'

        # Create new PostgreSQL object
        #
        # @param new_resource [Object] resource which will be initialized
        #
        # @return [PostgreSQL] PostgreSQL object
        #
        def init(new_resource)
          begin
            require 'rightscale_tools'
          rescue LoadError
            Chef::Log.warn "  Missing gem 'rightscale_tools'"
          end
          mount_point = new_resource.name
          RightScale::Tools::Database.factory(
            :postgres,
            new_resource.user,
            new_resource.password,
            mount_point,
            Chef::Log,
            new_resource.timeout
          )
        end

        # Create new PostgreSQL connection
        #
        # @param username [String] system username, default is 'postgres'
        # @param hostname [String] hostname FQDN, default is 'localhost'
        #
        # @return [PostgreSQL] PostgreSQL connection
        #
        def self.get_pgsql_handle(hostname = "localhost", username = "postgres")
          info_msg = "  PostgreSQL connection to #{hostname}"
          info_msg << ": opening NEW PostgreSQL connection."
          Chef::Log.info info_msg
          # PG::Connection.new raises a PG::Error if connection fails.
          PG::Connection.new(hostname, nil, nil, nil, nil, username, nil)
        end

        # Perform sql query to PostgreSQL server
        #
        # @param query [String] query text
        # @param hostname [String] hostname FQDN, default is 'localhost'
        # @param username [String] system username, default is 'postgres'
        # @param timeout [Integer] timeout value for query
        # @param tries [Integer] connection attempts number, default is 1
        #
        # @return [PGresult] query result
        #
        # @raise [TimeoutError] if timeout exceeded
        # @raise [RuntimeError] if connection try attempts limit reached
        #
        def self.do_query(query, hostname = 'localhost', username = 'postgres', timeout = nil, tries = 1)
          require 'rubygems'
          Gem.clear_paths
          require 'pg'

          loop do
            begin
              info_msg = "  Doing SQL Query: HOST=#{hostname}, QUERY=#{query}"
              info_msg << ", TIMEOUT=#{timeout}" if timeout
              info_msg << ", NUM_TRIES=#{tries}" if tries > 1
              Chef::Log.info info_msg
              result = nil
              if timeout
                SystemTimer.timeout_after(timeout) do
                  conn = get_pgsql_handle(hostname, username)
                  result = conn.exec(query)
                end
              else
                conn = get_pgsql_handle(hostname, username)
                result = conn.exec(query)
              end
              return result.getvalue(0, 0) if result
              return result
            rescue Timeout::Error => e
              Chef::Log.info "  Timeout occurred during PostgreSQL query:#{e}"
              tries -= 1
              raise "FATAL: retry count reached" if tries == 0
            end
          end
        end

      end
    end
  end
end
