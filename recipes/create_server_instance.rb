#
# Cookbook Name:: octopus
# Recipe:: create_server_instance
#
# Author:: Michael Burns (<michael.burns@shawmedia.ca>)
#
# Copyright 2015, Shaw Media Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# assign attributes to local variables
server = node['octopus']['server']
tools = node['octopus']['tools']
octopus_data_bag = node['octopus']['data_bag']

unless octopus_data_bag
  Chef::Log.warn("node['octopus']['data_bag'] was set to false. Not configuring octopus server or secrets.")
  return
end

# try loading encrypted data bag
octopus_secrets = nil
begin
  octopus_secrets = Chef::EncryptedDataBagItem.load(octopus_data_bag, 'secrets')
  octopus_secrets.to_hash # access it to force an error to be raised
rescue
  Chef::Log.warn("Could not find encrypted data bag item #{octopus_data_bag}/secrets")
  octopus_secrets = nil
end

if !octopus_secrets.nil? && octopus_secrets['sql_username'] && octopus_secrets['sql_password'] && octopus_secrets['sql_dbname']
	node.run_state['octopus_sql_username'] = octopus_secrets['sql_username']
	node.run_state['octopus_sql_password'] = octopus_secrets['sql_password']
	node.run_state['octopus_sql_dbname'] = octopus_secrets['sql_dbname']
	node.run_state['octopus_license_base64'] = octopus_secrets['license_base64']
	node.run_state['octopus_connection_string'] = "Data Source=#{server['sql_hostname']};Initial Catalog=#{node.run_state['sql_dbname']};Integrated Security=False;User ID=#{node.run_state['octopus_sql_username']};Password=#{node.run_state['octopus_sql_password']}"
elsif !octopus_secrets.nil?
  Chef::Log.warn('Found a data bag for octopus secrets, but it was missing a required data bag item')
elsif octopus_secrets.nil?
	Chef::Log.warn('Could not find an encrypted data bag to use for octopus secrets')
end

# path to octopus.server.exe
octopus_server_exe = win_friendly_path("#{server['install_dir']}/octopus.server.exe")

# create octopus server instance
powershell_script 'create_octopus_server_instance' do
	code <<-eos
	set-alias server "#{octopus_server_exe}"

	server create-instance --instance "#{server['name']}" --config "#{server['home']}\\OctopusServer.config" | out-default
	server configure --instance "#{server['name']}" --home "#{server['home']}"
	server configure --instance "#{server['name']}" --storageConnectionString #{node.run_state['octopus_connection_string']} --upgradeCheck "False" --upgradeCheckWithStatistics "False" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "#{ server['bindings'].length > 1 ? server['bindings'].each { |binding| puts "#{binding}:80/" }.join(',') :  "server['bindings']:80/" }" --commsListenPort "10943" --serverNodeName "#{node['hostname']}"
	server database --instance "#{server['name']}" --create
	server service --instance "#{server['name']}" --stop
	server admin --instance "#{server['name']}" --username "#{server['admin_username']}" --password "#{server['admin_password']}"
	server license --instance "#{server['name']}" --licenseBase64 "#{node.run_state['octopus_license_base64']}"
	server service --instance "#{server['name']}" --install --reconfigure --start

	eos
	not_if {::File.exists?("#{server['home']}\\OctopusServer.config")}
end
