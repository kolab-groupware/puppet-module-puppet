define puppet::server::domain::development (
        $public = true,
        $base_url = false,
        $url = false,
        $real_name = false,
        $prefix = false
    ) {

    puppet::server::domain { "development_$name":
        branch => "development",
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

