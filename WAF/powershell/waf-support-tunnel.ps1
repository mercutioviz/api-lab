# waf-support-tunnel.ps1
#
# Accepts WAF hostname/IP:port and opens support tunnel
#
# NOTE: do a "dot include" to have $waftoken populated in the PowerShell session
# Example:
# ". ./waf-support-tunnel.ps1" at the CLI
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [string]
    $wafhost,
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [switch]
    $https = $false
)

if ( $https -eq $true ) {
    if ( $wafhost -eq '' ) {
        $wafhost = '51.143.38.93:8443'
    }
    $tunnelurl='https://' + $wafhost + "/cgi-mod/support-tunnel.cgi"
} else {
    if ( $wafhost -eq '' ) {
        $wafhost = '51.143.38.93:8000'
    }    
    $tunnelurl='http://' + $wafhost + "/cgi-mod/support-tunnel.cgi"
}

$contentType = 'application/json'

$r = Invoke-WebRequest -Uri $tunnelurl -Method Get -ContentType $contentType -SkipCertificateCheck

