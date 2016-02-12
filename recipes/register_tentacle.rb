#
# Cookbook Name:: octopus
# Recipe:: register_tentacle
#
# Copyright 2014, Shaw Media Inc.
#
# All rights reserved - Do Not Redistribute
#

# register the tentacle with octopus server

octoposhPath = "#{Chef::Config['file_cache_path']}/octoposh.ps1"

template octoposhPath do
  source 'octoposh.ps1.erb'
end

powershell_script "configure_tentacle_locally" do
	code <<-EOH
	Set-Alias tentacle "#{node['octopus']['tentacle']['install_dir']}\\Tentacle.exe"
	tentacle create-instance --instance "#{node['octopus']['tentacle']['name']}" --config "#{node['octopus']['tentacle']['home']}\\Tentacle\\Tentacle.config" --console
	tentacle new-certificate --instance "#{node['octopus']['tentacle']['name']}" --console
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --home "#{node['octopus']['tentacle']['home']}\\" --console
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --app "#{node['octopus']['tentacle']['home']}\\Applications" --console
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --port "#{node['octopus']['tentacle']['port']}" --console
	tentacle configure --instance "#{node['octopus']['tentacle']['name']}" --trust "#{node['octopus']['server']['thumbprint']}" --console
	tentacle service --instance "#{node['octopus']['tentacle']['name']}" --install --start --console
	EOH
	not_if {::File.exists?("#{node['octopus']['tentacle']['home']}\\Tentacle\\Tentacle.config")}
end

powershell_script "configure_tentacle_on_server" do
	code <<-EOH
	$ErrorActionPreference = 'Stop'
	$ProgressPreference='SilentlyContinue'
	Add-Type -Path '#{node['octopus']['tentacle']['install_dir']}\\Octopus.Client.dll'
	#{octoposhPath}

	Function Get-CurrentTentacleThumbprint
	{
		$subject = &'#{node['octopus']['tentacle']['install_dir']}\\Tentacle.exe' show-thumbprint --nologo
		$result = $subject -creplace '((?:The thumbprint of this Tentacle is: )+)(?<field2>(?:[0-9a-zA-Z]+))', '${field2}'
		return $result
	}

	$apikey = '#{node['octopus']['api']['key']}' # Get this from your profile
	$octopusURI = '#{node['octopus']['api']['uri']}' # Your Octopus Server address
	$machineName = '#{node['octopus']['tentacle']['name']}"'
	$publicHostName = '#{node['octopus']['tentacle']['publichostname']}"'
	$port = '#{node['octopus']['tentacle']['port']}'
	$expectedEnvironments = @('#{node['octopus']['tentacle']['environment']}') -split ',' | %{$_.Trim()} |?{$_}
	$expectedRoles = @('#{node['octopus']['tentacle']['role']}') -split ',' | %{$_.Trim()} |?{$_}
	$expectedThumbprint = Get-CurrentTentacleThumbprint

	Set-OctopusConnectionInfo -URL $octopusURI -APIKey $apikey

	$expectedEnvironmentIds =  @()
	$expectedEnvironments | %{
		$environment = Get-OctopusEnvironment -EnvironmentName $_

		if (!($environment)) {
			throw "There is no environment called $_"
		}
		$expectedEnvironmentIds += $environment.Id
	}

	$machine = Get-OctopusMachine -Name $machineName

	if ($machine) {
		$machineChanged = $false

		if ($expectedThumbprint -ne $machine.Resource.Thumbprint) {
			write-host "Update machine to use new thumbprint $expectedThumbprint"
			$machine.Resource.Thumbprint = $expectedThumbprint
		}

		if ($machineChanged) {
			$machine | Update-OctopusResource
		}
	} else {
		#Create an instance of a Machine Object
		$machine = Get-OctopusResourceModel -Resource Machine

		#Add mandatory properties to the object
		$machine.name = $machineName #Display name of the machine on Octopus

		$expectedEnvironmentIds | %{
			$machine.EnvironmentIds.Add($_) #Environment where you want to register the machine
		}

		$expectedRoles | %{
			$machine.Roles.Add($_) #Only one Role can be added at a time	
		}

		$machineEndpoint = New-Object Octopus.Client.Model.Endpoints.ListeningTentacleEndpointResource
		$machine.EndPoint = $machineEndpoint
		$machine.Endpoint.Uri = "https://$($publicHostName):$($port)/" #URI of the machine.
		$machine.Endpoint.Thumbprint = $expectedThumbprint #Thumbprint of the machine

		New-OctopusResource -Resource $machine
	}
	EOH
    not_if <<-EOH
	$ErrorActionPreference = 'Stop'
	$ProgressPreference='SilentlyContinue'
	Add-Type -Path '#{node['octopus']['tentacle']['install_dir']}\\Octopus.Client.dll'
	#{octoposhPath}

	Function Get-CurrentTentacleThumbprint
	{
		$subject = &'#{node['octopus']['tentacle']['install_dir']}\\Tentacle.exe' show-thumbprint --nologo
		$result = $subject -creplace '((?:The thumbprint of this Tentacle is: )+)(?<field2>(?:[0-9a-zA-Z]+))', '${field2}'
		return $result
	}

	$apikey = '#{node['octopus']['api']['key']}' # Get this from your profile
	$octopusURI = '#{node['octopus']['api']['uri']}' # Your Octopus Server address
	$machineName = '#{node['octopus']['tentacle']['name']}"'

	Set-OctopusConnectionInfo -URL $octopusURI -APIKey $apikey
	$machine = Get-OctopusMachine -Name $machineName

	if ($machine) {
		$expectedThumbprint = Get-CurrentTentacleThumbprint
		if ($expectedThumbprint -ne $machine.Resource.Thumbprint) {
			return $false
		} else {
			return $true		
		}
	} else {
		return $false
	}
    EOH	
end

powershell_script 'configure_tentacle_with_latest_calamari' do
	guard_interpreter :powershell_script
	code <<-EOH
	$ErrorActionPreference = 'Stop'
	$ProgressPreference='SilentlyContinue'
	Add-Type -Path '#{node['octopus']['tentacle']['install_dir']}\\Octopus.Client.dll'
	#{octoposhPath}

	$apikey = '#{node['octopus']['api']['key']}' # Get this from your profile
	$octopusURI = '#{node['octopus']['api']['uri']}' # Your Octopus Server address
	$machineName = '#{node['octopus']['tentacle']['name']}"'

	Set-OctopusConnectionInfo -URL $octopusURI -APIKey $apikey

	Start-OctopusCalamariUpdate -MachineName $machineName -Wait
	EOH
	action :run
    not_if <<-EOH
	$ErrorActionPreference = 'Stop'
	$ProgressPreference='SilentlyContinue'
	Add-Type -Path '#{node['octopus']['tentacle']['install_dir']}\\Octopus.Client.dll'
	#{octoposhPath}

	$apikey = '#{node['octopus']['api']['key']}' # Get this from your profile
	$octopusURI = '#{node['octopus']['api']['uri']}' # Your Octopus Server address
	$machineName = '#{node['octopus']['tentacle']['name']}"'
	
	Set-OctopusConnectionInfo -URL $octopusURI -APIKey $apikey
	$machine = Get-OctopusMachine -Name $machineName

	if ($machine -and $machine.Resource.HasLatestCalamari){
		return $true
	} else {
		return $false
	}
    EOH
end
