EC2_Collective
======

An orchestration tool build on the ideas of MColletive but for the cloud by using AWS SQS as the queue service. 
The agent will execute arbitrary commands and supports message filtering based on facts from e.g. puppet and queue isolation.

NOTE: I'm not a developer, I just connect the dots - this is a prototype

Why is it cool
--------

- *Decentralized*
  With python, boto and an IAM user, you can command your servers from anywhere. You are not tied to a 'mamagement' server

- *No firewalll problems*
  All communication is through AWS SQS so there is no need to open for specific ports to/from your servers
  New servers in new security groups will simply work

- *Arbitrary commands*
  Create you own scripts and wrappers to perform those actions you need to do on a regular basis. Stop caring about Ruby and write your stuff in your beloved bash interpreter or something else

- *Facts*
  Use puppet facts from yaml files or populate your own files and have the agent read them. Read text files like puppet classes.txt and filter on all of it as facts

- *Queue isolation*
  Ever executed a command in production that was meant for test servers? EC2_Collective lets you to use different queues for your different environments

Requirements
--------

* AWS account
* Python > 2.6 < 3
* Boto >= 1.9b

Cost
--------

As with all Amazon Webservices there is a cost associated with its usage. 
Ec2_Collective will amount to something like $12 a month for 50 servers.
Use the tools/sqs-price-calculator to calculate the price for your environment.

How does it work
--------

Please familiarize yourself with the standard SQS[SQS] documentation

And the long polling document[LONGPOLLING]

Messages containing commands are pushed by the master ( ec2-cmaster ) to a specific SQS queue where agents ( ec2-cagent ) are 'listening'. The agents are actually continuously polling the queue using the long polling SQS feature in order to limit the amount of requests towards AWS which bills by request. 

All messages are received by all agents on that queue and processed. If the message facts matches the one of the agent, the agent first respond with a discovery reply by pushing a message on a different queue. This allows the master to know how many replies to expect. ( amount of agents with those specific facts ). The agent then performs the action included in the message and pushes the output and the status code of the execution to the same queue as the discovery reply where the master is listening.

When the master has reached the default discovery timeout of 5 seconds it records how many agents to expect. It will then wait for that amount of agents to respond or break prematurely if the default command timeout of 10 seconds is reached. In all cases, it will print the output and status code from all the agents that managed to be discovered and which replied with command output. Along with that is a list of agents which was discovered but failed to repond with output within 10 seconds. During this time, the master will delete received messages from the queue and the one it had sent out to begin with. In other words, if an agent is not discovered within the first 5 seconds it does not exist.

A number of things can happen within these 5 seconds that will make it seem as if Ec2_Collective is misbehaiving. One such case is that a few agents will never receive the message from the master because all expected agents have already replied and the original message has been deleted before the agents see it. Or the master never receives a reply because other master processes are reading those messages. In short, we rely heavily on timeouts and timely deliverability of messages. If we were to wait longer that 5 seconds for the discovery reply it would quickly become a slow tool to work with.

Luckily we have introduced a safetynet which has proved itself to eliminate these problems. By using a facts queue, all agents will at a regular interval sent the list of facts which is has. This way the master can quickly query that queue with a visibility timeout of 0 ensuring that all other master processes are also able to read these messages. This allows the master to know how many agents to expect without having received a real-time discovery reply from them. That is why it is important that the configuration of the queues are done exactly as documented in this README.

Using a true publish / subscribe service like AWS SNS would have been prefererred, but suddenly you'll find youself opening ports to everyone to a service that can perform anything. There is some overhead in adding new subscribers and we're really aiming at having a 'zero configuration setup' cross servers and cloud providers.

Setup
--------

### AWS SQS queues

I recommend basing your queues on your given environments. E.g. queues for testing, staging and production. For each environment 3 queues are required. 

Create those 3 queues with a prefix e.g. :

- *testing_master* Write queue for publisher / read queue for subscriber

    Default Visibility Timeout: 0 seconds

    Message Retention Period: 1 minutes

    Maximum Message Size: 64 KB

    Receive Message Wait Time: 20 seconds

- *testing_agent* Write queue fro subscriber / read queu for publisher

    Default Visibility Timeout: 0 seconds

    Message Retention Period: 1 minutes

    Maximum Message Size: 64 KB

    Receive Message Wait Time: 0 seconds

- *testing_facts* Cheat queue to allow publisher to know how many replies to expect

    Default Visibility Timeout: 0 seconds

    Message Retention Period: 1 minutes

    Maximum Message Size: 64 KB

    Receive Message Wait Time: 0 seconds

Be sure to set the queue configuration accordingly or else ec2_collective will fail to work.

### AWS IAM users

Create a user for the agent with the following policy:

    {
      "Statement": [
        {
          "Action": [
            "sqs:ListQueues",
            "sqs:GetQueueAttributes"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:sqs:*:*:*"
          ]
        },
        {
          "Action": [
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "sqs:ListQueues",      
            "sqs:ChangeMessageVisibility",
            "sqs:ChangeMessageVisibilityBatch",
            "sqs:SendMessage",
            "sqs:SendMessageBatch"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:sqs:*:*:*_agent",
            "arn:aws:sqs:*:*:*_facts"
          ]
        },
     {
          "Action": [
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl",
            "sqs:ListQueues",
         "sqs:ReceiveMessage"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:sqs:*:*:*_master"
          ]
        }
      ]
    }

Create a user for the master 'publisher' tool:

    {
      "Statement": [
        {
          "Action": [
            "sqs:ListQueues",
            "sqs:GetQueueAttributes"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:sqs:*:*:*"
          ]
        },
        {
          "Action": [
             "sqs:*"
          ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:sqs:*:*:*_agent",
            "arn:aws:sqs:*:*:*_master",
            "arn:aws:sqs:*:*:*_facts"
          ]
        }
      ]
    }

Agent installation
-------

Perform the following steps on the servers you wish to orchestrate

- *cp ec2-cagent /usr/sbin/ec2-cagent && chmod +x /usr/sbin/ec2-cagent*
- *cp scripts/ec2-cagent-init /etc/init.d/ec2-cagent && chmod +x /etc/init.d/ec2-cagent*
- *cp scripts/ec2-cagent-logrotate /etc/logrotate.d/ec2-cagent*
- *mkdir /var/log/ec2_collective/*
- *mkdir /etc/ec2_collective*
- *cp conf/ec2-cagent.json /etc/ec2_collective*
- Add a /etc/boto.cfg including the AWS IAM credentials

Edit your /etc/boto.cfg to contain

    [Credentials]
    ...

    [Boto]
    http_socket_timeout = 30

Edit your ec2-cagent.json according to your queues and fact file locations.

    { 
        "general": {
            "log_level": "INFO",
            "sqs_poll_interval": 1,
            "queue_poll_interval": 0.1,
            "yaml_facts": true,
            "yaml_facts_path": "/etc/ec2_collective/facts.yaml,/var/lib/puppet/state/classes.txt",
            "yaml_facts_refresh": 30,
            "use_facts_queue": true
        },
        "aws": {
            "region": "eu-west-1",
            "sqs_read_queue": "testing_master",
            "sqs_write_queue": "testing_agent",
            "sqs_facts_queue": "testing_facts"
        }
    }

Master installation
-------

Perform the following steps on your workstations where you wish to perform the orchestration

- *cp ec2-cmaster <whereever> && chmod +xec2-cagent*
- *mkdir /etc/ec2_collective*
- *cp conf/ec2-cmaster.json /etc/ec2_collective*
- Add a /etc/boto.cfg including the AWS IAM credentials

Edit your /etc/boto.cfg to contain

    [Credentials]
    ...

    [Boto]
    http_socket_timeout = 30

Edit your ec2-cmaster.json according to your queues.

    { 
        "general": {
            "log_level": "INFO",
            "cmd_timeout": 10,
            "ping_timeout": 5,
            "clean_timeout": 15,
            "use_facts_queue": true
        },
        "aws": {
            "region": "eu-west-1",
            "default_queue_name": "testing",
            "write_queue_suffix": "_ec2_master",
            "read_queue_suffix": "_ec2_agent",
            "facts_queue_suffix": "_ec2_facts"
        }
    }


Usage
-------

[SQS]: http://docs.amazonwebservices.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/SQSConcepts.html
[LONGPOLLING]: http://docs.amazonwebservices.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-long-polling.html
