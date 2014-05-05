class agent_role {

    class { 'ec2_collective':
        run_as          => 'ec2collective',
        deps_from_pip   => true,
     }

}
