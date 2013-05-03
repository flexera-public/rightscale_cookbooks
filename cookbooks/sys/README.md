# RightScale System Cookbook 

## DESCRIPTION:

This cookbook provides recipes for setting up a server for RightScale. This
includes setting up the running of periodic recipes and setting up swap.

## REQUIREMENTS:

* Requires a virtual machine launched from a RightScale managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* Place the `sys::default` recipe into the boot recipes to have your
  server set up with any periodic recipes from the inputs.
* Place the `sys::setup_swap` recipe into the boot recipes to set up
  swap on your server. You may wish to use ephemeral storage for swap, in that
  case you should include the `block_device::setup_ephemeral` recipe
  before it.
* You can disable and enable the periodic recipes by running the
  `sys::do_reconverge_list_disable` and
  `sys::do_reconverge_list_enable` recipes.

## DETAILS:

### System Consistency (re-convergence)

To enforce a consistent system state, one can use this LWRP to schedule
a cron job to periodically run a recipe. Optional interval in minutes can be
passed (default 15 minutes) -- with a random starting offset based on fixed 10
min splay (to distribute runs being performed by multiple systems).

To start a periodic reconverge:

    sys_reconverge "mycookbook::myrecipe"

To stop a periodic reconverge:

    sys_reconverge "mycookbook::myrecipe" do
      action :disable
    end

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
