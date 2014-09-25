define puppet::server::domain (
        $public = true,
        $base_url = false,
        $url = false,
        $real_name = false,
        $prefix = false,
        $hosted = false,
        $branch = 'development'
    ) {

    #
    # This resource makes the puppet masterpull in the
    # /var/lib/puppet/private/$environment/$environment tree from an upstream
    # SCM, and "copies" the puppet/manifests/nodes/ to it's final location
    # /var/lib/puppet/manifests/$environment/domains/$domain/nodes/
    #

    if defined(File["/var/lib/puppet/private/$name/"]) {
        realize(File["/var/lib/puppet/private/$name/"])
    } else {
        @file { "/var/lib/puppet/private/$name/":
            ensure => directory,
            path => $real_name ? {
                false => "/var/lib/puppet/private/$name",
                default => "/var/lib/puppet/private/$real_name"
            }
        }
        realize(File["/var/lib/puppet/private/$real_name/"])
    }

    git::clone { "private/$name/$branch":
        source => $url ? {
            false => $prefix ? {
                false => $real_name ? {
                    false => "$base_url/$name",
                    default => "$base_url/$real_name"
                },
                default => $real_name ? {
                    false => "$base_url/$prefix-$name",
                    default => "$base_url/$prefix-$real_name"
                }
            },
            default => "$url"
        },
        localtree => $real_name ? {
            false => "/var/lib/puppet/private/$name/",
            default => "/var/lib/puppet/private/$real_name/"
        },
        real_name => $branch
    }

    git::pull { "private/$name/$branch":
        localtree => $real_name ? {
            false => "/var/lib/puppet/private/$name/",
            default => "/var/lib/puppet/private/$real_name/"
        },
        real_name => $branch,
        require => Git::Clone["private/$name/$branch"]
    }

    if $hosted == 'true' {
        if (!defined(File["/var/lib/puppet/environments/$branch/manifests/domains/"])) {
            file { "/var/lib/puppet/environments/$branch/manifests/domains/":
                ensure => directory
            }
        }

        file { "/var/lib/puppet/environments/$branch/manifests/domains/$name/":
            ensure => directory,
            path => $real_name ? {
                false => "/var/lib/puppet/environments/$branch/manifests/domains/$name/",
                default => "/var/lib/puppet/environments/$branch/manifests/domains/$real_name/"
            },
            source => $real_name ? {
                false => "/var/lib/puppet/private/$name/$branch/puppet/manifests/",
                default => "/var/lib/puppet/private/$real_name/$branch/puppet/manifests/"
            },
            recurse => true,
            purge => true,
            force => true,
            require => [
                Git::Pull["private/$name/$branch"]
            ]
        }

        file { "/var/lib/puppet/environments/$branch/manifests/domains/$name.pp":
            path => $real_name ? {
                false => "/var/lib/puppet/environments/$branch/manifests/domains/$name.pp",
                default => "/var/lib/puppet/environments/$branch/manifests/domains/$real_name.pp"
            },
            source => $real_name ? {
                false => [
                    "/var/lib/puppet/private/$name/$branch/puppet/$name.pp",
                    "/var/lib/puppet/private/$name/$branch/puppet/site.pp"
                ],
                default => [
                    "/var/lib/puppet/private/$real_name/$branch/puppet/$real_name.pp",
                    "/var/lib/puppet/private/$real_name/$branch/puppet/site.pp"
                ]
            },
            require => [
                Git::Pull["private/$name/$branch"]
            ]
        }
    }
}
