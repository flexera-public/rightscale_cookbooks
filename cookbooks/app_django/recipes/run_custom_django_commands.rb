#
# Cookbook Name::app_django
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Run specific to application user defined commands
# for example  manage.py syncdb or manage.py migrate
#
# Variable node[:app_django][:project][:custom_cmd] contains comma separated list of commands along
# in the format:
#
#   command1, command2
#

log "  Running user defined commands"
bash "run commands" do
  flags "-ex"
  cwd "#{node[:app][:destination]}/"
  code <<-EOH
    IFS=,  read -a ARRAY1 <<< "#{node[:app_django][:project][:custom_cmd]}"
    for i in "${ARRAY1[@]}"
    do
      tmp=`echo $i | sed 's/^[ \t]*//'`
      #{node[:app_django][:python_bin]} $tmp
    done
  EOH
  only_if { node[:app_django][:project][:custom_cmd] != "" }
end

rightscale_marker :end
