#
# Cookbook Name:: repo_git
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# @resource Chef::Resource::Repo

action :pull do

  capistrano_dir="/home/capistrano_repo"
  ruby_block "Before pull" do
    block do
      Chef::Log.info "  Check for previous capistrano repository in case of action change"
      if (::File.exists?("#{new_resource.destination}") == true && ::File.symlink?("#{new_resource.destination}") == true && ::File.exists?("#{capistrano_dir}") == true)
        ::File.rename("#{new_resource.destination}", "#{capistrano_dir}/releases/capistrano_old_"+::Time.now.strftime("%Y%m%d%H%M"))
      end
      # Add ssh key and exec script
      RightScale::Repo::Ssh_key.new.create(new_resource.git_ssh_key)
    end
  end

  destination = new_resource.destination
  repository_url = new_resource.repository
  revision = new_resource.revision
  app_user = new_resource.app_user
  raise "  ERROR: repo URL input is unset. Please fill 'Repository Url' input" if repository_url.empty?

  # If repository already exists, just update it
  if ::File.directory?("#{destination}/.git")
    log "  Git project repository already exists, updating to latest revision"
    git_action = :checkout
  else
    ruby_block "Backup of existing project directory" do
      only_if do ::File.directory?(destination) end
      block do
        ::File.rename(destination.sub(/\/+$/,''), destination.sub(/\/+$/,'') + ::Time.now.strftime("%Y%m%d%H%M"))
      end
    end
    log "  Downloading new Git project repository"
    git_action = :sync
  end

  git "#{destination}" do
    repository repository_url
    reference revision
    user app_user
    action git_action
  end

  # Delete SSH key & clear GIT_SSH
  ruby_block "After pull" do
    block do
      RightScale::Repo::Ssh_key.new.delete
    end
  end

  log "  GIT repository update/download action - finished successfully!"
end

action :capistrano_pull do

  # Add ssh key and exec script
  ruby_block "Before deploy" do
    block do
       RightScale::Repo::Ssh_key.new.create(new_resource.git_ssh_key)
    end
  end

  log "  Preparing to capistrano deploy action. Setting parameters for the process..."
  destination = new_resource.destination
  repository = new_resource.repository
  revision = new_resource.revision
  app_user = new_resource.app_user
  purge_before_symlink = new_resource.purge_before_symlink
  create_dirs_before_symlink = new_resource.create_dirs_before_symlink
  symlinks = new_resource.symlinks
  scm_provider = new_resource.provider
  environment = new_resource.environment
  raise "  ERROR: repo URL input is unset. Please fill 'Repository Url' input" if repository.empty?
  log "  Deploying branch: #{revision} of the #{repository} to #{destination}. New owner #{app_user}"
  log "  Deploy provider #{scm_provider}"

  # Applying capistrano style deployment
  capistranize_repo "Source repo" do
    repository                 repository
    revision                   revision
    destination                destination
    app_user                   app_user
    purge_before_symlink       purge_before_symlink
    create_dirs_before_symlink create_dirs_before_symlink
    symlinks                   symlinks
    scm_provider               scm_provider
    environment                environment
  end

  # Delete SSH key & clear GIT_SSH
  ruby_block "After deploy" do
    block do
      RightScale::Repo::Ssh_key.new.delete
    end
  end

  log "  Capistrano GIT deployment action - finished successfully!"
end
