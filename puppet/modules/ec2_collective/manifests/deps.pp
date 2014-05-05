class ec2_collective::deps () inherits ec2_collective {

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

    # boto >= 2.6 is required to support IAM roles
    if $deps_from_pip {
        if ! defined(Package['python-pip']) {
            package { 'python-pip':
                ensure => installed
            }
        }

        exec {'pip_install_boto':
            command     => "pip install boto==${boto_version}",
            cwd         => '/tmp',
            path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin', 
            unless      => "pip freeze | grep -iq ^boto==${boto_version}",
            require     => Package['python-pip']
        }

        exec {'pip_install_pyyaml': 
            command     => 'pip install pyyaml',
            cwd         => '/tmp',
            path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin', 
            unless      => 'pip freeze | grep -iq ^pyyaml',
            require     => Package['python-pip']
        }

    } else {
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

    if $install_agent {
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
    }

}
