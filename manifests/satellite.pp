class puppet::satellite inherits puppet::server {
    File["/etc/puppet/puppet.conf"] {
        content => template('puppet/puppet.conf.erb')
    }

    realize(File["/etc/puppet/puppet.conf"])
}

