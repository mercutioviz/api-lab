# get-waas-api.ps1
#
# Generic API GET call; supply api info. Specify format; defaults to psobject
#  Ex: ./send-waas-api.ps1 -api "applications/6948/servers"
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
    [ValidateSet('2','4')]
    [string]
    $apiVersion = '2',
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
    [string]
    $Method = 'GET',
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $Body,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $apikey,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $apikeyfile,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $api
)
$waasHost='https://api.waas.barracudanetworks.com'
$baseUrl='v' + $apiVersion + '/waasapi'
$contentType = 'application/json'

# Determine which type of auth to use
# apikeyfile first, apikey second, waastoken last

if ( ! $apikeyfile -and ! $apikey -and ! $waastoken ) {
    Write-Host "No auth method specified." -ForegroundColor Yellow
    Write-Host 'Choose apikeyfile, apikey, or set $waastoken environment variable' -ForegroundColor Yellow
    Write-Host
    exit
}

if ( $apikeyfile -and ! $apikey -and !(Test-Path $apikeyfile) ) {
    Write-Host "Could not locate api key file: $apikeyfile" -BackgroundColor Yellow
    Write-Host
    exit
}

if ( $apikeyfile -and (Test-Path $apikeyfile ) ) {
    $apikey = (Get-Content $apikeyfile)
}

# Set headers
if ( $apikey ) {
    $headers = @{ 'Accept' = 'application/json'; 'Authorization' = "Bearer $apikey"}
} else {
    $headers = @{ 'Accept' = 'application/json'; 'auth-api' = $waastoken }
}

if ( $OutputType -eq 'PSObject' ) {
    Write-Host "Invoke RestMethod"
    if ( $Method -in ('GET', 'DELETE') -or $Body -eq '' ) {
        $r = Invoke-RestMethod -Uri $waasHost/$baseUrl/$api -Method $Method -ContentType $contentType -Headers $headers
    } else {
        $r = Invoke-RestMethod -Uri $waasHost/$baseUrl/$api -Method $Method -ContentType $contentType -Headers $headers -Body $Body
    }
    $r
} else {
    Write-Host "Invoke WebRequest"
    if ( $Method -in ('GET', 'DELETE') -or $Body -eq '' ) {
        $r = Invoke-WebRequest -Uri $waasHost/$baseUrl/$api -Method $Method -ContentType $contentType -Headers $headers
    } else {
        $r = Invoke-WebRequest -Uri $waasHost/$baseUrl/$api -Method $Method -ContentType $contentType -Headers $headers -Body $Body
    }
    $r.Content
}

