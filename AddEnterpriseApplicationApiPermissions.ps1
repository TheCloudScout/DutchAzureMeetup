# Your tenant id (in Azure Portal, under Azure Active Directory -> Overview )
$TenantID = ""

# Name of the manage identity (same as the Logic App name)
$DisplayNameOfMSI = @(
    "logic-defender-nonprd-weeu-dailyreports-01",
    "logic-defender-prd-weeu-dailyreports-01"
)

$GraphPermissions = @(
    "SecurityIncident.Read.All",
    "Device.Read.All",
    "Device.ReadWrite.All",
    "Directory.Read.All",
    "Directory.ReadWrite.All"
)

$DefenderPermissions = @(
    "AdvancedQuery.Read.All",
    "Alert.Read.All",
    "Alert.ReadWrite.All",
    "Machine.Read.All"
)

$ThreatIntelPermissions = @(
    "AdvancedHunting.Read.All",
    "Incident.Read.All",
    "Incident.ReadWrite.All"
)

# Microsoft Graph App ID (DON'T CHANGE)
$GraphAppId = "00000003-0000-0000-c000-000000000000"
$DefenderAppId = "fc780465-2017-40d4-a0c5-307022471b92"
$Threathprotectionid = "8ee8fdad-f234-4243-8f3b-15c294843740"

# Install the module (You need admin on the machine) also only works with native PowerShell not PowerShell Core!
# Install-Module AzureAD 

# Connect to Tenant
Connect-AzureAD -TenantId $TenantID

# Start-Sleep 10

$GraphServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$GraphAppId'"
$DefenderServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$DefenderAppId'"
$ThreatIntelServicePrincipal = Get-AzureADServicePrincipal -Filter "appId eq '$Threathprotectionid'"

foreach ($MSI in $DisplayNameOfMSI) {

    Write-Host "Gathering identity for $($MSI)..." -ForegroundColor Green

    $identity = (Get-AzureADServicePrincipal -Filter "displayName eq '$MSI'")

    Write-Host "Microsoft Graph" -ForegroundColor Yellow
    foreach ($Permission in $GraphPermissions) {
        Write-Host "Assigning $($Permission) to $($MSI)..." -ForegroundColor DarkGray
        $AppRole = $GraphServicePrincipal.AppRoles | Where-Object { $_.Value -eq $Permission -and $_.AllowedMemberTypes -contains "Application" }
        if ($null -ne $AppRole) {
            New-AzureAdServiceAppRoleAssignment -ObjectId $identity.ObjectId -PrincipalId $identity.ObjectId -ResourceId $GraphServicePrincipal.ObjectId -Id $AppRole.Id | out-null
            Write-Host "Permissions assigned"
        }
        else {
            Write-Host "Permission $($Permission) was not found for $($GraphServicePrincipal.DisplayName)" -ForegroundColor Red
        }
    }

    Write-Host "WindowsDefenderATP" -ForegroundColor Yellow
    foreach ($Permission in $DefenderPermissions) {
        Write-Host "Assigning $($Permission) to $($MSI)..." -ForegroundColor DarkGray
        $AppRole = $DefenderServicePrincipal.AppRoles | Where-Object { $_.Value -eq $Permission -and $_.AllowedMemberTypes -contains "Application" }
        if ($null -ne $AppRole) {
            New-AzureAdServiceAppRoleAssignment -ObjectId $identity.ObjectId -PrincipalId $identity.ObjectId -ResourceId $DefenderServicePrincipal.ObjectId -Id $AppRole.Id | out-null
            Write-Host "Permissions assigned"
        }
        else {
            Write-Host "Permission $($Permission) was not found for $($DefenderServicePrincipal.DisplayName)" -ForegroundColor Red
        }
    }

    Write-Host "Microsoft Threat Intel" -ForegroundColor Yellow
    foreach ($Permission in $ThreatIntelPermissions) {
        Write-Host "Assigning $($Permission) to $($MSI)..." -ForegroundColor DarkGray
        $AppRole = $ThreatIntelServicePrincipal.AppRoles | Where-Object { $_.Value -eq $Permission -and $_.AllowedMemberTypes -contains "Application" }
        if ($null -ne $AppRole) {
            New-AzureAdServiceAppRoleAssignment -ObjectId $identity.ObjectId -PrincipalId $identity.ObjectId -ResourceId $ThreatIntelServicePrincipal.ObjectId -Id $AppRole.Id | out-null
            Write-Host "Permissions assigned"
        }
        else {
            Write-Host "Permission $($Permission) was not found for $($ThreatIntelServicePrincipal.DisplayName)" -ForegroundColor Red
        }
    }

}
