#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Sets privileges for MySQL database.
#
# @param preset [String] Default privilege
# @param username [String] Privilege username
# @param password [String] Privilege password
# @param db_name [String] Database name
#
define :db_mysql_set_privileges,
  :preset => "administrator",
  :username => nil,
  :password => nil,
  :db_name => nil do

  priv_preset = params[:preset]
  username = params[:username]
  password = params[:password]
  db_name = "*.*"
  db_name = "#{params[:db_name]}.*" if params[:db_name]

  # The list of all privileges applicable in a non global scope. I.E. dbname.*
  priv_list = [
    "SELECT", "INSERT", "UPDATE", "DELETE", "CREATE", "DROP", "REFERENCES",
    "INDEX", "ALTER", "CREATE TEMPORARY TABLES", "LOCK TABLES", "EXECUTE",
    "CREATE VIEW", "SHOW VIEW", "CREATE ROUTINE", "ALTER ROUTINE", "EVENT",
    "TRIGGER"
  ]

  # The list of all privileges applicable only for *.* or "global"
  global_priv_list = [
    "RELOAD", "SHUTDOWN", "PROCESS", "FILE", "SHOW DATABASES",
    "REPLICATION SLAVE", "REPLICATION CLIENT", "CREATE USER"
  ]


  ruby_block "set #{priv_preset} credentials for #{username} on #{db_name}" do
    block do
      require 'rubygems'
      require 'mysql'

      con = Mysql.new("", "root", nil, nil, nil, "#{node[:db][:socket]}")

      # Now that we have a Mysql object, let's sanitize our inputs
      username = con.escape_string(username)
      password = con.escape_string(password)

      case priv_preset
      when 'administrator'
        query = "GRANT ALL PRIVILEGES on *.* TO '#{username}'@'%'" +
          " IDENTIFIED BY '#{password}' WITH GRANT OPTION"
        con.query(query)

        query = "GRANT ALL PRIVILEGES on *.* TO '#{username}'@'localhost'" +
          " IDENTIFIED BY '#{password}' WITH GRANT OPTION"
        con.query(query)
      when 'user'
        # Grant only the appropriate privileges
        privs = priv_list
        privs << global_priv_list if db_name == "*.*"
        query = "GRANT #{privs.join(',')} on #{db_name} TO '#{username}'@'%'" +
          " IDENTIFIED BY '#{password}'"
        con.query(query)

        query = "GRANT #{privs.join(',')} on #{db_name} TO " +
          "'#{username}'@'localhost' IDENTIFIED BY '#{password}'"
        con.query(query)
      else
        raise "only 'administrator' and 'user' type presets are supported!"
      end

      con.query("FLUSH PRIVILEGES")
      con.close
    end
  end

end
