# get-waas-api.ps1
#
# Generic API GET call; supply api info. Specify format; defaults to psobject
#  Ex: ./send-waas-api.ps1 -api "6948/servers"
# NOTE: do a "dot include" to have $r object exported as a variable
# Example:
# ". ./send-waas-api.ps1 -api 6948/servers" at the CLI
#   Allows for things like:
#  $r.Content | Select-Object name,id
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('PSObject','JSON')]
    [string]
    $OutputType = 'PSObject',
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
    [string]
    $Method = 'GET',
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $Body,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $api
)
$waasHost='https://api.waas.barracudanetworks.com'
$baseUrl='v2/waasapi/applications/'
$contentType = 'application/json'

if ( $OutputType -eq 'PSObject' ) {
    Write-Host "Invoke RestMethod"
    if ( $Method -in ('GET', 'DELETE') ) {
        $r = Invoke-RestMethod -Uri $waasHost/$baseUrl/$api -Method $Method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
    } else {
        $r = Invoke-RestMethod -Uri $waasHost/$baseUrl/$api -Method $Method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken} -Body $Body
    }
    $r
} else {
    Write-Host "Invoke WebRequest"
    if ( $Method -in ('GET', 'DELETE') ) {
        $r = Invoke-WebRequest -Uri $waasHost/$baseUrl/$api -Method $Method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
    } else {
        $r = Invoke-WebRequest -Uri $waasHost/$baseUrl/$api -Method $Method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken } -Body $Body
    }
    $r.Content
}

