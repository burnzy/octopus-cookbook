#
# Cookbook Name:: octopus
# Recipe:: create_environment
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
api = node['octopus']['api']

# create environment
powershell_script "create_environment" do
	code <<-EOH
	Set-Alias octo "#{node['octopus']['tools']['home']}\\Octo.exe"
	octo create-environment --name #{tentacle['environment']} --ignoreIfExists --server=#{api['uri']} --apiKey=#{api['key']}
	EOH
end
