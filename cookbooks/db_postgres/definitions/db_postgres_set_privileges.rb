#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_postgres_set_privileges, :preset => "administrator", :username => nil, :password => nil, :db_name => nil do 


  priv_preset = params[:preset]
  username = params[:username]
  password = params[:password]
  db_name = "*.*"
  db_name = "#{params[:db_name]}.*" if params[:db_name]

  ruby_block "set admin credentials" do
    block do
      require 'rubygems'
      Gem.clear_paths
      require 'pg'
      sleep 20
      conn = PGconn.open("localhost", nil, nil, nil, nil, "postgres", nil)

      # Now that we have a Postgresql object, let's sanitize our inputs. These will get pass for log and comparision.
      username_esc = conn.escape_string(username)
      password_esc = conn.escape_string(password)
      # Following Username and password will get to pass for creation of user.
      username = conn.quote_ident(username_esc)
      password = conn.quote_ident(password_esc)

      case priv_preset

      # Create group roles, don't error out if already created.  Users don't inherit "special" attribs
      # from group role, see: http://www.postgresql.org/docs/9.1/static/role-membership.html
      # cmd ==> createuser -h /var/run/postgresql -U postgres #{admin_role} -sdril
      when 'administrator'
        # Enable admin/replication user
        result = conn.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{username_esc}'")
        userstat = result.getvalue(0,0)
        if ( userstat == '1' )
          Chef::Log.info "  User #{username_esc} already exists, updating user using current inputs"
          conn.exec("ALTER USER #{username} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
        else
          Chef::Log.info "  Creating administrator user #{username_esc}"
          conn.exec("CREATE USER #{username} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
        end

      # Create group roles, don't error out if already created.  Users don't inherit "special" attribs
      # from group role, see: http://www.postgresql.org/docs/9.1/static/role-membership.html
      # cmd ==> createuser -h /var/run/postgresql -U postgres #{user_role} -SdRil
      when 'user'
        # Enable application user
        result = conn.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{username_esc}'")
        userstat = result.getvalue(0,0)
        if ( userstat == '1' )
          Chef::Log.info "  User #{username_esc} already exists, updating user using current inputs"
          conn.exec("ALTER USER #{username} NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
        else
          Chef::Log.info "  Creating application user #{username_esc}"
          conn.exec("CREATE USER #{username} NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
        end

        # Set default privileges for any future tables, sequences, or functions created.
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username} GRANT ALL ON TABLES to #{username}")
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username} GRANT ALL ON SEQUENCES to #{username}")
        conn.exec("ALTER DEFAULT PRIVILEGES FOR USER #{username} GRANT ALL ON FUNCTIONS to #{username}")

      else
        raise "  Only 'administrator' and 'user' type presets are supported!"
      end

      conn.finish
    end
  end

end
