# create-waas-app.ps1
#
# Creates a new WaaS app using the JSON in the specied path
#
# Use the dot-include method to export $r object, e.g.
#  . ./create-waas-app.ps1
#
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $Path
)

if ( -not (Test-Path $Path) ) {
    Write-Host "File not found: " $Path
    exit
}

$waashost='https://api.waas.barracudanetworks.com'
$apiurl='v2/waasapi/applications/'
$contentType = 'application/json'

$appConfig = (Get-Content $Path )
Write-Host "App Config:" $appConfig

$r = Invoke-WebRequest -Uri $waashost/$apiurl -Method Post -Body $appConfig -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }

$r.Content 
