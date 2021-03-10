# get-waas-endpoint.ps1
#
# Dump endpoint config object; supply app id, endpoint id. Specify format; defaults to JSON
#  Ex: ./get-waas-endpoint.ps1 -endpointId "12345" -appId "6948"
# NOTE: do a "dot include" to have $r object exported as a variable
# Example:
# '. ./get-waas-endpoint.ps1 -endpointId "12345" -appId "6948" ' at the CLI
#   Allows for things like:
#  $r.Content | Select-Object name,id
#
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [ValidateSet('PSObject','JSON')]
    [string]
    $OutputType = 'PSObject',
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $appId,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $endpointId
)

### Functions ###
# Output from reading endpoint data is not in the same format needed for PATCHing or POSTing
# This function takes the output of a given endpoint API GET and reformats a JSON object
#  suitable for PATCHing or POSTing an existing or new endpoint, respectively
# NOTE: assumes that if a cert is present that it will replace whatever is already there
function build_endpoint_configuration {
    param($configData)

    $endpointBootstrap = '{
        "enable_pfs": false,
        "hostnames": [
          "8.8.8.8"
        ],
        "enableHttp2": false,
        "useOtherServiceIp": true,
        "enableVdi": false,
        "enable_tls_1_1": true,
        "replaceCertificate": false,
        "keepaliveRequests": 64,
        "cipher_suite_name": "all",
        "servicePort": "80",
        "custom_ciphers": [
          "ECDHE-RSA-AES128-SHA256",
          "AES256-GCM-SHA384"
        ],
        "session_timeout": 60,
        "automaticCertificate": true,
        "enable_tls_1": false,
        "ntlmIgnoreExtraData": false,
        "serviceType": "HTTP",
        "enableWebsocket": false,
        "redirectHTTP": "redirect",
        "enable_ssl_3": false,
        "enable_tls_1_2": true
      }' | ConvertFrom-Json 

    $newEndpoint = $endpointBootstrap
    # These are the easy ones that translate directly from source to destination data structure
    $basicSettings = (
        'custom_ciphers',
        'enable_tls_1',
        'enable_ssl_3',
        'enable_tls_1_2',
        'enable_tls_1_1',
        'cipher_suite_name',
        'enable_pfs',
        'custom_ciphers',
        'session_timeout'
    )

    # Translate over the basic settings first
    foreach ( $item in $basicSettings ) {
        $newEndpoint.$item = $configData.$item
    }

    # Certs aren't really applicable in a copy scenario because you can't download a private key
    # Just set automatic to "false" if this is an HTTP service
    # Also check if redirect is set or not
    if ( $configData.dps_service.service_type -eq "HTTP" ) {
        $newEndpoint.automaticCertificate = $false
        $newEndpoint.redirectHTTP = "noRedirect"
    } elseif ( $configData.dps_service.service_type -eq "Redirect Service" ) {
        $newEndpoint.automaticCertificate = $false
    }

    # The following settings need to be translated because...
    #  The GET API uses underscores
    #  The PATCH and POST APIs use camelCase
    $newEndpoint.enableHttp2 = $configData.advanced_configuration.enable_http2
    $newEndpoint.enableWebsocket = $configData.advanced_configuration.enable_websocket
    $newEndpoint.enableVdi = $configData.advanced_configuration.enable_vdi
    $newEndpoint.ntlmIgnoreExtraData = $configData.advanced_configuration.ntlm_ignore_extra_data
    $newEndpoint.keepaliveRequests = $configData.advanced_configuration.keepalive_requests

    # Service type and port
    $newEndpoint.servicePort = $configData.dps_service.port.ToString()
    $newEndpoint.serviceType = $configData.dps_service.service_type
    $newEndpoint.hostnames   = $configData.dps_service.domains

    return $newEndpoint
}

## Script ##
$waashost='https://api.waas.barracudanetworks.com'
$baseUrl='v2/waasapi/applications/'
$fullUrl="$baseUrl/$appId/endpoints/$endpointId"
$contentType = 'application/json'
$method = 'GET'

$r = Invoke-RestMethod -Uri $waashost/$fullUrl -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
$endpointConfig = build_endpoint_configuration($r)

if ( $OutputType -eq 'PSObject' ) {
    Write-Host "Formatted Object" -ForegroundColor Cyan 
    $endpointConfig | Format-List | Out-String | Write-Host -ForegroundColor Cyan
} else {
    Write-Host "Formatted JSON" -ForegroundColor Green
    $endpointConfig = $endpointConfig | ConvertTo-Json -Depth 20
    Write-Host $endpointConfig -ForegroundColor Green
}

