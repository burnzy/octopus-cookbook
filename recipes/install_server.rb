#
# Cookbook Name:: octopus
# Recipe:: install_server
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

server = node['octopus']['server']

# define service
service 'OctopusDeploy' do
  supports :status => true, :restart => true
  action :nothing
end

# download and install the octopus server
package server['package_name'] do
  source server['package_url']
  checksum server['package_checksum']
  options "INSTALLLOCATION=\"#{server['install_dir']}\""
  action :install
  notifies :restart, 'service[OctopusDeploy]', :immediately
end
