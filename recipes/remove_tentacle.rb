#
# Cookbook Name:: octopus
# Recipe:: remove_tentacle
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
