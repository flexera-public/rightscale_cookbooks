# RightScale "repo_git" Cookbook

## DESCRIPTION:

This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).

Provides the Git implementation of the 'repo' resource to
manage source code downloaded from Git repositories.

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
* Once set up, use the recipes in the 'repo' cookbook to manage downloading from
  your code repository. See the repo/README.md for usage details.
* Select the 'repo_git' option for the repo/default/provider input.
* To perform correct operations, values for the repo/url and repo/branch inputs
  must be provided.
* To access private Git repositories, the repo/default/credential input must
  contain a string with a valid Git SSH key or 'key'-type variable from the
  RightScale dashboard.

## DETAILS:

### General

The 'repo_git' implementation can be called with the help of the Lightweight
Resource, which can be found in the `repo` cookbook.

For more information about Lightweight Resources and Providers (LWRPs), please
see [Lightweight Resources and Providers][Guide].

[Guide]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Lightweight_Resources_and_Providers_(LWRP)

### Libraries-helpers:

**RightScale::Repo::SshKey.create(git_ssh_key)**

Create a bash script that provides the Git SSH key that is required to access
code in private git repositories.

Parameters

`git_ssh_key(String)::` Git private ssh key

Raise

`RuntimeError::` if the Git SSH key string is empty.

**RightScale::Repo::SshKey.delete**

Remove bash script created by the `create` method, after a successful pull
operation.

Parameters

none

### LWRPs:

The `repo_git` provider is defined in the `providers/default.rb` file, which
contains source code for `:pull` and `:capistrano_pull` actions.
For more info about these actions please see the `repo` cookbook's README.

The `repo_git` provider allows the retrieval of source code from remote Git
repositories. It supports repositories with public and private
(ssh key protected) access.

For normal operations, it requires the 'repo' resource, which acts as the
interface to all `repo_git` provider logic.

##### Actions:

`:pull`
Standard repository pull. Pull source code from a remote repository by
specifying its location with a URL.

`:capistrano_pull`
Perform standard pull and then a capistrano deployment style will be applied.

##### Usage Example:

For usage examples, please see the corresponding section in `repo` cookbook's
README.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
