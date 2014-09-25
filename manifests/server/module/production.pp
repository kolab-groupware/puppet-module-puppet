define puppet::server::module::production (
        $base_url = false,
        $module_prefix = false,
        $branch = 'production'
    ) {

    # Shortcut to module with branch production
    puppet::server::module { "production_$name":
        base_url => $base_url,
        module_prefix => $module_prefix,
        module_name => $name,
        branch => $branch
    }
}

