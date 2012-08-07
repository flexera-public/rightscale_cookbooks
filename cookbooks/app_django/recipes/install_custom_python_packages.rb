#
# Cookbook Name::app_django
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Install specified python packages

# Variable node[:app_django][:project][:opt_pip_list] contains space separated list of Python packages along
# with their versions in the format:
#
#   py-pkg1==version  py-pkg2==version py-pkg3==version
#
log "  Installing user specified python packages:"
ruby_block "Install custom python packages" do
  block do

    pip_list = node[:app_django][:project][:opt_pip_list]

    # Split pip_list into an array
    pip_list = pip_list.split
    # Installing python packages
    pip_list.each do |pip_name|
      begin
        if pip_name =~ /(.+)==([\d\.]{2,})/
          name = "#{$1}==#{$2}"
        else
          name = pip_name
        end
      end
      raise "Error installing python packages!" unless
      system("#{node[:app_django][:pip_bin].chomp} install #{name}")
    end

  end
   only_if do (node[:app_django][:project][:opt_pip_list]!="") end
end

rightscale_marker :end
