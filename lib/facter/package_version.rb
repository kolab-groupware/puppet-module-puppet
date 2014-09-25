require 'facter'

results = %x{/bin/rpm -qa --queryformat "%{NAME} %{VERSION}-%{RELEASE}\n"}

results.split("\n").each do |pv|
    p,v = pv.split(' ')

    p = "_" + p if p =~ /^\d/

    Facter.add(p + '_version') do
        setcode do
            v
        end
    end
end
