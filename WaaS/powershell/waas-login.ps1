# waas-login.ps1
#
# Logs in using the email address specified in loginBody and password in creds.ignore file
#
# Use the dot-include method to export $waastoken, e.g.
#  . ./waas-login.ps1
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $accountId,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $email = "mercutio.viz@gmail.com"
)

$waashost='https://api.waas.barracudanetworks.com'
$loginurl='v2/waasapi/api_login/'
$contentType = 'application/x-www-form-urlencoded'

$plainTextPassword = (Get-Content ".\creds.ignore" | out-string).Trim()

$loginBody = @{
 password = "$plainTextPassword"
 email = $email
}

if ( $accountId -ne '' ) {
    $loginBody.account_id = "$accountId"
}

$authResponse = Invoke-WebRequest -Uri $waashost/$loginurl -Method Post -Body $loginBody -ContentType $contentType
$waastoken = ($authResponse.Content | ConvertFrom-Json).key
$waastoken
