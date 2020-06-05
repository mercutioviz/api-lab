# Run these at the command line or use F8 in VS Code to run each line individually
# Set the url of your WAF
Set-BarracudaWAFApiUrl -Url "http://51.143.38.93:8000"

# Connect to WAF
Connect-BarracudaWAFAccount -Credential (Get-Credential)

# Retrieve a list of services
Get-BarracudaWAFService

# Disconnect
#Disconnect-BarracudaWAFAccount
