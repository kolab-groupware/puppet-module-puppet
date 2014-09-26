require "puppet"

module Puppet::Parser::Functions
    newfunction(:titles_for_restype_in_environment, :type => :rvalue ) do |args|
        theEnvironment = args[0]
        theRestype = args[1]
    
        Puppet::Parser::Functions.autoloader.load(:versioncmp) unless Puppet::Parser::Functions.autoloader.loaded?(:versioncmp)

        if lookupvar("puppetversion")[0] == "2" then
            require "puppet/rails"
            class Resources < Puppet::Rails::Resource; end
            printtype = "title"
            query = "resources.restype = \'" + theRestype + "\' AND hosts.environment = \'" + theEnvironment + "\'"
            Resources.find(
                    :all,
                    :include => [ :host ],
                    :conditions => query
                ).map { |resource| resource.send(printtype) }
        else
            Puppet::Parser::Functions.autoloader.load(:query_nodes) unless Puppet::Parser::Functions.autoloader.loaded?(:query_nodes)
            function_query_nodes([theRestype.to_s + ' and environment="' + theEnvironment + '"', 'fqdn'])
        end
    end
end

