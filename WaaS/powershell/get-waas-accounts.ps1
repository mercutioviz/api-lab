# get-waas-accounts.ps1
#
# Retrieves dump of WaaS accounts. Specify format; defaults to psobject
#
# NOTE: do a "dot include" to have $r object exported as a variable
# Example:
# ". ./get-waas-accounts.ps1" at the CLI
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('PSObject','JSON')]
    [string]
    $OutputType = 'PSObject'
)
$waashost='https://api.waas.barracudanetworks.com'
$apiurl='v2/waasapi/accounts/'
$contentType = 'application/json'
$method = 'GET'

$OutputType

if ( $OutputType -eq 'PSObject' ) {
    Write-Host "Invoke RestMethod"
    $r = Invoke-RestMethod -Uri $waashost/$apiurl -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
} else {
    Write-Host "Invoke WebRequest"
    $r = Invoke-WebRequest -Uri $waashost/$apiurl -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
}

$r
