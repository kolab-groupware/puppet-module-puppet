define puppet::server::domain::testing (
        $public = true,
        $base_url = false,
        $url = false,
        $real_name = false,
        $prefix = false
    ) {

    puppet::server::domain { "testing_$name":
        branch => "testing",
        public => $public,
        base_url => $base_url,
        url => $url,
        real_name => $real_name ? {
            false => $name,
            default => $real_name
        },
        prefix => $prefix
    }
}

