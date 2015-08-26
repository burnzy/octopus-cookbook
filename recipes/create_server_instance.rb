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
octopus_data_bag = server['data_bag']

unless octopus_data_bag
  Chef::Log.warn("node['octopus']['server']['data_bag'] was set to false. Not configuring octopus server or secrets.")
  return
end

# try loading encrypted data bag
octopus_secrets = nil
begin
  octopus_secrets = Chef::EncryptedDataBagItem.load(octopus_data_bag, 'secrets')
  octopus_secrets = octopus_secrets.to_hash
rescue
  Chef::Log.warn("Could not find encrypted data bag item #{octopus_data_bag}/secrets")
  octopus_secrets = nil
end

if octopus_secrets.nil?
  Chef::Log.warn('Could not find an encrypted data bag to use for octopus secrets')
  return
else
  # make sure all required secrets exist in encrypted data bag
  required_secrets = %w(sql_user_name sql_user_password sql_admin_name sql_admin_password license_base64)
  required_secrets.each do |secret|
    unless octopus_secrets.key?(secret)
      Chef::Log.warn("Found a data bag for octopus secrets, but it was missing \`#{secret}\`")
      return -1
    end
  end

  # add secrets to node.run_state
  octopus_secrets.each do |secret_item, secret_value|
    node.run_state["octopus_#{secret_item}"] = secret_value
  end

  # create connection string
  node.run_state['octopus_connection_string'] = "Data Source=#{server['sql_hostname']};Initial Catalog=#{server['sql_dbname']};Integrated Security=False;User ID=#{node.run_state['octopus_sql_user_name']};Password=#{node.run_state['octopus_sql_user_password']}"
end

# prepare sql server connection
sql_server_connection_info = {
  :host => server['sql_hostname'],
  :port => server['sql_port'],
  :username => node.run_state['octopus_sql_admin_user'],
  :password => node.run_state['octopus_sql_admin_password']
}

# create a sql server database
sql_server_database server['sql_dbname'] do
  connection sql_server_connection_info
  action :create
end

# create a sql server user and grant access to octopus database
sql_server_database_user node.run_state['octopus_sql_user_name'] do
  connection sql_server_connection_info
  password node.run_state['octopus_sql_user_password']
  database_name server['sql_dbname']
  sql_roles :db_owner => :ADD
  action :alter_roles
end

# path to octopus.server.exe
octopus_server_exe = win_friendly_path("#{server['install_dir']}/octopus.server.exe")

# generate the octopus web bindings
octopus_web_bindings = server['web_bindings'].map { |binding| "#{server['web_protocol']}://#{binding}:#{server['web_port']}" }

execute 'create_instance' do
  cwd server['install_dir']
  command <<-EOH
    octopus.server.exe create-instance --instance '#{server['name']}' --config '#{server['home']}\\OctopusServer.config'
  EOH
end

execute 'configure_octopus_home' do
  cwd server['install_dir']
  command <<-EOH
    octopus.server.exe configure --instance "#{server['name']}" --home "#{server['home']}"
  EOH
end

execute 'configure_connection_string' do
  cwd server['install_dir']
  command <<-EOH
    octopus.server.exe configure --instance "#{server['name']}" --storageConnectionString "#{node.run_state['octopus_connection_string']}" --upgradeCheck "False" --upgradeCheckWithStatistics "False" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "#{octopus_web_bindings.join(',')}" --commsListenPort "10943" --serverNodeName "#{node['hostname']}"
  EOH
end

execute 'create_database' do
  cwd server['install_dir']
  command <<-EOH
    octopus.server.exe database --instance "#{server['name']}" --create
  EOH
end

execute 'stop_service' do
  cwd server['install_dir']
  command <<-EOH
    octopus.server.exe service --instance "#{server['name']}" --stop
  EOH
end

execute 'configure_admin_account' do
  cwd server['install_dir']
  command <<-EOH
    octopus.server.exe admin --instance "#{server['name']}" --username "#{server['admin_username']}" --password "#{server['admin_password']}"
  EOH
end

execute 'configure_license' do
  cwd server['install_dir']
  command <<-EOH
    octopus.server.exe license --instance "#{server['name']}" --licenseBase64 "#{node.run_state['octopus_license_base64']}"
  EOH
end

execute 'start_service' do
  cwd server['install_dir']
  command <<-EOH
    octopus.server.exe service --instance "#{server['name']}" --install --reconfigure --start
  EOH
end


# # create octopus server instance
# powershell_script 'create_octopus_server_instance' do
#   code <<-EOH
#   set-alias server "#{octopus_server_exe}"
#   server create-instance --instance "#{server['name']}" --config "#{server['home']}\\OctopusServer.config"
#   server configure --instance "#{server['name']}" --home "#{server['home']}"
#   server configure --instance "#{server['name']}" --storageConnectionString "#{node.run_state['octopus_connection_string']}" --upgradeCheck "False" --upgradeCheckWithStatistics "False" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "#{octopus_web_bindings.join(',')}" --commsListenPort "10943" --serverNodeName "#{node['hostname']}"
#   server database --instance "#{server['name']}" --create
#   server service --instance "#{server['name']}" --stop
#   server admin --instance "#{server['name']}" --username "#{server['admin_username']}" --password "#{server['admin_password']}"
#   server license --instance "#{server['name']}" --licenseBase64 "#{node.run_state['octopus_license_base64']}"
#   server service --instance "#{server['name']}" --install --reconfigure --start
#   EOH
#   action :run
#   #not_if { ::File.exist?("#{server['home']}\\OctopusServer.config") || node.run_state['octopus_connection_string'].nil? }
# end
