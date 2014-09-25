define puppet::server::domain::production (
        $public = true,
        $base_url = false,
        $url = false,
        $real_name = false,
        $prefix = false
    ) {

    puppet::server::domain { "production_$name":
        branch => "production",
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

