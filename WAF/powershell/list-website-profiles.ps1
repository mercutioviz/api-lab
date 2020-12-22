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

#$r | ConvertFrom-Json

$d = $r.Content | ConvertFrom-Json
foreach ( $website in $d.data | get-member -type properties | ForEach-Object name ) {
    write-host "Site: $website" -ForegroundColor Cyan
    $url = $url + "/$website/website-profile"
    $r = Invoke-WebRequest -uri $url -Method Get -Headers $headers -ContentType $contentType
    $siteprofile = $r.content | ConvertFrom-Json
    $url = $url + "/$website/url-profiles"
    $r = Invoke-WebRequest -uri $url -Method Get -Headers $headers -ContentType $contentType

}

