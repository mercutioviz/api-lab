# post-waf-api.ps1
#
# Accepts required API string, source JSON file, and optional WAF hostname/IP:port 
#  and process the POST request
#
# Ex:
#  ./post-waf-api.ps1 -api 'services/HTTPS/content-rules' -jsonSourceFile 'C:\temp\mydat.json'
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $wafhost,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $jsonSourceFile,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $api,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [switch]
    $https = $false
)

$apiVer = 'v3.1'

if ( $waftoken -eq '' ) {
    Write-Host "No WAF token available. Generate a token and set the \$waftoken variable"
    exit
}

if ( $https -eq $true ) {
    if ( $wafhost -eq '' ) {
        $wafhost = '51.143.38.93:8443'
    }
    $url='https://' + $wafhost + "/restapi/$apiVer/" + $api
} else {
    if ( $wafhost -eq '' ) {
        $wafhost = '51.143.38.93:8000'
    }
    $url='http://' + $wafhost + "/restapi/$apiVer/" + $api
}

$bodyJSON = (Get-Content $jsonSourceFile | out-string).Trim()
$contentType = 'application/json'
$creds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($waftoken))
$headers = @{
    'Authorization' = 'Basic ' + $creds
    'Accept' = 'application/json'
}

$r = Invoke-WebRequest -uri $url -Method Post -Body $bodyJSON -Headers $headers -ContentType $contentType -SkipCertificateCheck

$r | ConvertFrom-Json
