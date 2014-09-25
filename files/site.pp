#
# site.pp for any domain
#

$server = "master.puppetmanaged.org"

# Do these first, see if this allow proper variable inheritance
import "domains/*.pp"
import "nodes/*.pp"

import "classes/*.pp"
import "groups/*.pp"
import "modules/*.pp"
import "services/*.pp"
import "utils/*.pp"

# Get facts and give them a good, good name
$os = $operatingsystem

case $os {
    "Fedora", "CentOS", "RedHat": {
        $osver = $lsbdistrelease
        $osmajorver = $lsbmajdistrelease
    }
    "Debian", "Ubuntu": {
        $osver = $lsbdistrelease
    }
    "SuSE": {
    }
    "openSuSE": {
    }
    "Darwin": {
        $osver = $operatingsystemrelease
    }
}

case $environment {
    nil: {
        $environment = "development"
    }
}

# Always include the puppet::client class

include puppet::client

# The default node

node default {

}
