#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Installing bundler
gem_package "bundler" do
  gem_binary "#{node[:app_passenger][:gem_bin]}"
end

# Installing gems using bundler
#
# If the checked application contains a Gemfile, then we can install all
# the required gems using "bundle install" command.
#
log "  Bundler will install gems from Gemfile"
# Installing gems from /Gemfile if it exists
bash "Bundle gem install" do
  flags "-ex"
  code <<-EOH
    /usr/bin/bundle install --gemfile=#{node[:app][:destination]}/Gemfile
  EOH
  only_if do File.exists?("#{node[:app][:destination]}/Gemfile")  end
end

rightscale_marker :end
