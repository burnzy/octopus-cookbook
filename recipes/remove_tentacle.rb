#
# Cookbook Name:: octopus
# Recipe:: remove_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

tentacle = node['octopus']['tentacle']
tools = node['octopus']['tools']

# remove the tentacle service
windows_package tentacle['package_name'] do
	source tentacle['url']
	checksum tentacle['checksum']
	options "INSTALLLOCATION=\"#{tentacle['install_dir']}\""
	action :remove
end

# remove the tentacle tools
directory tools['home'] do
	recursive true
	action :delete
end
