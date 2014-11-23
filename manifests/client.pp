class puppet::client inherits puppet {
    cron { "puppet_service":
        command => "/usr/bin/pgrep -x '(puppet|puppetd)' > /dev/null || /sbin/service puppet restart > /dev/null 2>&1",
        user => "root",
        minute => "0",
        hour => [ 0,4,8,12,16,20 ]
    }

    File["/etc/puppet/puppet.conf"] {
        content => template('puppet/puppet.conf.erb')
    }

    File["/etc/sysconfig/puppet"] {
        content => template('puppet/puppet.sysconfig.erb')
    }

    realize(
            File["/etc/puppet/puppet.conf"],
            File["/etc/sysconfig/puppet"]
        )
}
