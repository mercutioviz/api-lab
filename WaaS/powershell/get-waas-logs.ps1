# get-waas-applications.ps1
#
# Retrieves dump of WaaS logs. Specify format; defaults to psobject
#  Specify noDownload option to receive JSON or PSObject and to use itemsPerPage
#  By default script will attempt to download CSV data (itemsPerPage has no effect)
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
    [ValidateSet('waf','access','event','all')]
    [string]
    $logType,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $jsonFilters,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [Int32]
    $dateFrom,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [Int32]
    $dateTo,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [Int16]
    $appId,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [Int16]
    $pageNumber = 1,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [Int16]
    $itemsPerPage = 100,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [switch]
    $noDownload,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $apikey,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $apikeyfile,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('r_1h','r_3h','r_24h','r_7d','r_14d','r_30d')]
    [string]
    $quickRange
)
$waashost='https://api.waas.barracudanetworks.com'
$apiurl='v2/waasapi/applications/' + $appId + '/' + $logType + '/logs'
$contentType = 'application/json'
$method = 'GET'

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

if ( $noDownload -and $logType -eq 'all' ) {
    Write-Host "Cannot download log type 'all' - please choose 'waf' or 'access' to download" -ForegroundColor Yellow
    exit
}

if ( $quickRange ) {
    if ( $noDownload ) {
        $qstring = '?id=' + $appId + '&quickRange=' + $quickRange + '&page=' + $pageNumber + '&itemsPerPage=' + $itemsPerPage
    } else {
        $qstring = '?download=true&quickRange=' + $quickRange
    }
} else {
    if ( $noDownload ) {
        $qstring = '?id=' + $appId + '&page=' + $pageNumber + '&itemsPerPage=' + $itemsPerPage
        if ( $dateFrom -and $dateTo ) {
            $qstring = $qstring + '&from=' + $dateFrom + '&to=' + $dateTo
        }
    } else {
        $qstring = '?download=true'
        if ( $dateFrom -and $dateTo ) {
            $qstring = $qstring + '&from=' + $dateFrom + '&to=' + $dateTo
        }
    }
}

if ( $jsonFilters ) {
    $jsonFiltersEncoded = [System.Web.HTTPUtility]::UrlEncode($jsonFilters)
    $qstring = $qstring + '&jsonFilters=' + $jsonFiltersEncoded
}

if ( $OutputType -eq 'PSObject' ) {
    Write-Host "Invoke RestMethod"
#    $r = Invoke-RestMethod -Uri $waashost/$apiurl/$qstring -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
    $r = Invoke-RestMethod -Uri $waashost/$apiurl/$qstring -Method $method -ContentType $contentType -Headers $headers
} else {
    Write-Host "Invoke WebRequest"
#    $r = Invoke-WebRequest -Uri $waashost/$apiurl/$qstring -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
    $r = Invoke-WebRequest -Uri $waashost/$apiurl/$qstring -Method $method -ContentType $contentType -Headers $headers
}

$r
