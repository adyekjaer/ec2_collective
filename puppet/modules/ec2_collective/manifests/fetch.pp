class ec2_collective::fetch () inherits ec2_collective {

    $url = "https://github.com/adyekjaer/ec2_collective/archive/${release}.tar.gz"
    $archive = "ec2_collective-${release}"

    exec { 'download_ec2_collective':
        command     => "wget -O /tmp/ec2_collective.tar.gz ${url}",
        cwd         => '/tmp',
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin', 
        subscribe   => File['/etc/ec2_collective'],
        refreshonly => true,
        require     => Package['wget'],
    }

    exec { 'extract_ec2_collective':
        command     => "tar -xf /tmp/ec2_collective.tar.gz",
        cwd         => '/tmp',
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin', 
        subscribe   => Exec['download_ec2_collective'],
        refreshonly => true,
        require     => Package['wget'],
    }
}
