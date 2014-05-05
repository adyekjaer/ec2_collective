class ec2_collective (
    $install_deps               = $ec2_collective::params::install_deps,
    $deps_from_pip              = $ec2_collective::params::deps_from_pip,
    $boto_version               = $ec2_collective::params::boto_version,
    $run_as                     = $ec2_collective::params::run_as,
    $release                    = $ec2_collective::params::release,
    $install_agent              = $ec2_collective::params::install_agent,
    $install_master             = $ec2_collective::params::install_master,
    $log_level                  = $ec2_collective::params::log_level,
    $fact_files                 = $ec2_collective::params::fact_files,
    $agent_read_queue           = $ec2_collective::params::agent_read_queue,
    $agent_write_queue          = $ec2_collective::params::agent_write_queue,
    $agent_facts_queue          = $ec2_collective::params::agent_facts_queue,
    $default_queue_name         = $ec2_collective::params::default_queue_name,
    $master_write_suffix        = $ec2_collective::params::master_write_suffix,
    $maste_read_suffix          = $ec2_collective::params::maste_read_suffix,
    $master_facts_suffix        = $ec2_collective::params::master_facts_suffix,
) inherits ec2_collective::params {

    class {'ec2_collective::fetch':}

    if $install_deps {
        class {'ec2_collective::deps':}
    }

    # This class triggers download of the release
    class {'ec2_collective::dirs':
        require => Class['ec2_collective::fetch'] 
    }

    if $install_agent {
        class {'ec2_collective::agent':
            require => Class['ec2_collective::dirs']
        }
    }

    if $install_master {
        class {'ec2_collective::master':
            require => Class['ec2_collective::dirs']
        }
    }


}
