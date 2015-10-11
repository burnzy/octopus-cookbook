#
# Cookbook Name:: octopus
# Recipe:: install_tentacle
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

# download and install the tentacle service
windows_package tentacle['package_name'] do
  source tentacle['url']
  checksum tentacle['checksum']
  options "INSTALLLOCATION=\"#{tentacle['install_dir']}\""
  action :install
end

octo_exe_path = win_friendly_path("#{tools['home']}/octo.exe")

# download and unzip octopus tools
windows_zipfile tools['home'] do
  source tools['url']
  checksum tools['checksum']
  action :unzip
  not_if { ::File.exists?(octo_exe_path) } 
end
