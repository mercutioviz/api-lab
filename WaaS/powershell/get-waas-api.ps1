# get-waas-api.ps1
#
# Generic API GET call; supply api info. Specify format; defaults to psobject
#  Ex: ./get-waas-api.ps1 -api "6948/servers"
# NOTE: do a "dot include" to have $r object exported as a variable
# Example:
# ". ./get-waas-api.ps1" at the CLI
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
    $api
)
$waashost='https://api.waas.barracudanetworks.com'
$baseUrl='v2/waasapi/applications/'
$contentType = 'application/json'
$method = 'GET'

if ( $OutputType -eq 'PSObject' ) {
    Write-Host "Invoke RestMethod"
    $r = Invoke-RestMethod -Uri $waashost/$baseUrl/$api -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
    $r
} else {
    Write-Host "Invoke WebRequest"
    $r = Invoke-WebRequest -Uri $waashost/$baseUrl/$api -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
    $r.Content
}

