$dev_name = "51.143.38.93"
$dev_port = "8000"
$username = "wafapiuser"
$password = "cloud2020"
$auth = Login-BarracudaWAF -device $dev_name -device_port $dev_port -username $username -password $password 

$response = Get-BarracudaWAFService -device $dev_name -device_port $dev_port -token $auth

foreach ( $item in $response.psobject.Properties.Name ) {
    Write-Host ("Name: {0}" -f $item)
    Write-Host ("Status: {0}  Port: {1}" -f $response.$item.status, $response.$item.port)
}
