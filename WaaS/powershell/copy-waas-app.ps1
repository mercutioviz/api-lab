# copy-waas-app.ps1
#
# Accepts App ID to copy, new app name, and new hostname to listen on 
#  Creates a new WaaS app with all the same settings (including BE server)
#
# NOTE: do a "dot include" to have $r object exported as a variable
# Example:
# ". ./copy-waas-app.ps1" at the CLI
#   Allows for things like:
#  $r.Content | Select-Object name,id
#
param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $hostname,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $appName,    
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $appId
)

# Number of seconds to sleep/pause after a major update
$sleepTimer = 5

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

    # Hostname was supplied at runtime by the user on CLI
    $newEndpoint.hostnames = @($hostname)

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

    return $newEndpoint
}


# Bootstrap JSON config for new app
$waasBootstrap = '{
    "account_ips": {},
    "useExistingIp": false,
    "serviceIp": "",
    "backendIp": "1.1.1.1",
    "backendType": "HTTP",
    "backendPort": 80,
    "applicationName": "New App Name",
    "useHttp": true,
    "serviceType": "HTTP",
    "httpServicePort": 80,
    "useHttps": true,
    "httpsServicePort": "443",
    "maliciousTraffic": "Passive",
    "hostnames": [
      {
        "hostname": "X"
      }
    ],
    "redirectHTTP": true
  }' | ConvertFrom-Json

# Connection basics
$waashost='https://api.waas.barracudanetworks.com'
$baseurl='v2/waasapi/applications'
$contentType = 'application/json'
$method = 'GET'

# Export app info
Write-Host "Invoke-RestMethod GET $waashost/$baseurl/$appId/"
try {
    $appInfo = Invoke-RestMethod -Uri $waashost/$baseurl/$appId/ -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
} catch {
    Write-Host "Unable to retrieve information for WaaS App Id $appId." -ForegroundColor Yellow
    Write-Host "  StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "  StatusDescription:" $_.Exception.Response.StatusDescription
    Write-Host "  Error Details:" ($_.ErrorDetails.Message | ConvertFrom-Json).errors
    exit
}

if ( $null -ne $appInfo.errors ) {
    Write-Host("Error retrieving data: $appInfo.errors, aborting operation...") -ForegroundColor Red
    exit
}

# Export app config
Write-Host "Invoke-RestMethod GET $waashost/$baseurl/$appId/export"
$appConfig = Invoke-RestMethod -Uri $waashost/$baseurl/$appId/export -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
if ( $appConfig -eq  '' ) {
    Write-Host("App $appId not found, aborting operation...") -ForegroundColor Red
    exit
}

# Export server config for app
Write-Host "Invoke-RestMethod GET $waashost/$baseurl/$appId/servers"
$appServers = Invoke-RestMethod -Uri $waashost/$baseurl/$appId/servers -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
if ( $appServers -eq  '' ) {
    Write-Host("App servers not found for app $appId, aborting operation...") -ForegroundColor Red
    exit
}

# Update boostrap data with info from $appId
$waasBootstrap.applicationName = $appName
$waasBootstrap.hostnames[0].hostname = $hostname
$waasBootstrap.backendType = $appServers.results[0].protocol
$waasBootstrap.backendPort = $appServers.results[0].port
$waasBootstrap.backendIp = $appServers.results[0].host
Write-Host "Using the following JSON to bootstrap new WaaS app:"
$waasJson = $waasBootstrap | ConvertTo-Json -Depth 25
Write-Host $waasJson

# Create new WaaS app step 1 - Initial creation
Write-Host "Invoke-WebRequest POST $waashost/$baseurl/ "
try {
    #Write-Host "DEBUGGING" -ForegroundColor Green
    $newApp = Invoke-WebRequest -Uri $waashost/$baseurl/ -Method Post -Body $waasJson -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
} catch {
    Write-Host "Unable to create new WaaS application." -ForegroundColor Yellow
    Write-Host "  StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "  StatusDescription:" $_.Exception.Response.StatusDescription
    Write-Host "  Error Details:" $_.ErrorDetails.Message
    exit    
}

if ( $null -ne $newApp.errors ) {
    Write-Host("Error retrieving data: $newApp.errors, aborting operation...") -ForegroundColor Red
    exit
}

$newAppInfo = $newApp.Content | ConvertFrom-Json
if ( $null -ne $newAppInfo.id ) {
    Write-Host "New App Info: "
    Write-Host $newAppInfo
} else {
    Write-Host "Failed to get the new WaaS app Id - undisclosed error occurred."
    exit
}
$newId = $newAppInfo.id
$newAppConfig = Invoke-RestMethod -Uri $waashost/$baseurl/$newId/export/compliance -Method $method -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }

Write-Host "Initial creation seems to have worked, pausing $sleepTimer seconds before continuing..."
Start-Sleep -s $sleepTimer

# Create new WaaS app step 2 - import configuration
# Skip the default rewrite rules
$appConfig.psobject.Properties.Remove('request_rewrite')
$appConfigJson = $appConfig | ConvertTo-Json -Depth 50
Write-Host "Invoke-RestMethod PATCH $waashost/$baseurl/$newId/import"
try {
    #Write-Host "DEBUGGING" -ForegroundColor Green
    $resimport = Invoke-RestMethod -Method Patch -Uri $waashost/$baseurl/$newId/import -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken } -Body $appConfigJson
} catch {
    Write-Host "  StatusCode:" $_.Exception.Response.StatusCode.value__ 
    Write-Host "  StatusDescription:" $_.Exception.Response.StatusDescription
    exit
}
Write-Host "Import seems to have worked, pausing $sleepTimer seconds before continuing..."
Start-Sleep -s $sleepTimer

# Create new WaaS app step 3 - import endpoint configuration
#  Retrieve new WaaS app's endpoints so we can match them up with the source app's endpoints
#  We need to loop through each endpoint and use the listening port as the key
#  Cannot assume that the source app is using only 80 and/or 443
#  Source app endpoint port 80 ==> Dest app endpoint port 80
#  Source app endpoint port 443 ==> Dest app endpoint port 443
#  Etc.

$newEndpoints = Invoke-RestMethod -Method Get -Uri $waashost/$baseurl/$newId/endpoints -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
$srcEndpointList = New-Object System.Collections.ArrayList
$srcEndpointTable = New-Object System.Collections.Hashtable
foreach ( $item in $appInfo.waas_services ) { 
    $srcEndpointTable.Add($item.dps_service.port.ToString(),$item.id.ToString())
    $srcEndpointList.Add($item.dps_service.port.ToString())
}

# Loop through new endpoints and update with source endpoint data
#  After each source endpoint as been copied to new app, remove from list
#  If there are any source endpoints left in the hashtable then we know we need
#  to invoke a POST to $waashost/$baseurl/$newId/endpoints for each one
#  This is because we are forced to create a port 80 and a port 443 endpoint at 
#  WaaS app creation time but the source app may have additional endpoints
## TODO: use the arraylist and hashtable to figure out which endpoints haven't yet been added to new waas app

foreach ( $tcpPort in $srcEndpointTable.Keys ) {
    # Look for this port in the new endpoints; if found update and remove from hashtable
    Write-Host "Source TCP Port " $tcpPort -ForegroundColor Magenta
    foreach ( $endpoint in $newEndpoints.results ) {
        Write-Host "Looking in src endpoints for target port " $endpoint.dps_service.port.ToString()
        if ( $tcpPort -eq $endpoint.dps_service.port.ToString() ) {
            # Found tcpPort endpoint in both source and destination apps
            $newEndpointId = $endpoint.id.ToString()
            Write-Host "Updating new endpoint id $newEndpointId"
            foreach ( $srcEndPointConfig in $appInfo.waas_services ) {
                if ( $srcEndPointConfig.dps_service.port.ToString() -eq $tcpPort ) {
                    # Found the source endpoint config data; grab all but the id value
                    #  Convert to JSON and PATCH the new app's endpoint id
                    #$newEndpointConfig = $srcEndPointConfig | Select-Object -ExcludeProperty id,cname
                    #$newEndpointConfig.dps_service = $newEndpointConfig | Select-Object -ExcludeProperty id,ip
                    #$newEndpointConfig.managed_service = $newEndpointConfig.managed_service | Select-Object -ExcludeProperty id,creation_moment,account
                    $newEndpointConfig = build_endpoint_configuration($srcEndPointConfig)
                    $newEndpointConfigJson = $newEndpointConfig | ConvertTo-Json -Depth 50
                    Write-Host "New endpoint config " $newEndpointConfigJson -ForegroundColor Green
                }
            }
            Write-Host "Invoke-RestMethod PATCH $waashost/$baseurl/$newId/endpoints/$newEndpointId"
            try {
            $r = Invoke-RestMethod -Method Patch -Uri $waashost/$baseurl/$newId/endpoints/$newEndpointId -Body $newEndpointConfigJson -ContentType $contentType -Headers @{'Accept' = 'application/json'; 'auth-api' = $waastoken }
            } catch {
                Write-Host "  StatusCode:" $_.Exception.Response.StatusCode.value__ 
                Write-Host "  StatusDescription:" $_.Exception.Response.StatusDescription
                exit
            }
        }
    }
    # Done with this endpoint
    $srcEndpointList.Remove($tcpPort)
}

if ( $srcEndpointList.Count -ge 1 ) {
    Write-Host "Still have at least one endpoint to create..."
    foreach ( $item in $srcEndpointList ) {
        Write-Host("Endpoint Id: {0} TCP Port: {1}", $item, $srcEndpointTable[$item]) 
    }
} else {
    Write-Host "All endpoints updated. Please review new WaaS app to ensure the configuration was successful."
}

