#
# Cookbook Name:: repo_git
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Setup repository URL and other attributes.
action :setup_attributes do

  branch = new_resource.revision
  repository_url = new_resource.repository

  # Checking branch
  if branch.empty?
    log "  Warning: branch/tag input is empty, switching to 'master' branch"
    branch = "master"
    new_resource.revision branch
  end

  # Checking repository URL
  raise "  ERROR: repository input is unset. Please fill 'Repository URL' input" if repository_url.empty?
end


# Pull code from a determined repository to a specified destination.
action :pull do

  capistrano_dir = "/home/capistrano_repo"
  ruby_block "Before pull" do
    block do
      Chef::Log.info "  Check for previous capistrano repository in case of action change"
      if (::File.exists?("#{new_resource.destination}") == true && ::File.symlink?("#{new_resource.destination}") == true && ::File.exists?("#{capistrano_dir}") == true)
        ::File.rename("#{new_resource.destination}", "#{capistrano_dir}/releases/capistrano_old_"+::Time.now.strftime("%Y%m%d%H%M"))
      end
      # Add ssh key and exec script
      # See cookbooks/repo_git/libraries/default.rb for the "create" method.
      RightScale::Repo::GitSshKey.new.create(new_resource.credential, new_resource.ssh_host_key)
    end
  end

  # Checking attributes
  # Calls the :setup_attributes action.
  action_setup_attributes

  destination = new_resource.destination
  repository_url = new_resource.repository
  revision = new_resource.revision
  app_user = new_resource.app_user

  # If repository already exists, just update it
  if ::File.directory?("#{destination}/.git")
    log "  Git project repository already exists, updating to latest revision"
    git_action = :sync
  else
    ruby_block "Backup of existing project directory" do
      only_if { ::File.directory?(destination) }
      block do
        ::File.rename(destination.sub(/\/+$/, ''), destination.sub(/\/+$/, '') + ::Time.now.strftime("%Y%m%d%H%M"))
      end
    end
    log "  Downloading new Git project repository"
    git_action = :checkout
  end

  git "#{destination}" do
    repository repository_url
    reference revision
    user app_user
    enable_submodules true
    action git_action
  end

  # Delete SSH key & clear GIT_SSH
  ruby_block "After pull" do
    block do
      # See cookbooks/repo_git/libraries/default.rb for the "delete" method.
      RightScale::Repo::GitSshKey.new.delete
    end
  end

  log "  GIT repository update/download action - finished successfully!"
end


# Pull code from a determined repository to a specified destination and create a capistrano-style deployment.
action :capistrano_pull do

  # Add ssh key and exec script
  ruby_block "Before deploy" do
    block do
      # See cookbooks/repo_git/libraries/default.rb for the "create" method.
       RightScale::Repo::GitSshKey.new.create(new_resource.credential, new_resource.ssh_host_key)
    end
  end

  # Checking attributes
  # Calls the :setup_attributes action.
  action_setup_attributes

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

  log "  Deploying branch: #{revision} of the #{repository} to #{destination}. New owner #{app_user}"
  log "  Deploy provider #{scm_provider}"

  # Applying capistrano style deployment
  # See cookbooks/repo/definition/repo_capistranize.rb for the "repo_capistranize" definition.
  repo_capistranize "Source repo" do
    repository repository
    revision revision
    destination destination
    app_user app_user
    purge_before_symlink purge_before_symlink
    create_dirs_before_symlink create_dirs_before_symlink
    symlinks symlinks
    scm_provider scm_provider
    environment environment
  end

  # Delete SSH key & clear GIT_SSH
  ruby_block "After deploy" do
    block do
      # See cookbooks/repo_git/libraries/default.rb for the "delete" method.
      RightScale::Repo::GitSshKey.new.delete
    end
  end

  log "  Capistrano GIT deployment action - finished successfully!"
end
