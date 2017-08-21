#
# Cookbook Name:: octopus
# Recipe:: register_environment_tentacle
#
# Author:: Ivan Marx
#
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
server = node['octopus']['server']
api = node['octopus']['api']

octoposhPath = "#{Chef::Config['file_cache_path']}/octoposh.ps1"

template octoposhPath do
  source 'octoposh.ps1.erb'
end


powershell_script 'register_tentacle_in_environment_if_not_there' do	
	guard_interpreter :powershell_script
	code <<-EOH	
	$ErrorActionPreference = 'Stop'
	$ProgressPreference='SilentlyContinue'
	Add-Type -Path '#{node['octopus']['tentacle']['install_dir']}\\Octopus.Client.dll'
	. "#{octoposhPath}"

	$apikey = '#{node['octopus']['api']['key']}' # Get this from your profile
	$octopusURI = '#{node['octopus']['api']['uri']}' # Your Octopus Server address
	$environments = '#{node['octopus']['environment'].to_json}' | ConvertFrom-Json			
	Set-OctopusConnectionInfo -URL $octopusURI -APIKey $apikey | out-null
	
	foreach($environmentProp in $environments.psobject.Properties)
	{
		Try{$environment = Get-OctopusEnvironment -Name $environmentProp.Name}Catch{$environment = $null}
		foreach($tentacle in $environmentProp.Value.tentacles)
		{
			Try{$machine = Get-OctopusMachine -Name $tentacle}Catch{$machine = $null}
			if($machine -ne $null -and $environment -ne $null)
			{
				$machineChanged = $false

				if(-not $machine.Resource.EnvironmentIds.Contains($environment.Resource.Id))
				{
					$machineChanged =$true
					$machine.Resource.EnvironmentIds.Add($environment.Resource.Id)
				}

				if ($machineChanged) {
						$machine | Update-OctopusResource -Force
				}       
			}
		}
	}		
	EOH
	only_if <<-EOH4
	$ErrorActionPreference = 'Stop'
	$ProgressPreference='SilentlyContinue'
	Add-Type -Path '#{node['octopus']['tentacle']['install_dir']}\\Octopus.Client.dll'
	. "#{octoposhPath}"

	$apikey = '#{node['octopus']['api']['key']}' # Get this from your profile
	$octopusURI = '#{node['octopus']['api']['uri']}' # Your Octopus Server address
	$environments = '#{node['octopus']['environment'].to_json}' | ConvertFrom-Json			
	
	$machineChanged = $false
	Set-OctopusConnectionInfo -URL $octopusURI -APIKey $apikey | out-null

	foreach($environmentProp in $environments.psobject.Properties)
	{
			 Try{$environment = Get-OctopusEnvironment -Name $environmentProp.Name}Catch{$environment = $null}
			 foreach($tentacle in $environmentProp.Value.tentacles)
			 {
					 Try{$machine = Get-OctopusMachine -Name $tentacle}Catch{$machine = $null}
					 if($machine -ne $null -and $environment -ne $null)
					 {                         

							 if(-not $machine.Resource.EnvironmentIds.Contains($environment.Resource.Id))
							 {
									 $machineChanged =$true                                 
							 }                         
					 }
			 }
	}
	return $machineChanged
    EOH4
end