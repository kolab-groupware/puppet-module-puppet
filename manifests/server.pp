class puppet::server inherits puppet::client {
    include git::client
    include webserver

    exec { "dashboard_rake_gems_refresh_specs":
        command => "rake gems:refresh_specs",
        cwd => "/usr/share/puppet-dashboard",
        refreshonly => true
    }

    exec { "puppetdb_ssl-setup_f":
        command => "puppetdb ssl-setup -f",
        refreshonly => true,
        unless => "diff /etc/puppetdb/ssl/ca.pem /var/lib/puppet/ssl/certs/ca.pem"
    }

    file { "/etc/puppet/puppetdb.conf":
        owner => "root",
        group => "root",
        mode => "644",
        source => [
                "puppet://$server/private/$environment/puppet/puppetdb.conf",
                "puppet://$server/files/puppet/puppetdb.conf"
            ],
        require => [
                Package["puppet-server"],
                Package["puppetdb"]
            ]
    }

    file { "/etc/puppet/routes.yaml":
        owner => "root",
        group => "root",
        mode => "644",
        source => [
                "puppet://$server/private/$environment/puppet/routes.yaml",
                "puppet://$server/files/puppet/routes.yaml",
                "puppet://$server/modules/puppet/routes.yaml"
            ]
    }

    file { "/usr/local/sbin/update_puppet":
        source => [
                "puppet://$server/private/$environment/puppet/update_puppet",
                "puppet://$server/files/puppet/update_puppet",
                "puppet://$server/modules/puppet/update_puppet"
            ],
        mode => "750",
        owner => "root",
        group => "root"
    }

    file { "/var/lib/puppet/environments/production/environment.conf":
        content => "modulepath = /var/lib/puppet/environments/production/modules/:\$basemodulepath"
    }

    package { "puppet-dashboard":
        ensure => installed,
        notify => Exec["dashboard_rake_gems_refresh_specs"]
    }

    package { "puppet-server":
        ensure => installed
    }

    package { "puppetdb":
        ensure => installed,
        notify => Exec["puppetdb_ssl-setup_f"]
    }

    service { "puppet-dashboard-workers":
        ensure => running,
        enable => true,
        require => [
                Package["puppet-dashboard"]
            ]
    }

    service { "puppetdb":
        ensure => running,
        enable => true,
        require => [
                Exec["puppetdb_ssl-setup_f"],
                Package["puppetdb"]
            ]
    }

    if (!defined(Webserver::Module::Enable["mod_authz_core"])) {
        @webserver::module::enable { "mod_authz_core": }
    }

    if (!defined(Webserver::Module::Enable["mod_slotmem_shm"])) {
        @webserver::module::enable { "mod_slotmem_shm": }
    }

    if (!defined(Webserver::Module::Enable["mod_socache_shmcb"])) {
        @webserver::module::enable { "mod_socache_shmcb": }
    }
        
    if (!defined(Webserver::Module::Enable["mod_ssl"])) {
        @webserver::module::enable { "mod_ssl": }
    }

    if (!defined(Webserver::Module::Enable["mod_unixd"])) {
        @webserver::module::enable { "mod_unixd": }
    }

    if (!defined(Webserver::Module::Enable["mod_passenger"])) {
        @webserver::module::enable { "mod_passenger": }
    }

    realize(
            Webserver::Module::Enable["mod_authz_core"],
            Webserver::Module::Enable["mod_slotmem_shm"],
            Webserver::Module::Enable["mod_socache_shmcb"],
            Webserver::Module::Enable["mod_ssl"],
            Webserver::Module::Enable["mod_unixd"],
            Webserver::Module::Enable["mod_passenger"]
        )

    webserver::virtualhost { "puppet.${::domain}":
        certificate => false,
        template => "puppet/webserver/sites/puppet.conf.erb"
    }

    File["/etc/puppet/puppet.conf"] {
        content => template('puppet/puppet.conf.erb'),
        require +> Package["puppet-server"]
    }

    realize(
        File["/etc/puppet/puppet.conf"]
    )

    environment_manifests { [
            "development",
            "testing",
            "production"
        ]:
    }

    environment_modules { [
            "development",
            "testing",
            "production"
        ]:
    }

    define environment_manifests() {
        if (!defined(File["/var/lib/puppet/environments/$name/"])) {
            @file { "/var/lib/puppet/environments/$name/":
                ensure => directory
            }
        }

        if (!defined(File["/var/lib/puppet/environments/$name/environment.conf"])) {
            @file { "/var/lib/puppet/environments/$name/environment.conf":
                content => "modulepath = /var/lib/puppet/environments/$name/modules/:\$basemodulepath"
            }
        }

        realize(
                File["/var/lib/puppet/environments/$name/"],
                File["/var/lib/puppet/environments/$name/environment.conf"]
            )

        file { "/var/lib/puppet/environments/$name/manifests/site.pp":
            owner => "root",
            group => "root",
            mode => "644",
            source => [
                "puppet://$server/private/$name/puppet/site.pp",
                "puppet://$server/modules/$name/puppet/files/site.pp"
            ],
            require => File["/var/lib/puppet/environments/$name/manifests/"]
        }

        file { "/var/lib/puppet/environments/$name/manifests/":
            owner => "root",
            group => "root",
            source => [
                "puppet://$server/private/$name/puppet/manifests/"
            ],
            recurse => true,
            purge => true,
            force => true
        }
    }

    define environment_modules() {
        if (!defined(File["/var/lib/puppet/environments/$name/"])) {
            @file { "/var/lib/puppet/environments/$name/":
                ensure => directory
            }
        }

        if (!defined(File["/var/lib/puppet/environments/$name/modules/"])) {
            @file { "/var/lib/puppet/environments/$name/modules/":
                ensure => directory
            }
        }

        realize(
                File["/var/lib/puppet/environments/$name/"],
                File["/var/lib/puppet/environments/$name/modules/"]
            )
    }

    file { "/etc/puppet/autosign.conf":
        owner => "root",
        group => "root",
        mode => "644",
        source => [
            "puppet://$server/private/$environment/puppet/autosign.conf",
            "puppet://$server/files/puppet/autosign.conf",
            "puppet://$server/modules/puppet/autosign.conf"
        ],
        require => File["/var/lib/puppet/private/"]
    }

    file { "/etc/puppet/auth.conf":
        owner => "root",
        group => "root",
        mode => "644",
        source => [
            "puppet://$server/private/$environment/puppet/auth.conf",
            "puppet://$server/files/puppet/auth.conf",
            "puppet://$server/modules/puppet/auth.conf"
        ],
        require => File["/var/lib/puppet/private/"]
    }

    file { "/etc/puppet/fileserver.conf":
        owner => "root",
        group => "root",
        mode => "644",
        source => [
            "puppet://$server/private/$environment/puppet/fileserver.conf",
            "puppet://$server/files/puppet/fileserver.conf",
            "puppet://$server/modules/puppet/fileserver.conf"
        ],
        require => File["/var/lib/puppet/private/"]
    }

    file { [
            "/usr/share/puppet/rack/",
            "/usr/share/puppet/rack/puppetmasterd/",
            "/usr/share/puppet/rack/puppetmasterd/public/",
        ]:
        ensure => directory,
        mode => "755"
    }

    file { [
            "/usr/share/puppet/rack/puppetmasterd/tmp/"
        ]:
        ensure => directory,
        mode => "755",
        owner => "apache",
        group => "apache"
    }

    file { [
            "/usr/share/puppet/rack/puppetmasterd/config.ru"
        ]:
        source => "/usr/share/puppet/ext/rack/config.ru",
        mode => "644",
        notify => Service["httpd"],
        owner => "puppet"
    }

    file { "/var/lib/puppet/private/":
        ensure => directory
    }

    realize(
            File["/var/lib/puppet/environments/"],
            File["/var/lib/puppet/environments/production/"],
            File["/var/lib/puppet/environments/production/modules/"],
        )
}

