#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This is an adaptation of Opscode "deploy" resource to be used with RightScale repository LWRPs:
# cookbooks/repo, cookbooks/repo_git, cookbooks/repo_ros, cookbooks/repo_svn

capistrano_dir="/home/capistrano_repo"
# More detailed parameters descriptions you can find in repo/resources/default.rb
define :repo_capistranize,
  :destination => "",
  :repository => "",
  :revision => "",
  :svn_username => "",
  :svn_password => "",
  :app_user => "",
  :environment => ({}),
  :create_dirs_before_symlink => %w{},
  :purge_before_symlink => %w{},
  :symlinks => ({}),
  :scm_provider => "" do

  log "  Capistrano deployment creation - in progress..."

  # Looking for old deployments and backup them if found any
  ruby_block "Before deploy" do
    block do
      Chef::Log.info("  Checking for previous project repository in case of action change")
      if (::File.exists?("#{params[:destination]}") == true && ::File.symlink?("#{params[:destination]}") == false)
        ::File.rename("#{params[:destination]}", "#{params[:destination]}_old")
      elsif (::File.exists?("#{params[:destination]}") == true && ::File.symlink?("#{params[:destination]}") == true && ::File.exists?("#{capistrano_dir}") == false)
        ::File.rename("#{params[:destination]}", "#{params[:destination]}_old")
      end
    end
  end

  # Creating /shared folder which is required by Opscode "deploy" resource
  directory "#{capistrano_dir}/shared/" do
    recursive true
  end

  # Deleting /cached-copy dir which can contain previous version of project repository
  #  Can cause definition fail in case of provider type change.
  directory "#{capistrano_dir}/shared/cached-copy" do
    recursive true
    action :delete
  end

  # Preparing "deploy" provider and its attributes
  if params[:scm_provider] == Chef::Provider::RepoSvn
    scm_prov = Chef::Provider::Subversion
    svn_args = "--no-auth-cache --non-interactive"
    enable_submodules = false
  else
    scm_prov = Chef::Provider::Git
    svn_args = nil
    params[:svn_username] = nil
    params[:svn_password] = nil
    enable_submodules = true
  end

  log "  Capistrano deployment will use #{scm_prov} for initialization"
  # Creating capistrano deployment
  deploy "#{capistrano_dir}" do
    scm_provider scm_prov
    repo "#{params[:repository].chomp}"
    revision params[:revision]
    svn_username params[:svn_username]
    svn_password params[:svn_password]
    svn_arguments svn_args
    enable_submodules enable_submodules
    shallow_clone false
    user params[:app_user]
    migrate false
    purge_before_symlink params[:purge_before_symlink]
    create_dirs_before_symlink params[:create_dirs_before_symlink]
    symlink_before_migrate ({})
    symlinks params[:symlinks]
    action :deploy
    environment params[:environment]
  end

  log "  Capistrano deployment created.  Performing secondary operations"
  # Removing old symlinks from project folder
  link params[:destination] do
    action :delete
    only_if "test -L #{params[:destination].chomp}"
  end

  # Recreating symlinks and perform backup of old project directories
  #  To avoid problems from using different provider types
  ruby_block "After deploy" do
    block do
      Chef::Log.info("  Perform backup of old deployment directory to #{capistrano_dir}/releases/ ")
      system("data=`/bin/date +%Y%m%d%H%M%S` && mv #{params[:destination]}_old #{capistrano_dir}/releases/${data}_initial")

      repo_dest = params[:destination]
      # Checking last symbol of "destination" for correct work of "cp -d"
      if (params[:destination].end_with?("/"))
        repo_dest = params[:destination].chop
      end

      Chef::Log.info("  linking #{capistrano_dir}/current/ directory to project root -  #{repo_dest}")
      system("cp -d #{capistrano_dir}/current #{repo_dest}")
    end

  end

end
