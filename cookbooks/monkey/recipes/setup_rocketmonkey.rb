#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Checking out Rocketmonkey repository from: #{node[:monkey][:rocketmonkey][:repo_url]}"
git "/root/rocketmonkey" do
  repository node[:monkey][:rocketmonkey][:repo_url]
  reference node[:monkey][:rocketmonkey][:repo_branch]
  action :sync
end

log "  Making super sure that we're on the right branch"
execute "git checkout" do
  cwd "/root/rocketmonkey"
  command "git checkout #{node[:monkey][:rocketmonkey][:repo_branch]}"
end

log "  Copy rocketmonkey configuration files"
bash "Copy rocketmonkey configuration files" do
  flags "-ex"
  code <<-EOH
    cd /root/rocketmonkey
    cp googleget.yaml .googleget.yaml
    cp rocketmonkey.yaml .rocketmonkey.yaml
    cp rocketmonkey.clouds.yaml .rocketmonkey.clouds.yaml
    cp rocketmonkey.regexs.yaml .rocketmonkey.regexs.yaml
  EOH
end

log "  Installing required gems for rocketmonkey"
bash "Install required gems for rocketmonkey" do
  flags "-ex"
  code <<-EOH
    cd /root/rocketmonkey
    bundle install --system
  EOH
end

rightscale_marker :end
