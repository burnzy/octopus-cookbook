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
  required_secrets = %w(sql_user_username sql_user_password sql_admin_username sql_admin_password admin_username license_base64)
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
  node.run_state['octopus_connection_string'] = "Data Source=#{server['sql_hostname']};Initial Catalog=#{server['sql_dbname']};Integrated Security=False;User ID=#{node.run_state['octopus_sql_user_username']};Password=#{node.run_state['octopus_sql_user_password']}"
end

# prepare sql server connection
sql_server_connection_info = {
  :host => server['sql_hostname'],
  :port => server['sql_port'],
  :username => node.run_state['octopus_sql_admin_username'],
  :password => node.run_state['octopus_sql_admin_password']
}

# create a sql server database
sql_server_database server['sql_dbname'] do
  connection sql_server_connection_info
  action :create
end

# create a sql server user and grant access to octopus database
sql_server_database_user node.run_state['octopus_sql_user_username'] do
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

# set the admin user command based on authentication_type
case server['authentication_type']
when 'UsernamePassword'
  if node.run_state['octopus_admin_password'].nil?
    Chef::Log.warn('Could not find an octopus admin password: please set in data bag to use UsernamePassword authentication')
    return
  else
    node.run_state['octopus_admin_cmd'] = "--username \"#{node.run_state['octopus_admin_username']}\" --password \"#{node.run_state['octopus_admin_password']}\""
  end
when 'Domain'
  node.run_state['octopus_admin_cmd'] = "--username \"#{node.run_state['octopus_admin_username']}\""
end

# create octopus server instance
powershell_script 'create_octopus_server_instance' do
  code <<-EOH
  set-alias server "#{octopus_server_exe}"
  server create-instance --instance "#{server['name']}" --config "#{server['home']}\\OctopusServer.config" --console
  server configure --instance "#{server['name']}" --home "#{server['home']}" --console
  server configure --instance "#{server['name']}" --storageConnectionString "#{node.run_state['octopus_connection_string']}" --upgradeCheck "False" --upgradeCheckWithStatistics "False" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "#{octopus_web_bindings.join(',')}" --commsListenPort "10943" --serverNodeName "#{node['hostname']}" --console
  server database --instance "#{server['name']}" --create --console
  server service --instance "#{server['name']}" --stop --console
  server admin --instance "#{server['name']}"  "#{node.run_state['octopus_admin_cmd']}" --console
  server license --instance "#{server['name']}" --licenseBase64 "#{node.run_state['octopus_license_base64']}" --console
  server service --instance "#{server['name']}" --install --reconfigure --start --console
  EOH
  action :run
  not_if { ::File.exist?("#{server['home']}\\OctopusServer.config") || node.run_state['octopus_connection_string'].nil? }
end
