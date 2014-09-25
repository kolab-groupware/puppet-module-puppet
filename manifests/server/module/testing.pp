define puppet::server::module::testing (
        $base_url = false,
        $module_prefix = false,
        $branch = 'testing'
    ) {

    #
    # Shortcut to Puppet::Server::Module with branch testing
    #
    # You can only include/define Puppet::Server::Module["foo"] once, so this is
    # work-around to enable you to have Puppet::Server::Module::Development["foo"]
    # and Puppet::Server::Module::Production["foo"]
    #
    # Since the Puppet::Server::Module resource does everything by $name normally,
    # this shortcut supplies the "module_name" attribute to it's call.
    #

    puppet::server::module { "testing_$name":
        base_url => $base_url,
        module_prefix => $module_prefix,
        module_name => $name,
        branch => $branch
    }
}

