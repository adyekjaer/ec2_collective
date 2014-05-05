try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

setup(
    name='ec2-collective',
    version='0.0.1',
    author='Cristian Magherusan-Stanciu',
    author_email='cristian.magherusan-stanciu@here.com',
    packages=[],
    scripts=['bin/ec2-cagent', 'bin/ec2-cmaster','bin/sqs-price-calculator'],
    data_files=[
        ('/etc/init.d', ['etc/init.d/ec2-cagent']),
        ('/etc/supervisor/conf.d/', ['etc/supervisor/ec2-cagent.conf']),
        ('/etc/ec2_collective', ['etc/ec2_collective/ec2-cagent.json', 'etc/ec2_collective/ec2-cmaster.json']),
        ('/var/log/ec2_collective', []),
        ('/etc/logrotate.d', ['etc/logrotate.d/ec2-cagent'])
      ],
    url='http://pypi.python.org/pypi/ec2-collective/',
    license='LICENSE.txt',
    description='Mcollective alternative using AWS SQS',
    long_description=open('README.txt').read(),
    install_requires=[
      'boto >= 2.0', 'pyyaml'
      ],
    )
