default['octopus']['home'] = 'C:\Octopus'

default['octopus']['tentacle']['url'] = 'http://download.octopusdeploy.com/octopus/Octopus.Tentacle.2.6.0.778-x64.msi'
default['octopus']['tentacle']['checksum'] = 'cb81f5296f7843c5c04cb20a02793bb14dad50f6453a0f264ebe859e268d8289'
default['octopus']['tentacle']['package_name'] = 'Octopus Deploy Tentacle'
default['octopus']['tentacle']['install_dir'] = 'C:\Program Files\Octopus Deploy\Tentacle'
default['octopus']['tentacle']['port'] = '10933'
default['octopus']['tentacle']['home'] = node['octopus']['home']
default['octopus']['tentacle']['role'] = 'webserver'
default['octopus']['tentacle']['name'] = 'Tentacle'
default['octopus']['tentacle']['environment'] = node.chef_environment

default['octopus']['server']['package_url'] = 'https://download.octopusdeploy.com/octopus/Octopus.3.0.23.0-x64.msi'
default['octopus']['server']['package_checksum'] = '55be100bac5e1a1d48d4c6beb2038cd958a704de82b1cf16a0f09836c104d7fd'
default['octopus']['server']['package_name'] = 'Octopus Deploy Server'
default['octopus']['server']['install_dir'] = 'C:\Program Files\Octopus Deploy\Octopus'
default['octopus']['server']['home'] = node['octopus']['home']
default['octopus']['server']['name'] = 'OctopusServer'
default['octopus']['server']['web_bindings'] = ['localhost', 'my-octopus-server.com']
default['octopus']['server']['web_port'] = '80'
default['octopus']['server']['web_protocol'] = 'http'
default['octopus']['server']['sql_hostname'] = '127.0.0.1'
default['octopus']['server']['sql_port'] = '1433'
default['octopus']['server']['sql_dbname'] = 'octopus'
default['octopus']['server']['data_bag'] = 'octopus'
default['octopus']['server']['authentication_type'] = 'UsernamePassword' # to use active directory, set as 'Domain'

default['octopus']['server']['thumbprint'] = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' # replace with your octopus server thumbprint

default['octopus']['tools']['url'] = 'http://download.octopusdeploy.com/octopus-tools/2.5.10.39/OctopusTools.2.5.10.39.zip'
default['octopus']['tools']['checksum'] = '0790ed04518e0b50f3000093b4a2b4ad47f0f5c9af269588e82d960813abfd67'
default['octopus']['tools']['home'] = 'C:\tools\OctopusTools.2.5.10.39'

# replace with your octopus server api endpoint and key
default['octopus']['api']['uri'] = 'http://my-octopus-server.com/api'
default['octopus']['api']['key'] = 'API-XXXXXXXXXXXXXXXXXXXXXXXXXXX'
