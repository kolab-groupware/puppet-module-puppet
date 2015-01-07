class puppet {

    package { "puppet":
        ensure => installed
    }

    service { "puppet":
        enable => true,
        ensure => running,
        require => Package["puppet"],
        noop => false
    }

    # TO be realized later, with templates and stuff
    @file { [
            "/etc/puppet/puppet.conf",
            "/etc/sysconfig/puppet"
        ]:
        owner => "root",
        group => "root",
        mode => "644",
        notify => Service["puppet"],
        require => Package["puppet"]
    }

    file { "/usr/local/sbin/run_puppet":
        owner => "root",
        group => "wheel",
        mode => "750",
        source => [
            "puppet://$server/private/$environment/puppet/run_puppet",
            "puppet://$server/files/puppet/run_puppet",
            "puppet://$server/modules/puppet/run_puppet"
        ]
    }

    # Ensure that the manifest directory for default environment production
    # is defined. This will be realized in puppet::server.
    #
    # Do the same for the modules directory.

    @file { [
            "/var/lib/puppet/environments/",
            "/var/lib/puppet/environments/production/",
            "/var/lib/puppet/environments/production/modules/",
        ]:
        ensure => directory
    }
}
