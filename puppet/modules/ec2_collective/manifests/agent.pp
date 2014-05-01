class ec2_collective::agent () inherits ec2_collective {

    exec { 'supervisor_reread' :
        command     => 'supervisorctl reread',
        cwd         => '/tmp',
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin', 
        refreshonly => true,
        notify      => Exec['supervisor_add']
    }

    exec { 'supervisor_add' :
        command     => 'supervisorctl add ec2-cagent',
        cwd         => '/tmp',
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin', 
        refreshonly => true,
    }

    file { '/etc/init.d/ec2-cagent':
        source => 'puppet:///modules/ec2_collective/ec2-cagent-init',
        owner => 'root',
        group => 'root',
        mode => '0755'
    }

    file { '/etc/supervisor/conf.d/ec2-cagent.conf':
        content => template('ec2_collective/ec2-cagent-supervisor.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        notify  => Exec['supervisor_reread'],
        require => Service['supervisor']
    }

    file { '/etc/ec2_collective/ec2-cagent.json':
        content => template('ec2_collective/ec2-cagent.json.erb'),
        owner => 'root',
        group => 'root',
        mode => '0755'
    }

    file { '/usr/local/bin/ec2-cagent':
        source => "/tmp/ec2_collective-${release}/bin/ec2-cagent",
        owner => 'root',
        group => 'root',
        mode => '0755'
    }
}
