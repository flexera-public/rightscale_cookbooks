#
# cookbook name:: jenkins
#
# copyright rightscale, inc. all rights reserved.  all access and use subject
# to the rightscale terms of service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements such
# as a rightscale master subscription agreement.

module RightScale
  module Jenkins
    module HttpRequestHelper
	    class Chef::REST
	      def gzip_disabled?; true; end
	    end
    end
  end
end
