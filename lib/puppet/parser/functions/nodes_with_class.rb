require "puppet"

module Puppet::Parser::Functions
    newfunction(:nodes_with_class, :type => :rvalue ) do |args|
        theClass = args[0]

        Puppet::Parser::Functions.autoloader.load(:versioncmp) unless Puppet::Parser::Functions.autoloader.loaded?(:versioncmp)

        if lookupvar("puppetversion")[0] == "2" then
            require "puppet/rails"
            class Hosts < Puppet::Rails::Host; end
            printtype = "name"
            query = "resources.restype = \'Class\' AND resources.title = \'" + theClass.to_s + "\'"
            Hosts.find(
                    :all,
                    :include => [ :resources ],
                    :conditions => query
                ).map { |host| host.send(printtype) }
        else
            Puppet::Parser::Functions.autoloader.load(:query_nodes) unless Puppet::Parser::Functions.autoloader.loaded?(:query_nodes)
            function_query_nodes(['Class["' + theClass.to_s + '"]', 'fqdn'])
        end
    end
end

