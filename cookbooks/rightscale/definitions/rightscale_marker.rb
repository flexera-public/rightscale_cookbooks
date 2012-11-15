#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Marks the beginning and end of a Chef recipe converge in RightScale Audit Entries and logs.
#
# @param [String, Symbol] name The marker to use; can be +:begin+ or +:end+. Also, +:start+ and +:stop+ will work.
define :rightscale_marker do

  recipe_name = "#{self.cookbook_name}" + "::" + "#{self.recipe_name}"

  location = params[:name] ? params[:name] : "start"

  case location.to_s
  when /^(start|begin)$/
    # We use Chef::Log.info here to get clear output
    ruby_block "log marker" do
      block do
        Chef::Log.info "********************************************************************************"
        Chef::Log.info "*RS>  Running recipe #{recipe_name}   ****"
      end
    end
  when /^(stop|end)$/
    # Do nothing
  else
    Chef::Log.warn "unknown marker (#{location})"
  end

end
