# RightScale "repo_ros" Cookbook

## DESCRIPTION:

Provides the Remote Object Store implementation of the 'repo' resource to
manage source code download from Remote Object Store repositories.

## REQUIREMENTS:

* Requires the ['repo' Lightweight Resource cookbook][repo]. See "repo" cookbook
  README for details.
* Requires a virtual machine launched from a RightScale-managed RightImage.

[repo]: https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/repo

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

* `repo`

## KNOWN LIMITATIONS:

This cookbook only supports the retrieval of code from Amazon S3, Rackspace
Cloud Files, and SoftLayer Object Storage.

## SETUP/USAGE:

* Provider will automatically be initialized when you add the `repo:default`
  recipe to your ServerTemplate's runlist.
* Once setup, use the recipes in the 'repo' cookbook to install and manage how
  application code will be retrieved from ROS locations.
  See the 'repo' cookbook's README.md for usage details.
* Select 'repo_ros' option in the repo/default/provider input.

To access to Remote Object Store repositories all inputs shown below must be
filled.

* repo/default/storage_account_provider
* repo/default/repository
* repo/default/prefix
* repo/default/account
* repo/default/credintial

The `repo/default/endpoint` input allows to override the default endpoint.

More detailed input descriptions can be found in the 'repo' cookbook's
README.md.

## DETAILS:

### General

The 'repo_ros' implementation can be called with help from the Lightweight
Resource, which can be found in the `repo` cookbook.

For more information about Lightweight Resources and Providers (LWRPs), please
see [Lightweight Resources and Providers][Guide].

[Guide]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Lightweight_Resources_and_Providers_(LWRP)

### LWRPs:

The `repo_ros` provider is defined in providers/default.rb file and contains
source code for `:pull` and `:capistrano_pull` actions.
For more information about these actions please see the `repo` cookbook's
README.

The `repo_ros` provider allows the retrieval of source code from Amazon S3,
Rackspace Cloud Files, Swift and SoftLayer Object Storage ROS remote
repositories.

For normal operations it requires the "repo" resource, which acts as the
interface to all `repo_ros` provider logic.

##### Actions:

`:pull`

Standard repository pull. Your source code repository will be pulled from the
specified ROS remote repository to a specified destination on the local
instance.

`:capistrano_pull`

Performs a standard repository pull plus a capistrano deployment style is
applied.

* Standard Opscode chef capistrano implementation does not support ROS
* Downloaded ROS repository will be converted to a git repository
* Then the capistrano deployment will be applied using the `capistranize`
  definition
* Git attributes will be removed after everything is applied.

##### Usage Example:

For usage examples, please see the corresponding section in `repo` cookbook's
README.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
