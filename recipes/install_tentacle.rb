#
# Cookbook Name:: octopus
# Recipe:: install_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

# download and install the tentacle service  
windows_package node['octopus']['tentacle']['package_name'] do
	source node['octopus']['tentacle']['url']
	checksum node['octopus']['tentacle']['checksum']
	options "INSTALLLOCATION=\"#{node['octopus']['tentacle']['install_dir']}\""
	action :install
end

# download and unzip octopus tools
windows_zipfile node['octopus']['tools']['home'] do
	source node['octopus']['tools']['url']
	checksum node['octopus']['tools']['checksum']
	action :unzip
	not_if {::File.exists?("#{node['octopus']['tools']['home']}\\Octo.exe")}
end
