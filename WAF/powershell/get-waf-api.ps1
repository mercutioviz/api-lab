# get-waf-api.ps1
#
# Accepts require API string and optional WAF hostname/IP:port 
#  and process the GET request
#
# Ex:
#  ./get-waf-api.ps1 -api 'services/'
#  ./get-waf-api.ps1 -api 'cluster/'
#  ./get-waf-api.ps1 -api 'stats/http-stats'
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $wafhost,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $api
)

if ( $waftoken -eq '' ) {
    Write-Host "No WAF token available. Generate a token and set the \$waftoken variable"
    exit
}

if ( $wafhost -eq '' ) {
    $wafhost = '51.143.38.93:8000'
}

$url='http://' + $wafhost + '/restapi/v3.1/' + $api
$contentType = 'application/json'
$creds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($waftoken))
$headers = @{
    'Authorization' = 'Basic ' + $creds
    'Accept' = 'application/json'
}

$r = Invoke-WebRequest -uri $url -Method Get -Headers $headers -ContentType $contentType

$r | ConvertFrom-Json