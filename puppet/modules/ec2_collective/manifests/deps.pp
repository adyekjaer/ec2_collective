class ec2_collective::deps () inherits ec2_collective {

    if $run_as != 'root' and ! defined(User["$run_as"]){
        group { 'ec2_collective_user_primary_grup':
            ensure  => present,
            name => "$run_as"
        }
    
        user { 'ec2_collective_user':
            ensure  => present,
            name    => "$run_as",
            gid     => "$run_as",
            require => Group['ec2_collective_user_primary_grup']
        }
    }

    if ! defined(Package['supervisor']) {
        package { 'supervisor':
            ensure => installed
        }
    }

    if ! defined(Service['supervisor']) {
        service { 'supervisor':
            ensure      => running,
            enable      => true,
            hasstatus   => true,
            hasrestart  => true,
            require     => Package['supervisor']
        }
    }

    if ! defined(Package['wget']) {
        package { 'wget':
            ensure => installed
        }
    }

    if ! defined(Package['tar']) {
        package { 'tar':
            ensure => installed
        }
    }

    if ! defined(Package['python-boto']) {
        package { 'python-boto':
            ensure => installed
        }
    }

    if ! defined(Package['python-yaml']) {
        package { 'python-yaml':
            ensure => installed
        }
    }
}
