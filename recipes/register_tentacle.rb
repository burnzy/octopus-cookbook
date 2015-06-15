#
# Cookbook Name:: octopus
# Recipe:: register_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

# register the tentacle with octopus server
powershell_script "register_tentacle" do
	code <<-EOH
	Set-Alias tentacle "#{node['octopus']['tentacle']['install_dir']}\\Tentacle.exe"
	tentacle create-instance --instance "#{node.name}" --config "#{node['octopus']['tentacle']['home']}\\Tentacle\\Tentacle.config" --console
	tentacle new-certificate --instance "#{node.name}" --console
	tentacle configure --instance "#{node.name}" --home "#{node['octopus']['tentacle']['home']}\\" --console
	tentacle configure --instance "#{node.name}" --app "#{node['octopus']['tentacle']['home']}\\Applications" --console
	tentacle configure --instance "#{node.name}" --port "#{node['octopus']['tentacle']['port']}" --console
	tentacle configure --instance "#{node.name}" --trust "#{node['octopus']['server']['thumbprint']}" --console
	tentacle register-with --instance "#{node.name}" --name="#{node.name}" --publicHostName=#{node['ipaddress']} --server=#{node['octopus']['api']['uri']} --apiKey=#{node['octopus']['api']['key']} --role=#{node['octopus']['tentacle']['role']} --environment=#{node.chef_environment} --comms-style TentaclePassive --console
	tentacle service --instance "#{node.name}" --install --start --console
	EOH
	not_if {::File.exists?("#{node['octopus']['tentacle']['home']}\\Tentacle\\Tentacle.config")}
end