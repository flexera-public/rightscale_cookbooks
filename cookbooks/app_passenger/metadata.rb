maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures Apache Passenger Rails application server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.3.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "app"
depends "repo"
depends "rightscale"
depends "web_apache"
depends "logrotate"

recipe "app_passenger::setup_server_3_0", "Default cookbook recipe which " +
  "sets provider-specific attributes for rails-passenger."
recipe "app_passenger::install_custom_gems", "Custom gems to install."
recipe "app_passenger::install_required_app_gems", "Bundler gems install. " +
  "Gemfile must be present in app directory."
recipe "app_passenger::run_custom_rails_commands", "Run specific user " +
  "defined commands. Commands will be executed in the app directory. " +
  "Command path ../rails/bin/"


attribute "app_passenger/spawn_method",
  :display_name => "Rails spawn method",
  :description => "The spawn method that Phusion Passenger will use. " +
    "The choices are: smart, smart-lv2, and conservative. " +
    "Example: conservative",
  :choice => ["conservative", "smart-lv2", "smart"],
  :required => "recommended",
  :default => "conservative",
  :recipes => ["app_passenger::setup_server_3_0"]

attribute "app_passenger/project/environment",
  :display_name => "Rails Environment",
  :description => "Creates a Rails RAILS ENV environment variable. " +
    "Example: development",
  :choice => ["development", "production", "test"],
  :required => "optional",
  :default => "development",
  :recipes => ["app_passenger::setup_server_3_0"]

attribute "app_passenger/apache/serve_local_files",
  :display_name => "Apache serve local Files",
  :description => "This option tells Apache whether it should serve " +
    "the (static) content itself. Currently, it will omit dynamic content, " +
    "such as *.php, *.action, *.jsp, and *.do  Example: true",
  :choice => ["true", "false"],
  :required => "optional",
  :default => "true",
  :recipes => ["app_passenger::setup_server_3_0"]

attribute "app_passenger/project/gem_list",
  :display_name => "Custom gems list",
  :description => "A space-separated list of optional gem(s). " +
    "Format:  ruby-Gem1:version ruby-Gem2:version ruby-Gem3. " +
    "Example: mygem:1.0, yourgem:2.0",
  :required => "optional",
  :default => "",
  :recipes => ["app_passenger::install_custom_gems"]

attribute "app_passenger/project/custom_cmd",
  :display_name => "Custom rails/bin/ command",
  :description => "A comma-separated list of optional commands " +
    "which will be executed in the app directory. " +
    "Example: rake gems:install, rake db:create, rake get_common",
  :required => "optional",
  :default => "",
  :recipes => ["app_passenger::run_custom_rails_commands"]
