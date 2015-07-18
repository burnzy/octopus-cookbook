#
# Cookbook Name:: octopus
# Recipe:: register_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

# register the tentacle with octopus server
powershell_script "create_tentacle_environment" do
	code <<-EOH
	Set-Alias octo "#{node['octopus']['tools']['home']}\\Octo.exe"
	octo create-environment --name #{node['octopus']['tentacle']['environment']} --ignoreIfExists --server=#{node['octopus']['api']['uri']} --apiKey=#{node['octopus']['api']['key']}
	EOH
end