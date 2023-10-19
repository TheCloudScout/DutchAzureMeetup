[CmdletBinding()]
param (

    [Parameter (Mandatory = $true)]
    [string] $message

)

$appId          = "5313871f-8a8f-45a7-be85-bf9bc395e141"                            # the tenant ID in which the Data Collection Endpoint resides
$appSecret      = ""                                                                # the tenant ID in which the Data Collection Endpoint resides
$tenantId       = "8c884f39-eb63-49ee-83e4-7ebe060b8e5a"                            # the secret created for the above app - never store your secrets in the source code
$dcrImmutableId = "dcr-cb6c175e376548059f7d9e6b55230ee4"                            # immutable ID of the Data Collection Rule
$dceUri         = "https://bitdefend-o877.westeurope-1.ingest.monitor.azure.com"    # the URI of the Data Collection Endpoint
$tableName      = "DutchAzureMeetup_CL"                                             # the name of the custom log table

$payload = @{
    # Define the structure of log entry, as it will be sent
    Time        = Get-Date ([datetime]::UtcNow) -Format O
    Computer    = $env:computername
    Application = "Dutch Azure Meetup"
    RawData     = $message
}

# Obtain a bearer token used to authenticate against the data collection endpoint
$scope          = "https%3a%2f%2fmonitor.azure.com%2f%2f.default"
$body           = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials";
$headers        = @{"Content-Type" = "application/x-www-form-urlencoded" };
$uri            = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$bearerToken    = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token

# Sending the data to Log Analytics via the DCR!
$body           = ConvertTo-Json @($payload)
$headers        = @{"Authorization" = "Bearer $bearerToken"; "Content-Type" = "application/json" };
$uri            = "$dceUri/dataCollectionRules/$dcrImmutableId/streams/Custom-$tableName"+"?api-version=2021-11-01-preview";
$uploadResponse = Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers;

# Let's see how the response looks like
Write-Host $uploadResponse
Write-Host "Log line send to Data Collection Endpoint..." -ForegroundColor Yellow 
