#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

node[:sys][:reconverge_list].split(" ").each do |recipe|

  log "  Adding re-converge task for #{recipe}"

  sys_reconverge "Enable recipe re-converge" do
    recipe_name recipe
    action :enable
  end

end if node[:sys]

rightscale_marker :end
