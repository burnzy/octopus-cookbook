#
# Cookbook Name:: octopus
# Recipe:: register_tentacle
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
server = node['octopus']['server']
api = node['octopus']['api']

# register the tentacle with octopus server

octoposhPath = "#{Chef::Config['file_cache_path']}/octoposh.ps1"

template octoposhPath do
  source 'octoposh.ps1.erb'
end


powershell_script 'create_octopus_team_if_not_exists' do
	guard_interpreter :powershell_script
	code <<-EOH3
	$ErrorActionPreference = 'Stop'
	$ProgressPreference='SilentlyContinue'
	Add-Type -Path '#{node['octopus']['tentacle']['install_dir']}\\Octopus.Client.dll'
	. "#{octoposhPath}"

	$apikey = '#{node['octopus']['api']['key']}' # Get this from your profile
	$octopusURI = '#{node['octopus']['api']['uri']}' # Your Octopus Server address
	$teamName = '#{node['octopus']['team']['name']}'	
	$teamRoles = @('#{node['octopus']['team']['roles'].join(',')}') -split ',' | %{$_.Trim()} |?{$_}	
	$teamEnvironments = @('#{node['octopus']['team']['environments'].join(',')}') -split ',' | %{$_.Trim()} |?{$_}	
	$can_be_deleted = '#{node['octopus']['team']['can_be_deleted']}'	
	$can_be_renamed = '#{node['octopus']['team']['can_be_renamed']}'
	$can_change_roles = '#{node['octopus']['team']['can_change_roles']}'
	$can_change_members = '#{node['octopus']['team']['can_change_members']}'
	
	Set-OctopusConnectionInfo -URL $octopusURI -APIKey $apikey
	
	$team = Get-OctopusResourceModel -Resource Team
    $team.Name = $teamName 

    $team.UserRoleIds  = New-Object Octopus.Client.Model.ReferenceCollection
	$teamRoles | %{
		$team.UserRoleIds.Add($_)
	}
    
    $team.CanBeDeleted=$can_be_deleted
    $team.CanBeRenamed=$can_be_renamed
    $team.CanChangeRoles=$can_change_roles
    $team.CanChangeMembers=$can_change_members
    $team.EnvironmentIds= New-Object Octopus.Client.Model.ReferenceCollection
	
	$teamEnvironments  | %{
		$environment = Get-OctopusEnvironment -EnvironmentName $_
		$team.EnvironmentIds.Add($environment.Id)
	}    

    New-OctopusResource -Resource $team
	EOH3
    only_if <<-EOH4
	$ErrorActionPreference = 'Stop'
	$ProgressPreference='SilentlyContinue'
	Add-Type -Path '#{node['octopus']['tentacle']['install_dir']}\\Octopus.Client.dll'
	. "#{octoposhPath}"

	$apikey = '#{node['octopus']['api']['key']}' # Get this from your profile
	$octopusURI = '#{node['octopus']['api']['uri']}' # Your Octopus Server address
	$teamName = '#{node['octopus']['team']['name']}'
	
	Set-OctopusConnectionInfo -URL $octopusURI -APIKey $apikey | out-null
	
	Try{$existingTeam =  Get-OctopusTeam -Name $teamName }Catch{$existingTeam=$null}
	
	if ($existingTeam){
		return $false
	} else {
		return $true
	}
    EOH4
end