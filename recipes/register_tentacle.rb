#
# Cookbook Name:: octopus
# Recipe:: register_tentacle
#
# Author:: Michael Burns (<michael.burns@shawmedia.ca>)
#
# Copyright 2014-2015, Shaw Media Inc.
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

tentacle = node['octopus']['tentacle']
server = node['octopus']['server']
api = node['octopus']['api']

unless (node['octopus']['tentacle']['role']).nil? || (node['octopus']['tentacle']['role']) == 0
	rolelist = nil
		(node['octopus']['tentacle']['role']).each do |role|
		if rolelist.nil? || rolelist == 0
			rolelist = "--role=#{role}"
		else
			rolelist << " --role=#{role}"
		end
		end
	rolelist = rolelist.strip
end

# register the tentacle with octopus server
powershell_script "register_tentacle" do
  code <<-EOH
	  set-alias tentacle "#{tentacle['install_dir']}\\Tentacle.exe"
	  tentacle create-instance --instance "#{tentacle['name']}" --config "#{tentacle['home']}\\Tentacle\\Tentacle.config" --console
	  tentacle new-certificate --instance "#{tentacle['name']}" --console
	  tentacle configure --instance "#{tentacle['name']}" --home "#{tentacle['home']}\\" --console
	  tentacle configure --instance "#{tentacle['name']}" --app "#{tentacle['home']}\\Applications" --console
	  if ('#{tentacle['type']}' -eq "listening") {
			tentacle configure --instance "#{tentacle['name']}" --port "#{tentacle['port']}" --console
			tentacle configure --instance "#{tentacle['name']}" --trust "#{server['thumbprint']}" --console
		  tentacle register-with --instance "#{tentacle['name']}" --name="#{tentacle['name']}" --publicHostName=#{node['ipaddress']} --server=#{api['uri']} --apiKey=#{api['key']} #{rolelist} --environment=#{tentacle['environment']} --comms-style TentaclePassive --console
	  }
	  if ('#{tentacle['type']}' -eq "polling") {
			tentacle configure --instance "#{tentacle['name']}" --trust "#{server['thumbprint']}" --console
			tentacle register-with --instance "#{tentacle['name']}" --name="#{tentacle['name']}" --server=#{api['uri']} --apiKey=#{api['key']} #{rolelist} --environment=#{tentacle['environment']} --comms-style TentacleActive --force --console
	  }
	  tentacle service --instance "#{tentacle['name']}" --install --start --console
	EOH
  not_if {::File.exists?("#{tentacle['home']}\\Tentacle\\Tentacle.config")}
end
