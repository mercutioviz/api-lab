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
    $wafhost
)

if ( $wafhost -eq '' ) {
    $wafhost = '51.143.38.93:8000'
}

$loginurl='http://' + $wafhost + '/restapi/v3.1/login'
$contentType = 'application/json'

$plainTextPassword = (Get-Content ".\creds.ignore" | out-string).Trim()
$username='wafapiuser'
$loginBody = @{
    password = "$plainTextPassword"
    username = "$username"
}
$loginBodyJSON = $loginBody | ConvertTo-Json

$authResponse = Invoke-WebRequest -Uri $loginurl -Method Post -Body $loginBodyJSON -ContentType $contentType

$waftoken = ($authResponse.Content | ConvertFrom-Json).token + ':'
$waftoken
