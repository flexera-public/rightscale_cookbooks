if node[:jenkins][:attach_slave_at_boot] == "true"
	log " Attaching to master node at boot..."
  include_recipe "jenkins::do_attach_request"
else
  log "  Attach slave at boot [skipped]"
end