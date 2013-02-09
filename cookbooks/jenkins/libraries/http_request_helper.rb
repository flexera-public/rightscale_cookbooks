module RightScale
  module Jenkins
    module HttpRequestHelper
	    class Chef::REST
	      def gzip_disabled?; true; end
	    end
    end
  end
end