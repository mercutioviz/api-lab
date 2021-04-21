# waf-login.ps1
#
# Accepts username and password and WAF hostname/IP:port and prints out the token
#
# NOTE: do a "dot include" to have $waftoken populated in the PowerShell session
# Example:
# ". ./waf-login.ps1" at the CLI
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $wafhost,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $username,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $credsfile = '.\creds.ignore',
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [switch]
    $https = $false
)

$apiVer = 'v3.1'

if ( $https -eq $true ) {
    if ( $wafhost -eq '' ) {
        $wafhost = '51.143.38.93:8443'
    }
    $loginurl='https://' + $wafhost + "/restapi/$apiVer/login"
} else {
    if ( $wafhost -eq '' ) {
        $wafhost = '51.143.38.93:8000'
    }    
    $loginurl='http://' + $wafhost + "/restapi/$apiVer/login"
}

$contentType = 'application/json'

$plainTextPassword = (Get-Content $credsfile | out-string).Trim()
if ( $username -eq '' ) {
    $username='wafapiuser'
}

$loginBody = @{
    password = "$plainTextPassword"
    username = "$username"
}
$loginBodyJSON = $loginBody | ConvertTo-Json

$authResponse = Invoke-WebRequest -Uri $loginurl -Method Post -Body $loginBodyJSON -ContentType $contentType -SkipCertificateCheck

$waftoken = ($authResponse.Content | ConvertFrom-Json).token + ':'
$waftoken
