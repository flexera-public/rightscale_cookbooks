# RightScale "repo_svn" Cookbook

## DESCRIPTION:

Provides the Subversion implementation of the 'repo' resource to
manage source code downloaded from Subversion repositories.

## REQUIREMENTS:

* Requires the ['repo' Lightweight Resource cookbook][repo]. See "repo" cookbook
  README for details.
* Requires a virtual machine launched from a RightScale-managed RightImage.

[repo]: https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/repo

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

* `rightscale`
* `repo`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* Provider will be automatically initialized when you add "repo:default" recipe
  to your ServerTemplate runlist
* Once setup, use the recipes in the 'repo' cookbook to install and manage your
  code repo.
  See the 'repo' cookbook's README.md for usage details.
* Select 'repo_svn' option in repo/default/provider input.
* To perform correct operations, values for the 'repo/url', and 'repo/branch'
  inputs must be provided.
* To retrieve source code from private svn repositories you must provide values
  for the 'repo/default/credential' and 'repo/default/account' inputs for
  authentication purposes.

## DETAILS:

### General

The 'repo_svn' implementation can be called with the help of the Lightweight
Resource, which can be found in the `repo` cookbook.

For more information about Lightweight Resources and Providers (LWRPs), please
see [Lightweight Resources and Providers][Guide].

[Guide]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Lightweight_Resources_and_Providers_(LWRP)

### LWRPs:

The `repo_svn` provider is defined in the providers/default.rb file and contains
source code for the `:pull` and `:capistrano_pull` actions.
For more info about these actions please see `repo` cookbook's README.

The `repo_svn` provider allows the retrieval of source code from Subversion
remote repositories.It supports repositories with public and private
(username/password protected) access.

For normal operations, it requires "repo" resource, which acts as interface to
all `repo_svn` provider logic.

##### Actions:

`:pull`

Standard repo pull. Pull source code from a remote repository by specifying its
location with a URL.

`:capistrano_pull`

Perform standard pull and then a capistrano deployment style will be applied.

##### Usage Example:

For usage examples, please see corresponding section in `repo` cookbook's
README.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
