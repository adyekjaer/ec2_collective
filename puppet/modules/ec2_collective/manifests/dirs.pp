class ec2_collective::dirs () inherits ec2_collective {

    file { '/etc/ec2_collective':
        ensure => directory,
        owner => 'root',
        group => 'root',
        mode => '0755'
    }

    file { '/var/log/ec2_collective':
        ensure => directory,
        owner => "$run_as",
        group => "$run_as",
        mode => '0755'
    }

    file { '/var/run/ec2_collective':
        ensure => directory,
        owner => "$run_as",
        group => "$run_as",
        mode => '0755'
    }
}
