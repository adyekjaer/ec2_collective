class agent_role {

    class { 'ec2_collective':
        #run_as                  => 'ec2collective',
        #run_as_group_membership => 'sudo'
     }

}
