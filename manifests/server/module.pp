define puppet::server::module (
        $module_name = false,
        $module_prefix = false,
        $base_url = false,
        $url = false,
        $branch = 'production'
    ) {

    #
    # This resource makes the puppet master pull in the modules
    # from puppetmanaged.org, to /var/lib/puppet/modules/$branch/$name
    #

    $real_name = $module_name ? {
        false => $name,
        default => $module_name
    }

    git::clone { "modules/$branch/$real_name":
        source => $url ? {
            false => $base_url ? {
                false => "$url",
                default => $module_prefix ? {
                    false => $module_name ? {
                        false => "$base_url/$name",
                        default => "$base_url/$module_name"
                    },
                    default => $module_name ? {
                        false => "$base_url/$module_prefix-$name",
                        default => "$base_url/$module_prefix-$module_name"
                    }
                }
            },
            default => $url
        },
        localtree => "/var/lib/puppet/environments/$branch/modules/",
        real_name => "$real_name",
        branch => $branch
    }

    git::pull { "modules/$branch/$real_name":
        localtree => "/var/lib/puppet/environments/$branch/modules/",
        real_name => $real_name,
        require => Git::Clone["modules/$branch/$real_name"]
    }

}

