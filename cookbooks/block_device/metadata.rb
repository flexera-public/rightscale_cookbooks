maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures block device storage."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "rightscale"

recipe "block_device::default", "Sets up input dependencies for use by other cookbooks."
recipe "block_device::setup_block_device", "Creates, formats, and mounts a brand new block device on the instance."
recipe "block_device::setup_ephemeral", "Creates, formats, and mounts a brand new block device on the instance's ephemeral drives. Does nothing on clouds without ephemeral drives."

recipe "block_device::do_primary_backup", :description => "Creates a primary backup in the local cloud where the server is currently running.", :thread => 'block_backup'
recipe "block_device::do_primary_restore","Restores a primary backup from the local cloud where the server is currently running."

recipe "block_device::do_secondary_backup", :description => "Creates a secondary backup to the remote cloud specified by block_device/secondary provider", :thread => 'block_backup'
recipe "block_device::do_secondary_restore","Restores a secondary backup from the remote cloud specified by block_device/secondary provider."

recipe "block_device::do_primary_backup_schedule_enable", "Enables continuous primary backups by updating the crontab file."
recipe "block_device::do_primary_backup_schedule_disable", "Disables continuous primary backups by updating the crontab file."

recipe "block_device::do_delete_volumes_and_terminate_server", "Deletes any currently attached volumes from the instance and then terminates the machine. WARNING: Execution of this script will delete any data on your block device!"

recipe "block_device::do_force_reset", "Unmount and delete the attached block device(s) for this lineage. Designed for test and development purposes only. WARNING: Execution of this script will delete any data on your block device!"

# all recipes EXCEPT for block_device::default which is used to "export" inputs to other cookbooks.
all_recipes = [
  "block_device::do_primary_backup",
  "block_device::do_primary_restore",
  "block_device::do_secondary_backup",
  "block_device::do_secondary_restore",
  "block_device::do_primary_backup_schedule_enable",
  "block_device::do_primary_backup_schedule_disable",
  "block_device::setup_block_device",
  "block_device::do_force_reset"
]

restore_recipes = [
  "block_device::do_primary_restore",
  "block_device::do_secondary_restore"
]

backup_recipes = [
  "block_device::do_primary_backup_schedule_enable",
  "block_device::do_primary_backup",
  "block_device::do_secondary_backup"
]

# ROS cloud type choices
ros_clouds = [
  "s3",
  "cloudfiles",
  "cloudfilesuk",
  "google",
  "azure",
  "swift",
  "SoftLayer_Dallas",
  "SoftLayer_Singapore",
  "SoftLayer_Amsterdam"
]

attribute "block_device/devices_to_use",
  :display_name => "Block Device(s) to Operate On",
  :description => "The block device(s) to operate on. Can be a comma-separated list of device names or '*' to indicate all devices. Example: device1",
  :required => "recommended",
  :default => "device1",
  :recipes => all_recipes

# Block Device Defaults
grouping "block_device/devices/default",
  :title => "Block Device Defaults",
  :description => "Default attributes for all block devices."

attribute "block_device/devices/default/backup/primary/cred/user",
  :display_name => "Primary Backup User (default)",
  :description => "Primary cloud authentication credentials. For Rackspace Cloud Files, use your Rackspace login username (e.g., cred:RACKSPACE_USERNAME). For clouds that do not require primary credentials (e.g., Amazon), set to 'ignore'.",
  :required => "recommended",
  :default => "",
  :recipes => [ "block_device::default" ]

attribute "block_device/devices/default/backup/primary/cred/secret",
  :display_name => "Primary Backup Secret (default)",
  :description => "Primary cloud authentication credentials. For Rackspace Cloud Files, use your Rackspace account API key (e.g., cred:RACKSPACE_AUTH_KEY). For clouds that do not require primary credentials (e.g., Amazon), set to 'ignore'.",
  :required => "recommended",
  :default => "",
  :recipes => [ "block_device::default" ]

attribute "block_device/devices/default/backup/primary/cloud",
  :display_name => "Primary Backup Storage Cloud (default)",
  :description => "The primary backup storage cloud. This is only used if the server's cloud does not have volume support.",
  :required => "optional",
  :choice => ros_clouds,
  :default => "",
  :recipes => [ "block_device::default" ]

attribute "block_device/devices/default/backup/primary/endpoint",
  :display_name => "Primary Backup Storage Cloud Endpoint URL (default)",
  :description => "The endpoint URL for the primary backup storage cloud. This is used to override the default endpoint or for generic storage clouds such as Swift.",
  :required => "optional",
  :default => "",
  :recipes => [ "block_device::default" ]

attribute "block_device/devices/default/backup/secondary/cred/user",
  :display_name => "Secondary Backup User (default)",
  :description => "Secondary cloud authentication credentials. For Rackspace Cloud Files, use your Rackspace login username (e.g., cred:RACKSPACE_USERNAME). For Amazon S3, use your Amazon key ID (e.g., cred:AWS_ACCESS_KEY_ID).",
  :required => "recommended",
  :default => "",
  :recipes => [ "block_device::default", "block_device::do_secondary_backup", "block_device::do_secondary_restore" ]

attribute "block_device/devices/default/backup/secondary/cred/secret",
  :display_name => "Secondary Backup Secret (default)",
  :description => "Secondary cloud authentication credentials. For Rackspace Cloud Files, use your Rackspace account API key (e.g., cred:RACKSPACE_AUTH_KEY). For Amazon S3, use your Amazon secret key (e.g., cred:AWS_SECRET_ACCESS_KEY).",
  :required => "recommended",
  :default => "",
  :recipes => [ "block_device::default", "block_device::do_secondary_backup", "block_device::do_secondary_restore" ]

attribute "block_device/devices/default/backup/secondary/cloud",
  :display_name => "Secondary Backup Storage Cloud (default)",
  :description => "The secondary backup storage cloud. Specify 'S3' for Amazon, and 'cloudfiles' for Rackspace.",
  :required => "recommended",
  :choice => ros_clouds,
  :default => "",
  :recipes => [ "block_device::default", "block_device::do_secondary_backup", "block_device::do_secondary_restore" ]

attribute "block_device/devices/default/backup/secondary/endpoint",
  :display_name => "Secondary Backup Storage Cloud Endpoint URL (default)",
  :description => "The endpoint URL for the secondary backup storage cloud. This is used to override the default endpoint or for generic storage clouds such as Swift.",
  :required => "optional",
  :default => "",
  :recipes => [ "block_device::default", "block_device::do_secondary_backup", "block_device::do_secondary_restore" ]

attribute "block_device/devices/default/backup/rackspace_snet",
  :display_name => "Rackspace SNET Enabled for Backup",
  :description => "When 'true', Rackspace internal private networking (preferred) is used for communications between servers and Rackspace Cloud Files. Ignored for all other clouds.",
  :type => "string",
  :required => "optional",
  :choice => ["true", "false"],
  :default => "true",
  :recipes => [ "block_device::default" ] + backup_recipes + restore_recipes

# Multiple Block Devices
device_count = 2
devices = 1.upto(device_count).map {|number| "device#{number}"}

# Set up the block device attributes for each device
devices.sort.each_with_index.map do |device, index|
  [device, index + 1]
end.each do |device, number|
  grouping "block_device/devices/#{device}",
    :title => "Block Device #{number}",
    :description => "Attributes for the block device: #{device}."

  attribute "block_device/devices/#{device}/stripe_count",
    :display_name => "Number of Volumes in the Stripe (#{number})",
    :description => "The total number of volumes in the volume stripe that will be used by the database. Volumes will be created and mounted to the instance. The default value is 1, which means that only a single volume will be used (no striping). This value is ignored on clouds that do not support volumes (e.g., Rackspace).",
    :required => device != 'device2' ? 'recommended' : 'optional',
    :default => "1",
    :recipes => [ "block_device::setup_block_device", "block_device::default" ]

  attribute "block_device/devices/#{device}/volume_size",
    :display_name => "Total Volume Size (#{number})",
    :description => "Defines the total size of the LVM volume stripe set (in GB). For example, if the stripe_count is '3' and you specify '3' for this input, it will create an LVM volume stripe that contains 3 volumes that are each 1 GB in size. If an uneven ratio is defined, volume sizes will be rounded up to the nearest whole integer. Ignored on clouds that do not support volumes (e.g., Rackspace).",
    :required => device != 'device2' ? 'recommended' : 'optional',
    :default => "10",
    :recipes => [ "block_device::setup_block_device", "block_device::default" ]

  attribute "block_device/devices/#{device}/backup/lineage",
    :display_name => "Backup Lineage (#{number})",
    :description => "The name associated with your primary and secondary database backups. It's used to associate them with your database environment for maintenance, restore, and replication purposes. Backup snapshots will automatically be tagged with this value (e.g. rs_backup:lineage=mysqlbackup). Backups are identified by their lineage name. Note: For servers running on Rackspace, this value also indicates the Cloud Files container to use for storing primary backups. If a Cloud Files container with this name does not already exist, one will automatically be created.",
    :required => device != 'device2' ? 'required' : 'optional',
    :recipes => backup_recipes + restore_recipes

  attribute "block_device/devices/#{device}/nickname",
    :display_name => "Nickname (#{number})",
    :description => "The name displayed in the dashboard for volumes and to uniquely identify LVM volume groups.",
    :required => device != 'device2' ? 'recommended' : 'optional',
    :default => "data_storage#{number}",
    :recipes => [ "block_device::default" ]

  attribute "block_device/devices/#{device}/backup/lineage_override",
    :display_name => "Backup Lineage Override",
    :description => "If defined, this will override the input defined for 'Backup Lineage' (block_device/devices/#{device}/backup/lineage) so that you can restore the volume from another backup that has as a different lineage name. The most recently completed snapshots will be used unless a specific timestamp value is specified for 'Restore Timestamp Override' (block_device/devices/#{device}/backup/timestamp_override). ",
    :required => "optional",
    :default => "",
    :recipes => restore_recipes

  attribute "block_device/devices/#{device}/backup/timestamp_override",
    :display_name => "Backup Restore Timestamp Override (#{number})",
    :description => "Another optional variable to restore from a specific timestamp. Specify a string matching the timestamp tags on the volume snapshot set. You will need to specify the timestamp that's defined by the snapshot's tag (not name). For example, if the snapshot's tag is 'rs_backup:timestamp=1303613371' you would specify '1303613371' for this input.",
    :required => "optional",
    :default => "",
    :recipes => restore_recipes

  attribute "block_device/devices/#{device}/backup/primary/cron/minute",
    :display_name => "Backup Cron Minute (#{number})",
    :description => "Defines the minute of the hour when the backup will be taken. Use a value of 1-59, or set to 'Ignore' and a random minute will be calculated.",
    :required => "optional",
    :default => "",
    :recipes => [ "block_device::do_primary_backup_schedule_enable" ]

  attribute "block_device/devices/#{device}/backup/primary/cron/hour",
    :display_name => "Backup Cron Hour (#{number})",
    :description => "Defines the hour when the backup will be taken. Use a value of 1-24, or set to 'Ignore' to create a backup every hour.",
    :required => "optional",
    :default => "",
    :recipes => [ "block_device::do_primary_backup_schedule_enable" ]

  attribute "block_device/devices/#{device}/backup/primary/keep/max_snapshots",
    :display_name => "Backup Max Snapshots (#{number})",
    :description => "The maximum number of primary backups to keep in addition to those being rotated.",
    :required => "optional",
    :default => "60",
    :recipes => [ "block_device::default" ]

  attribute "block_device/devices/#{device}/backup/primary/keep/daily",
    :display_name => "Keep Daily Backups (#{number})",
    :description => "The number of daily primary backups to keep (i.e., rotation size).",
    :required => "optional",
    :default => "14",
    :recipes => backup_recipes + [ "block_device::default" ]

  attribute "block_device/devices/#{device}/backup/primary/keep/weekly",
    :display_name => "Keep Weekly Backups (#{number})",
    :description => "The number of weekly primary backups to keep (i.e., rotation size).",
    :required => "optional",
    :default => "6",
    :recipes => backup_recipes + [ "block_device::default" ]

  attribute "block_device/devices/#{device}/backup/primary/keep/monthly",
    :display_name => "Keep Monthly Backups (#{number})",
    :description => "The number of monthly primary backups to keep (i.e., rotation size).",
    :required => "optional",
    :default => "12",
    :recipes => backup_recipes + [ "block_device::default" ]

  attribute "block_device/devices/#{device}/backup/primary/keep/yearly",
    :display_name => "Keep Yearly Backups (#{number})",
    :description => "The number of yearly primary backups to keep (i.e., rotation size).",
    :required => "optional",
    :default => "2",
    :recipes => backup_recipes + [ "block_device::default" ]

  attribute "block_device/devices/#{device}/backup/secondary/container",
    :display_name => "Secondary Backup Storage Container (#{number})",
    :description => "The secondary backup storage container where the backup will be saved to or restored from. For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name.",
    :required => device != 'device2' ? 'recommended' : 'optional',
    :default => "",
    :recipes => [ "block_device::default", "block_device::do_secondary_backup", "block_device::do_secondary_restore" ]

  attribute "block_device/devices/#{device}/mount_point",
    :display_name => "Block Device Mount Directory (#{number})",
    :description => "The directory of where to mount the block device (e.g., /mnt/storage).",
    :type => "string",
    :required => device != 'device2' ? 'recommended' : 'optional',
    :default => "/mnt/storage#{number}",
    :recipes => [ "block_device::setup_block_device", "block_device::default" ]

  attribute "block_device/devices/#{device}/vg_data_percentage",
    :display_name => "Percentage of the LVM used for data (#{number})",
    :description => "The percentage of the total Volume Group extents (LVM) that is used for data. (e.g. 50 percent - 1/2 used for data and remainder used for overhead and snapshots, 100 percent - all space is allocated for data (therefore snapshots can not be taken) WARNING: If the space used for data storage is too large, LVM snapshots cannot be performed. Using a non-default value it not reccommended. Make sure you understand what you are doing before changing this value.",
    :type => "string",
    :required => 'optional',
    :choice => ["50", "60", "70", "80", "90", "100"],
    :default => "90",
    :recipes => [ "block_device::setup_block_device", "block_device::default" ]

  attribute "block_device/devices/#{device}/iops",
    :display_name => "I/O Operations per Second (#{number})",
    :description => "The input/output operations per second (IOPS) that the volue can support. IOPS is currently only supported on Amazon EC2. Example: 500",
    :type => "string",
    :required => "optional",
    :recipes => [ "block_device::setup_block_device", "block_device::default" ]
end

attribute "block_device/terminate_safety",
  :display_name => "Terminate Safety",
  :description => "Prevents the accidental running of the block_device::do_teminate_server recipe. The recipe will only run if the input variable is overridden and set to \"off\".",
  :type => "string",
  :required => "recommended",
  :choice => ["Override the dropdown and set to \"off\" to really run this recipe"],
  :default => "Override the dropdown and set to \"off\" to really run this recipe",
  :recipes => [ "block_device::do_delete_volumes_and_terminate_server" ]

attribute "block_device/force_safety",
  :display_name => "Force Reset Safety",
  :description => "Prevents the accidental running of the block_device::do_force_reset recipe. The recipe will only run if the input variable is overridden and set to \"off\".",
  :type => "string",
  :required => "recommended",
  :choice => ["Override the dropdown and set to \"off\" to really run this recipe"],
  :default => "Override the dropdown and set to \"off\" to really run this recipe",
  :recipes => [ "block_device::do_force_reset" ]
