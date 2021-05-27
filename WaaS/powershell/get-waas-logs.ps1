# get-waas-applications.ps1
#
# Retrieves dump of WaaS logs. Specify format; defaults to psobject
#
# NOTE: do a "dot include" to have $r object exported as a variable
# Example:
# ". ./get-waas-logs.ps1 -appId 1234 -logType event -quickRange r_7d" at the CLI
#   Allows for things like:
#  $r.Content | Select-Object name,id
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('PSObject','JSON')]
    [string]
    $OutputType = 'PSObject',
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateSet('waf','access','event')]
    [string]
    $logType,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [Int16]
    $appId,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('r_1h','r_3h','r_24h','r_7d','r_14d','r_30d')]
    [string]
    $quickRange
)
$waashost='https://api.waas.barracudanetworks.com'
$apiurl='v2/waasapi/applications/' + $appId + '/' + $logType + '/logs'
$contentType = 'application/json'
$method = 'GET'

if ( $quickRange ) {
    $qstring = '?download=true'
} else {
    $qstring = '?download=true&quickRange=' + $quickRange
}

if ( $OutputType -eq 'PSObject' ) {
    Write-Host "Invoke RestMethod"
    $r = Invoke-RestMethod -Uri $waashost/$apiurl/$qstring -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
} else {
    Write-Host "Invoke WebRequest"
    $r = Invoke-WebRequest -Uri $waashost/$apiurl/$qstring -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
}

$r
