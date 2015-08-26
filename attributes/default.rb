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

default['octopus']['server']['package_url'] = 'https://download.octopusdeploy.com/octopus/Octopus.3.0.19.2485-x64.msi'
default['octopus']['server']['package_checksum'] = '1aeefc7da731a028ff0cf8a9e3cfd557aa365d61992a46445f8d937a3a71258e'
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
#default['octopus']['server']['sql_username'] = 'my_octopus_db_username'
#default['octopus']['server']['sql_password'] = 'my_octopus_db_password'
#default['octopus']['server']['connection_string'] = "Data Source=#{node['octopus']['server']['sql_hostname']};Initial Catalog=#{node['octopus']['server']['sql_dbname']};Integrated Security=False;User ID=#{node['octopus']['server']['sql_username']};Password=#{node['octopus']['server']['sql_password']}"
default['octopus']['server']['data_bag'] = 'octopus'

default['octopus']['server']['admin_username'] = 'admin'
default['octopus']['server']['admin_password'] = 'octoadmin@123ABC'
default['octopus']['server']['master_key'] = 'master_key_for_backups' # master encryption key for octopus backups
default['octopus']['server']['license_base64'] = 'UHV0IHlvdXIgb2N0b3B1cyBsaWNlbnNlIGhlcmU=' # put octopus license here (base64 encoded) - `echo -n 'Put your octopus license here' | openssl base64`
default['octopus']['server']['thumbprint'] = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' # replace with your octopus server thumbprint

default['octopus']['tools']['url'] = 'http://download.octopusdeploy.com/octopus-tools/2.5.10.39/OctopusTools.2.5.10.39.zip'
default['octopus']['tools']['checksum'] = '0790ed04518e0b50f3000093b4a2b4ad47f0f5c9af269588e82d960813abfd67'
default['octopus']['tools']['home'] = 'C:\tools\OctopusTools.2.5.10.39'

# replace with your octopus server api endpoint and key
default['octopus']['api']['uri'] = 'http://my-octopus-server.com/api'
default['octopus']['api']['key'] = 'API-XXXXXXXXXXXXXXXXXXXXXXXXXXX'
