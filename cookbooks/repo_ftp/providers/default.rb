#
# Cookbook Name:: repo_ftp
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :setup_attributes do

  # Checking inputs required for getting source from FTP
  raise "  FTP username input is unset" unless new_resource.ftp_user
  raise "  FTP password input is unset" unless new_resource.ftp_password

end

action :pull do

  # Checking attributes
  action_setup_attributes

  log "  Trying to get data from #{new_resource.repository}"

  # Backup project directory if it is not empty
  ruby_block "Backup of existing project directory" do
    block do
      ::File.rename("#{new_resource.destination}", "#{new_resource.destination}_" + ::Time.now.gmtime.strftime("%Y%m%d%H%M"))
    end
    not_if { ::Dir["#{new_resource.destination}/*"].empty? }
  end

  # Ensure that destination directory exists after all backups.
  directory "#{new_resource.destination}"

  # Workaround for wget not to create redundant hierarchy
  level = new_resource.repository[/^(ftp:\/\/)?(.+)/][$2].split('/').length - 1

  # Get the data
  execute "Download #{new_resource.container}" do
    command "wget #{new_resource.repository} --ftp-user=#{new_resource.ftp_user} --ftp-password=#{new_resource.ftp_password} -r -nH --cut-dirs=#{level} -P #{new_resource.destination}"
  end

  log "  Data fetch finished successfully!"
end


action :capistrano_pull do

  log "  Recreating project directory for :pull action"

  repo_dir="/home"
  capistrano_dir="/home/capistrano_repo"

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

  log "  Fetching data..."
  action_pull

  # The embedded chef capistrano resource can work only with git or svn repositories
  # After code download, we will transform this code repository to git type
  # Then we will apply capistrano chef provider
  # After that we will remove all git information from new repo (.git folders)

  # Moving dir with downloaded data to temp folder to prepare source for capistrano actions
  bash "Moving #{new_resource.destination} to #{repo_dir}/repo/" do
    cwd "#{repo_dir}"
    code <<-EOH
       mv #{new_resource.destination} #{repo_dir}/repo/
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
  directory "#{repo_dir}/repo/.git" do
    recursive true
    action :delete
  end

  #initialisation of new git repo with initial commit
  bash "Git init in project folder" do
    cwd "#{repo_dir}/repo"
    code <<-EOH
      git init
      git add .
      git commit -a -m "fake commit"
    EOH
  end

  log "  Deploying new local git project repo from #{repo_dir}/repo/ to #{destination}. New owner #{app_user}"
  log "  Deploy provider #{scm_provider}"

  # Applying capistrano style deployment
  repo_capistranize "Source repo" do
    repository "#{repo_dir}/repo/"
    destination destination
    app_user app_user
    purge_before_symlink purge_before_symlink
    create_dirs_before_symlink create_dirs_before_symlink
    symlinks symlinks
    scm_provider scm_provider
    environment  environment
  end

  log "  Cleaning transformation temp files"
  directory "#{repo_dir}/repo/" do
    recursive true
    action :delete
  end

  # Cleaning tmp files
  directory "#{repo_dir}/capistrano_repo/current/.git/" do
    recursive true
    action :delete
  end

  log "  Capistrano deployment action - finished successfully!"
end