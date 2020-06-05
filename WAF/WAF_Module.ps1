#
# WAF_Module.ps1
#
Import-Module Barracuda_WAF_Module

$dev_name = "51.143.38.93"
$dev_port = "8000"
$username = "wafapiuser"
$password = "cloud2020"
$auth = Login-BarracudaWAF -device $dev_name -device_port $dev_port -username $username -password $password 

Write-Host "Auth info "
Write-Host $auth

$response = Get-BarracudaWAFService -device $dev_name -device_port $dev_port -token $auth

foreach ( $item in $response.psobject.Properties.Name ) {
    Write-Host ("Name: {0}" -f $item)
    Write-Host ("Status: {0}  Port: {1}" -f $response.$item.status, $response.$item.port)
}

Write-Host "Rule Groups for each service..."
foreach ( $item in $response.psobject.Properties.Name ) {
    Write-Host ("Service Name: {0}" -f $item) -ForegroundColor Magenta
    foreach ( $rulegroup in $response.$item.'Rule Group'.data.psobject.Properties.Name ) {
        Write-Host ("    {0}" -f $rulegroup ) -ForegroundColor Green
    }
}

Logout-BarracudaWAF -device $dev_name -device_port $dev_port -authentication $auth

