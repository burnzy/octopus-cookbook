#
# Cookbook Name:: octopus
# Recipe:: remove_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

# remove the tentacle service 
windows_package node['octopus']['tentacle']['package_name'] do
	source node['octopus']['tentacle']['url']
	checksum node['octopus']['tentacle']['checksum']
	options "INSTALLLOCATION=\"#{node['octopus']['tentacle']['install_dir']}\""
	action :remove
end

# remove the tentacle tools
directory node['octopus']['tools']['home'] do
	recursive true
	action :delete
end
