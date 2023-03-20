# waas_app_ip_report.ps1
#
# Launch from same subdirectory as the send-waas-api.ps1 script
# Must launch waas-login.ps1 to populate $waas_token env variable:
# . ./waas-login.ps1 

$r = .\send-waas-api.ps1 -api 'applications/' -method GET
if ( $r.results.id -eq '' ) {
    Write-Host "No app ID's were found."
    exit
}

$my_ip_list = @{}

foreach ( $appId in $r.results.id ) {
    Write-Host "Reading IP addresses for app: " -NoNewline
    Write-Host $appId -ForegroundColor Blue
    
    $app_ip_addrs = .\send-waas-api.ps1 -api "applications/$appId/ips_to_allow/" -method GET
    Write-Host $app_ip_addrs.ranges -ForegroundColor Yellow
    foreach ( $range in $app_ip_addrs.ranges) {
        $my_ip_list[$range] += 1
    }
}

$prev_color = $Host.UI.RawUI.ForegroundColor
$Host.UI.RawUI.ForegroundColor = 'Green'
Write-Host "`n`n------====== Waas App IP Report ======------"
Write-Host "  IP ranges and corresponding app counts:`n"
Write-Host "    IP Range                 Count"
Write-Host "-------------------------------------------"
$my_ip_list | Format-Table -HideTableHeaders
Write-Host "`n"
$Host.UI.RawUI.ForegroundColor = $prev_color
