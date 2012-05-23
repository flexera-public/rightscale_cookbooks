#
# Cookbook Name:: repo_svn
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :pull do

  # Setting parameters
  destination_path = new_resource.destination
  repository_url = new_resource.repository
  branch_tag = new_resource.revision
  app_user = new_resource.app_user
  svn_password = new_resource.svn_password
  svn_user = new_resource.svn_username
  params = "--no-auth-cache --non-interactive"

  # If repository already exists, just update it
  if ::File.directory?("#{destination_path}/.svn")
    log "  Svn project repository already exists, updating to latest revision"
    svn_action = :checkout
  else
    ruby_block "Backup of existing project directory" do
      only_if do ::File.directory?(destination_path) end
      block do
        ::File.rename("#{destination_path}", "#{destination_path}"+::Time.now.strftime("%Y%m%d%H%M"))
      end
    end
    log "  Downloading new Svn project repository"
    svn_action = :sync
  end

  # Downloading SVN repository
  subversion "SVN_repo" do
    destination destination_path
    repository repository_url
    revision branch_tag
    user app_user
    svn_arguments params
    svn_username svn_user
    svn_password svn_password
    action svn_action
  end

  log "  SVN repository update/download action - finished successfully!"

end

action :capistrano_pull do

  log "  Preparing to capistrano deploy action. Setting parameters for the process..."
  destination = new_resource.destination
  repository = new_resource.repository
  revision = new_resource.revision
  svn_username = new_resource.svn_username
  svn_password = new_resource.svn_password
  app_user = new_resource.app_user
  purge_before_symlink = new_resource.purge_before_symlink
  create_dirs_before_symlink = new_resource.create_dirs_before_symlink
  symlinks = new_resource.symlinks
  scm_provider = new_resource.provider
  environment = new_resource.environment

  log "  Deploying branch: #{revision} of the #{repository} to #{destination}. New owner #{app_user}"
  log "  Deploy provider #{scm_provider}"

  capistranize_repo "Source repo" do
    repository repository
    destination destination
    revision revision
    svn_username svn_username
    svn_password svn_password
    app_user app_user
    purge_before_symlink purge_before_symlink
    create_dirs_before_symlink create_dirs_before_symlink
    symlinks symlinks
    environment environment
    scm_provider scm_provider
  end

 log "  Capistrano SVN deployment action - finished successfully!"
end
