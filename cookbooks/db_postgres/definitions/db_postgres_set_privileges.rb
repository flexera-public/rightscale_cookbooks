#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Sets privileges for Postgres database.
#
# @param preset [String] privilege to be set
# @param username [String] username for the database
# @param password [String] password for the database
#
define :db_postgres_set_privileges, :preset => "administrator", :username => nil, :password => nil do


  priv_preset = params[:preset]
  username = params[:username]
  password = params[:password]

  ruby_block "set admin credentials" do
    block do
      require 'rubygems'
      Gem.clear_paths
      require 'pg'
      sleep 20
      conn = PGconn.open("localhost", nil, nil, nil, nil, "postgres", nil)

      # Now that we have a Postgresql object, let's sanitize our inputs. These will get pass for log and comparison.
      username_esc = conn.escape_string(username)
      password_esc = conn.escape_string(password)

      # Create group roles, don't error out if already created.  Users don't inherit "special" attributes
      # from group role, see: http://www.postgresql.org/docs/9.1/static/role-membership.html
      case priv_preset
      when 'administrator'
        # cmd ==> createuser -U postgres #{admin_role} -sdril
        # Enable admin/replication user
        result = conn.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{username_esc}'")
        userstat = result.getvalue(0, 0)
        if (userstat == '1')
          Chef::Log.info "  User '#{username_esc}' already exists, updating" +
            " user using current inputs"
          conn.exec("ALTER USER #{username_esc} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password_esc}'")
        else
          Chef::Log.info "  Creating administrator user '#{username_esc}'"
          conn.exec("CREATE USER #{username_esc} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password_esc}'")
        end

      when 'user'
        # cmd ==> createuser -U postgres #{user_role} -SdRil
        # Enable application user
        result = conn.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{username_esc}'")
        userstat = result.getvalue(0, 0)
        if (userstat == '1')
          Chef::Log.info "  User '#{username_esc}' already exists, updating" +
            " user using current inputs"
          conn.exec("ALTER USER #{username_esc} NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password_esc}'")
        else
          Chef::Log.info "  Creating application user '#{username_esc}'"
          conn.exec("CREATE USER #{username_esc} NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password_esc}'")
        end

        # Set default privileges for any future tables, sequences, or functions created.
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username_esc} GRANT ALL ON TABLES to #{username_esc}")
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username_esc} GRANT ALL ON SEQUENCES to #{username_esc}")
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username_esc} GRANT ALL ON FUNCTIONS to #{username_esc}")

      else
        raise "  Only 'administrator' and 'user' type presets are supported!"
      end

      conn.finish
    end
  end

end
