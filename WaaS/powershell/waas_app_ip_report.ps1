# waas_app_ip_report.ps1
#
# Launch from same subdirectory as the send-waas-api.ps1 script
# Must launch waas-login.ps1 to populate $waas_token env variable:
# . ./waas-login.ps1 

param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $apikey,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $apikeyfile
)

if ( ! $apikeyfile -and ! $apikey -and ! $waastoken ) {
    Write-Host "No auth method specified." -ForegroundColor Yellow
    Write-Host 'Choose apikeyfile, apikey, or set $waastoken environment variable' -ForegroundColor Yellow
    Write-Host
    exit
}

if ( $apikeyfile -and ! $apikey -and !(Test-Path $apikeyfile) ) {
    Write-Host "Could not locate api key file: $apikeyfile" -BackgroundColor Yellow
    Write-Host
    exit
}

if ( $apikeyfile -and (Test-Path $apikeyfile ) ) {
    $apikey = (Get-Content $apikeyfile)
}

$barracuda_range = '64.113.48.0/20'
$aws_range = '34.228.125.58/32'

$azure_map = @{
    'California' = 'US West';
    'Washington' = 'US West 2';
    'Arizona'= 'US West 3';
    'Iowa' = 'North Central US';
    'Texas' = 'South Central US';
    'Virginia' = 'US East';
    
}
$r = .\send-waas-api.ps1 -api 'applications/' -method GET
if ( $r.results.id -eq '' ) {
    Write-Host "No app ID's were found."
    exit
}

$my_ip_list = @{}

## Collect IP ranges for each app and add to list
foreach ( $appId in $r.results.id ) {
    Write-Host "Reading IP addresses for app: " -NoNewline
    Write-Host $appId -ForegroundColor Blue
    
    $app_ip_addrs = .\send-waas-api.ps1 -api "applications/$appId/ips_to_allow/" -method GET
    Write-Host $app_ip_addrs.ranges -ForegroundColor Yellow
    foreach ( $range in $app_ip_addrs.ranges) {
        if ( $range -ne $barracuda_range -and $range -ne $aws_range ) {
            $my_ip_list[$range] += 1
        }
    }
}

## Lookup Azure region for each IP range
$my_ip_regions = @{}

foreach ($cidr in $my_ip_list.GetEnumerator()) {
    $ip = $cidr.Name.Substring(0,$cidr.Name.Length-3)
    $ipinfo = curl ipinfo.io/$ip
    $ipdata = $ipinfo | ConvertFrom-Json
    $my_ip_regions[$cidr] = $ipdata.region + ', ' + $ipdata.country
}

$prev_color = $Host.UI.RawUI.ForegroundColor
$Host.UI.RawUI.ForegroundColor = 'Green'
Write-Host "`n`n------====== Waas App IP Report ======------"
Write-Host "  IP ranges and corresponding app counts:`n"
Write-Host "    IP Range          Region            Count"
Write-Host "------------------------------------------------"
#$my_ip_list | Format-Table -HideTableHeaders
foreach ( $cidr in $my_ip_list.GetEnumerator() ) {
    Write-Host("{0,-20} {1,-20} {2,-15}" -f $cidr.Name, $my_ip_regions[$cidr], $cidr.Value)
}
Write-Host "`n"
$Host.UI.RawUI.ForegroundColor = $prev_color
