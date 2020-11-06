# list-website-profiles.ps1
#
# Lists each website and the corresponding URL and param profiles
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $wafhost
)

if ( $waftoken -eq '' ) {
    Write-Host "No WAF token available. Generate a token and set the \$waftoken variable"
    exit
}

if ( $wafhost -eq '' ) {
    $wafhost = '51.143.38.93:8000'
}

$url='http://' + $wafhost + '/restapi/v3.1/services'
$contentType = 'application/json'
$creds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($waftoken))
$headers = @{
    'Authorization' = 'Basic ' + $creds
    'Accept' = 'application/json'
}

$r = Invoke-WebRequest -uri $url -Method Get -Headers $headers -ContentType $contentType

$r | ConvertFrom-Json