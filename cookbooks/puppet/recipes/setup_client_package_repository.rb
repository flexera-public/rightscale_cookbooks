#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if node[:platform] =~ /redhat|centos/
  # Installs the Puppet Open Source package repository.
  cookbook_file "/etc/yum.repos.d/puppetlabs.repo" do
    source "puppetlabs.repo"
    mode "0644"
    cookbook "puppet"
  end

  # Installs public key for package verification.
  cookbook_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs" do
    source "RPM-GPG-KEY-puppetlabs"
    cookbook "puppet"
  end

  ruby_block "reload-internal-yum-cache" do
    block do
      Chef::Provider::Package::Yum::YumCache.instance.reload
    end
    action :nothing
  end

  # Updates the list of available packages.
  execute "Updating the list of available packages" do
    command "yum -q makecache"
    notifies :create, "ruby_block[reload-internal-yum-cache]", :immediately
  end

elsif node[:platform] =~ /ubuntu/
  # Installs the Puppet Open Source package repository.
  cookbook_file "/etc/apt/sources.list.d/puppetlabs.list" do
    source "puppetlabs.list"
    mode "0644"
    cookbook "puppet"
  end

  # Installs public key for package verification.
  directory "/etc/apt/trusted.gpg.d"

  cookbook_file "/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg" do
    source "puppetlabs-keyring.gpg"
    cookbook "puppet"
  end

  # Updates the list of available packages.
  execute "Updating the list of available packages" do
    command "sudo apt-get -qq update"
  end
end
