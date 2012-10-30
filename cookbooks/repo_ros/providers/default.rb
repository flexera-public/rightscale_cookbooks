#
# Cookbook Name:: repo_ros
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Setup repository attributes.
action :setup_attributes do

  # Checking ros_util presence it is required for repo_ros correct operations
  ruby_block "Checking for ros_util presence" do
    block do
      raise "  Error: ROS gem missing, please add rightscale::install_tool recipe to runlist." unless ::File.exists?("/opt/rightscale/sandbox/bin/ros_util")
    end
  end

  # Checking inputs required for getting source from ROS
  raise "  Storage Provider input is unset" unless new_resource.storage_account_provider
  raise "  Storage account provider ID input is unset" unless new_resource.account
  raise "  Storage account secret input is unset" unless new_resource.credential
  raise "  Repo container name input is unset." unless new_resource.repository
end


# Pull code from a determined repository to a specified destination.
action :pull do

  # Checking attributes
  # Calls the :setup_attributes action.
  action_setup_attributes

  log "  Trying to get ros repo from: #{new_resource.storage_account_provider}, bucket: #{new_resource.repository}"

  # Backup project directory if it is not empty
  ruby_block "Backup of existing project directory" do
     block do
       ::File.rename("#{new_resource.destination}", "#{new_resource.destination}_" + ::Time.now.gmtime.strftime("%Y%m%d%H%M"))
     end
     not_if { ::Dir["#{new_resource.destination}/*"].empty? }
  end

  # Ensure that destination directory exists after all backups.
  directory "#{new_resource.destination}"

  # "true" we just put downloaded file into "destination" folder
  # "false" we put downloaded file into /tmp and unpack it into "destination" folder
  if (new_resource.unpack_source == true)
    tmp_repo_path = "/tmp/downloaded_ros_archive.tar.gz"
  else
    tmp_repo_path = "#{new_resource.destination}/downloaded_ros_archive.tar.gz"
  end
  log "  Downloaded file will be available in #{tmp_repo_path}"

  # Obtain the source from ROS
  execute "Download #{new_resource.repository} from Remote Object Store" do
    command "/opt/rightscale/sandbox/bin/ros_util get --cloud #{new_resource.storage_account_provider} --container #{new_resource.repository} --dest #{tmp_repo_path} --source #{new_resource.prefix} --latest"
    environment ({
      'STORAGE_ACCOUNT_ID' => new_resource.account,
      'STORAGE_ACCOUNT_SECRET' => new_resource.credential
    })
  end


  bash "Unpack #{tmp_repo_path} to #{new_resource.destination}" do
    cwd "/tmp"
    code <<-EOH
      tar xzf #{tmp_repo_path} -C #{new_resource.destination}
    EOH
    only_if { (new_resource.unpack_source == true) }
  end

  log "  ROS repo pull action - finished successfully!"
end


# Pull code from a determined repository to a specified destination and create a capistrano-style deployment.
action :capistrano_pull do

  log "  Recreating project directory for :pull action"

  repo_dir = "/home"
  capistrano_dir = "/home/capistrano_repo"

  # Delete if destination is a symlink
  link "#{new_resource.destination}" do
    action :delete
    only_if { ::File.symlink?("#{new_resource.destination}") }
  end

  # If destination directory is not empty AND capistrano folder exists,
  # this mean that this folder is a result of previous user interaction, an error or multiple action changes.
  # We will backup destination directory to capistrano folder and warn user if this is the case.
  ruby_block "Backup old repo" do

    block do
      Chef::Log.info("  Check previous repo in case of action change")
      timestamp  = ::Time.now.gmtime.strftime("%Y%m%d%H%M")
      if ::File.exists?("#{capistrano_dir}")
        ::File.rename("#{new_resource.destination}", "#{capistrano_dir}/releases/_initial_#{timestamp}")
        Chef::Log.info("  Destination directory is not empty. Backup to #{capistrano_dir}/releases/_initial_#{timestamp}")
      else
        ::File.rename("#{new_resource.destination}", "#{new_resource.destination}_#{timestamp}")
        Chef::Log.info("  Destination directory is not empty. Backup to #{new_resource.destination}_#{timestamp}")
      end
    end
    only_if { ::File.exists?("#{new_resource.destination}") and ::Dir["#{new_resource.destination}/*"].empty? == false }

  end

  # Ensure that destination directory exists after all backups and cleanups
  directory "#{new_resource.destination}"

  log "  Pulling source from ROS"
  # Calls the :action_pull action.
  action_pull

  # The embedded chef capistrano resource can work only with git or svn repositories
  # After code download from ROS storage, we will transform this code repository to git type
  # Then we will apply capistrano chef provider
  # After that we will remove all git information from new repo (.git folders)

  # Moving dir with downloaded and unpacked ROS source to temp folder
  # to prepare source for capistrano actions
  bash "Moving #{new_resource.destination} to #{repo_dir}/ros_repo/" do
    cwd "#{repo_dir}"
    code <<-EOH
       mv #{new_resource.destination} #{repo_dir}/ros_repo/
    EOH
  end

  log "  Preparing to capistrano deploy action. Setting parameters for the process..."
  destination = new_resource.destination
  app_user = new_resource.app_user
  purge_before_symlink = new_resource.purge_before_symlink
  create_dirs_before_symlink = new_resource.create_dirs_before_symlink
  symlinks = new_resource.symlinks
  environment = new_resource.environment
  scm_provider = new_resource.provider

  log "  Preparing git transformation"
  directory "#{repo_dir}/ros_repo/.git" do
    recursive true
    action :delete
  end

  # Initialize new git repo with initial commit.
  bash "Git init in project folder" do
    cwd "#{repo_dir}/ros_repo"
    code <<-EOH
      git init
      git add .
      git commit -a -m "fake commit"
    EOH
  end

  log "  Deploying new local git project repo from #{repo_dir}/ros_repo/ to #{destination}. New owner #{app_user}"
  log "  Deploy provider #{scm_provider}"

  # Applying capistrano style deployment
  # See cookbooks/repo/definition/repo_capistranize.rb for the "repo_capistranize" definition.
  repo_capistranize "Source repo" do
    repository "#{repo_dir}/ros_repo/"
    destination destination
    app_user app_user
    purge_before_symlink purge_before_symlink
    create_dirs_before_symlink create_dirs_before_symlink
    symlinks symlinks
    scm_provider scm_provider
    environment  environment
  end

  log "  Cleaning transformation temp files"
  directory "#{repo_dir}/ros_repo/" do
    recursive true
    action :delete
  end

  # Cleaning tmp files
  directory "#{repo_dir}/capistrano_repo/current/.git/" do
    recursive true
    action :delete
  end

  log "  Capistrano ROS deployment action - finished successfully!"
end
