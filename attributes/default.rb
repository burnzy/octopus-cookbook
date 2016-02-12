default['octopus']['tentacle']['url'] = 'http://download.octopusdeploy.com/octopus/Octopus.Tentacle.2.6.0.778-x64.msi'
default['octopus']['tentacle']['checksum'] = 'cb81f5296f7843c5c04cb20a02793bb14dad50f6453a0f264ebe859e268d8289'
default['octopus']['tentacle']['package_name'] = 'Octopus Deploy Tentacle'
default['octopus']['tentacle']['install_dir'] = 'C:\Program Files\Octopus Deploy\Tentacle'
default['octopus']['tentacle']['port'] = '10933'
default['octopus']['tentacle']['home'] = 'C:\Octopus'
default['octopus']['tentacle']['role'] = 'webserver'
default['octopus']['tentacle']['name'] = node['hostname']
default['octopus']['tentacle']['publichostname'] = node['fqdn']
default['octopus']['tentacle']['environment'] = 'Test'

# replace with your octopus server thumbprint
default['octopus']['server']['thumbprint'] = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

default['octopus']['tools']['url'] = 'http://download.octopusdeploy.com/octopus-tools/2.5.10.39/OctopusTools.2.5.10.39.zip'
default['octopus']['tools']['checksum'] = '0790ed04518e0b50f3000093b4a2b4ad47f0f5c9af269588e82d960813abfd67'
default['octopus']['tools']['home'] = 'C:\tools\OctopusTools.2.5.10.39'

# replace with your octopus server api endpoint and key
default['octopus']['api']['uri'] = 'http://my-octopus-server.com/api'
default['octopus']['api']['key'] = 'API-XXXXXXXXXXXXXXXXXXXXXXXXXXX'
