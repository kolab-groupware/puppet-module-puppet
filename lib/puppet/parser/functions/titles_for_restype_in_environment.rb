require "puppet"
require "puppet/rails"

module Puppet::Parser::Functions
    newfunction(:titles_for_restype_in_environment, :type => :rvalue ) do |args|
        theEnvironment = args[0]
        theRestype = args[1]
    
        class Resources < Puppet::Rails::Resource; end
        printtype = "title"
        query = "resources.restype = \'" + theRestype + "\' AND hosts.environment = \'" + theEnvironment + "\'"
        Resources.find(
                :all,
                :include => [ :host ],
                :conditions => query
            ).map { |resource| resource.send(printtype) }
    end
end

