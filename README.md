# api-lab
This repo has some simple scripts and docs to assist with getting started using API interfaces with various Barracuda products. 

## Purpose
The purpose of this repo is to give the user an easy path to getting started with using APIs on selected Barracuda products. It is not meant to be comprehensive, rather it is more of an "API 101" introduction. 

# INTRODUCTION
Using the API for a given product requires an environment suitable for sending the REST API requests and processing the responses from the server or service. For the purposes of this lab we use both PowerShell and BASH. These can be utilized in Linux, Mac, and Windows as well as Azure Cloud Shell. GCP Cloud Shell Supports BASH. AWS does not have a cloud shell, however the AWS CLI comes pre-installed on the Amazon Linux AMI and can be downloaded for Linux, Mac, and Windows clients.

## BASH Environment
Not much is needed to begin with a bash environment. Most Linux distributions as well as the Azure cloud shell have a bash shell that is ready to go. Sometimes there are tools and utilities that need to be installed. The following apt command will install some helpful packages:  
    `sudo apt-get -y update && sudo apt-get -y install curl wget jq`

## PowerShell Environment
Windows comes with PowerShell 5.1 and the ISE or integrated scripting environment. While these are useful tools in their own right they are relatively old and Microsoft is no longer using them. I recommend using a combination of PowerShell 7 and VS Code. Here are some tips and resources that I've found helpful for getting PS7:
* [Fast and easy install of PS7](https://www.thomasmaurer.ch/2019/07/how-to-install-and-update-powershell-7/)
* [Azure doc: Install PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7)
* Use "Run as Administrator" if you have difficulty with permissions
* To set the execution scope for the local machine run the following in a PS7 admin session:  
    `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine`
* [PowerShell Master Class](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8)

Note - PS7 installs side-by-side with PS5.1, however PS7 will replace any PS6 installations.

## Unified Environment
In my personal opinion this is the ideal place to work because it permits you to work with both bash and ps scripts from a single location. It also allows you to use the same scripts in a "pure" PowerShell or "pure" Linux environment. Install VS Code, Microsoft Terminal, and Windows Subsystem for Linux (WSL) for a unified environment. With WSL installed you can have a full Linux system running within Windows 10, just like opening a PowerShell session. 

### Install WSL
Full installation documentation can be found [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10). For reference, here are the two commands I ran on my Windows 10 laptop to be ready for WSL:  
`dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`  
`dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`  
(Restart computer here)  

Once this is done you can install a Linux version from the Microsoft Store. I have had good success with Ubuntu 20.04 LTS.

### Install Windows Terminal
Windows terminal is a handy tool that lets you open multiple SSH sessions and PowerShell sessions in a single window. For simple SSH sessions it can do pretty much anything that Putty can do. Install Terminal from the Microsoft store and then simply launch it from the start menu.

### Install VS Code
Download VS Code here. Run the installer and then launch. Very simple, but very powerful. There are a number of add-on modules that can be installed and VS Code will suggest a few. To get to know VS Code I found the following video from the PowerShell Master Class quite helpful:
* [Getting Ready for Devops with PowerShell and VS Code](https://www.youtube.com/watch?v=yavDKHV-OOI&list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8&index=6&t=1728s)

Once you have your Linux and PowerShell installed you can edit and run both .ps1 and .sh scripts in the terminal window. NOTE: when editing bash scripts be sure to set the line endings properly. If you see "CRLF" in the lower-right corner of the VS Code window while editing a .sh file then change the line endings:
* Click on CRLF to open the line-endings selector. Choose "LF" then save the file.

One clue that line-endings are wrong is running a script and seeing an error that '\r' is not a valid command. 

## JSON - the language of APIs
Like it or not you will need to get accustomed to viewing, parsing, and occasionally crafting JSON data.
The following resources may help when dealing with JSON:  
[Free Formatter - JSON](https://www.freeformatter.com/json-validator.html)  
[JSON Reference](https://www.json.org/json-en.html)  
[Gentle JSON Tutorial](https://restfulapi.net/introduction-to-json/)  

Most API calls return JSON data in a raw format. This is difficult to read. Copy the raw JSON and paste into the Free Formatter mentioned above to get a view of the data that can easily be explored. Alternatively, capture the raw JSON and pipe it through the jq tool in bash. In PowerShell there is a cmdlet called ConvertFrom-JSON that takes a string of JSON data and converts it into a psobject that has an object for each field in the JSON string. In both cases this makes it easier to analyze a response to an API call.

## Barracuda API Information
* WAF
Bash and PowerShell scripts
PS API module

* WAF as a Service

* CloudGen Firewall

* Cloud Security Guardian
