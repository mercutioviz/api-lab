# add-trusted-hosts.ps1
#
# Uses send-waas-api.ps1 and a CSV file to bulk add trusted hosts
#
#  CSV file must be in the form of:
#    host name, IP address, netmask, comment
#
# Host name and IP address are mandatory.
# If netmask is empty it defaults to 255.255.255.255
#
# apikeyfile is required for this operation
#

param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $apiKeyFile,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $appName,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $trustedHostsFile
)

if ( -not (Test-Path $TrustedHostsFile) ) {
    Write-Host "File not found: " $TrustedHostsFile
    exit
}

$trustedhosts = ( Get-Content $TrustedHostsFile | ConvertFrom-Csv )

for ( $i=0; $i -lt $trustedhosts.Length; $i++ ) {
    if ( ! $trustedhosts[$i].hostname -and ! $trustedhosts[$i].ip ) { continue }
    Write-Host "Adding trusted host: " $trustedhosts[$i].hostname $trustedhosts[$i].ip
    $name = $trustedhosts[$i].hostname
    $ip = $trustedhosts[$i].ip
    if ( ! $trustedhosts[$i].netmask ) { $netmask = '255.255.255.255' }
    if ( ! $trustedhosts[$i].comment ) { $note = '' }

    #Write-Host "Data: " $name $ip $netmask $note
    $data = @{ 'hostname' = "$name"; 'ip' = "$ip"; 'netmask' = "$netmask"; 'note' = "$note" }
    $jsonBody = $data | ConvertTo-Json
    try {
        $r = ./send-waas-api.ps1 -apiversion 4 -apikeyfile $apikeyfile -Method 'POST' -api "applications/$appName/trusted_hosts/hosts/" -Body $jsonBody
    } catch {
        Write-Host "  StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "  StatusDescription:" $_.Exception.Response.StatusDescription
        exit
        $r
    }
}

