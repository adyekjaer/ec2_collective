class ec2_collective::fetch () inherits ec2_collective {

    $url = "https://github.com/adyekjaer/ec2_collective/archive/${release}.tar.gz"
    $archive = "ec2_collective-${release}"

    exec { 'download_ec2_collective':
        command     => "wget -O /tmp/ec2_collective-${release}.tar.gz ${url}",
        cwd         => '/tmp',
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin', 
        creates     => "/tmp/ec2_collective-${release}.tar.gz",
        require     => Package['wget'],
    }

    exec { 'extract_ec2_collective':
        command     => "tar -xf /tmp/ec2_collective-${release}.tar.gz",
        cwd         => '/tmp',
        path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin', 
        creates     => "/tmp/${archive}",
        require     => Exec['download_ec2_collective']
    }
}
