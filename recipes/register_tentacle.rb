#
# Cookbook Name:: octopus
# Recipe:: register_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

tentacle = node['octopus']['tentacle']
server = node['octopus']['server']
api = node['octopus']['api']

# register the tentacle with octopus server
powershell_script "register_tentacle" do
	code <<-EOH
	set-alias tentacle "#{tentacle['install_dir']}\\Tentacle.exe"
	tentacle create-instance --instance "#{tentacle['name']}" --config "#{tentacle['home']}\\Tentacle\\Tentacle.config" --console
	tentacle new-certificate --instance "#{tentacle['name']}" --console
	tentacle configure --instance "#{tentacle['name']}" --home "#{tentacle['home']}\\" --console
	tentacle configure --instance "#{tentacle['name']}" --app "#{tentacle['home']}\\Applications" --console
	tentacle configure --instance "#{tentacle['name']}" --port "#{tentacle['port']}" --console
	tentacle configure --instance "#{tentacle['name']}" --trust "#{server['thumbprint']}" --console
	tentacle register-with --instance "#{tentacle['name']}" --name="#{tentacle['name']}" --publicHostName=#{node['ipaddress']} --server=#{api['uri']} --apiKey=#{api['key']} --role=#{tentacle['role']} --environment=#{tentacle['environment']} --comms-style TentaclePassive --console
	tentacle service --instance "#{tentacle['name']}" --install --start --console
	EOH
	not_if {::File.exists?("#{tentacle['home']}\\Tentacle\\Tentacle.config")}
end
