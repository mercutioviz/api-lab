# get-waas-config.ps1
#
# Retrieves dump of WaaS applications. Specify format; defaults to psobject
#
# NOTE: do a "dot include" to have $r object exported as a variable
# Example:
# ". ./get-waas-config.ps1" at the CLI
#   Allows for things like:
#  $r.Content | Select-Object name,id
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('PSObject','JSON')]
    [string]
    $OutputType = 'PSObject',
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $appId
)
$waashost='https://api.waas.barracudanetworks.com'
$apiurl='v2/waasapi/applications/'
$contentType = 'application/json'
$method = 'GET'

if ( $OutputType -eq 'PSObject' ) {
    Write-Host "Invoke RestMethod"
    $r = Invoke-RestMethod -Uri $waashost/$apiurl/$appId/export -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
    $r
} else {
    Write-Host "Invoke WebRequest"
    $r = Invoke-WebRequest -Uri $waashost/$apiurl/$appId/export -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
    $r.Content
}

