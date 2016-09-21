function GetOctopusTenants
{
    [CmdletBinding()]
    Param
    (
        # Octopus URL
        [Parameter(Mandatory=$true)]
        [string]$URL,

        # Octopus API Key
        [Parameter(Mandatory=$true)]
        [string]$APIKey
    )
    
    return GetOctopusMembers $URL $APIKey "tenants"
}

function GetOctopusEnvironments
{
    [CmdletBinding()]
    Param
    (
        # Octopus URL
        [Parameter(Mandatory=$true)]
        [string]$URL,

        # Octopus API Key
        [Parameter(Mandatory=$true)]
        [string]$APIKey
    )
    
    return GetOctopusMembers $URL $APIKey "environments"
}

function GetOctopusTenantNamesForEnvironment
{
    [CmdletBinding()]
    Param
    (
        # Octopus URL
        [Parameter(Mandatory=$true)]
        [string]$URL,

        # Octopus API Key
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        # Octopus Environment name
        [Parameter(Mandatory=$true)]
        [string]$EnvironmentName
    )
    
    $octopusTenants = GetOctopusTenants $URL $APIKey
    $octopusEnvironments = GetOctopusEnvironments $URL $APIKey

    $selectedEnvironment = $octopusEnvironments | where { $_.Name -eq $EnvironmentName }

    if ($selectedEnvironment -eq $null) {
        throw "[GetOctopusTenantForEnvironment] Failed finding suppled environment"
    }

    $selectedTenants = $octopusTenants | where {
        $_.ProjectEnvironments -ne $null -and
        $_.ProjectEnvironments.PSObject.Properties -ne $null -and
        $_.ProjectEnvironments.PSObject.Properties.Value.Contains($selectedEnvironment.Id)
    }
    
    if ($selectedTenants -ne $null) {
        $result = new-object "System.Collections.Generic.List[string]"
        $selectedTenants | foreach { $result.Add($_.Name) }
        return $result
    }

    return ""
}

function GetOctopusMembers
{
    [CmdletBinding()]
    Param
    (
        # Octopus URL
        [Parameter(Mandatory=$true)]
        [string]$URL,

        # Octopus API Key
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        # Octopus member type
        [Parameter(Mandatory=$true)]
        [string]$MemberType
    )
    
    # turn off ui progress indicators
    $currentProgressPreference = $ProgressPreference
    $ProgressPreference = 'silentlyContinue'

    $header = @{ "X-Octopus-ApiKey" = $APIKey }

    $webResult = (Invoke-WebRequest $URL/$MemberType/all -Method Get -Headers $header -UseBasicParsing).content | ConvertFrom-Json

    #reset progress pref
    $ProgressPreference = $currentProgressPreference

    return $webResult
}