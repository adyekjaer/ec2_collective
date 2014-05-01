class ec2_collective::master () inherits ec2_collective {

    file { '/etc/ec2_collective/ec2-cmaster.json':
        ensure => directory,
        owner => 'root',
        owner => 'root',
        mode => '0755'
    }

    file { '/usr/local/bin/ec2-cmaster':
        source => "/tmp/ec2_collective-${release}/bin/ec2-cmaster",
        owner => 'root',
        group => 'root',
        mode => '0755'
    }
}
