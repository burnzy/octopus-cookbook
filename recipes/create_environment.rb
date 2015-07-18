#
# Cookbook Name:: octopus
# Recipe:: create_environment
#

tentacle = node['octopus']['tentacle']
api = node['octopus']['api']

# create environment
powershell_script "create_environment" do
	code <<-EOH
	Set-Alias octo "#{node['octopus']['tools']['home']}\\Octo.exe"
	octo create-environment --name #{tentacle['environment']} --ignoreIfExists --server=#{api['uri']} --apiKey=#{api['key']}
	EOH
end
