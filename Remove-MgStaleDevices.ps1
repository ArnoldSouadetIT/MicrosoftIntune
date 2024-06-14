<#
.DESCRIPTION
This script will delete stale devices (More than 180 days inactivity) from EntraID
This Script needs to be run from an Azure Automation runbook using Managed Identity

Author : Arnold Souadet
Version : 1.0
#>

##*===============================================
##* PRE-REQUISITES
##*===============================================
# Modules 
# Install Module Microsoft.Graph.Identity.DirectoryManagement to azure Automation Account
# Install Module Microsoft.Graph.Authentication to azure Automation Account
# Install Module Microsoft.Graph.DeviceManagement to azure Automation Account
# Install Module Microsoft.Graph.DeviceManagement.Enrollment to azure Automation Account
# 
# Managed Identity Permissions
# Microsoft Graph - Device.ReadWrite.All - Application
# Microsoft Graph - DeviceManagementServiceConfig.Read.All - Application
##*===============================================
##* END PRE-REQUISITES
##*===============================================


##*===============================================
##* IMPORT MODULES
##*===============================================
try {
    Import-Module -Name Microsoft.Graph.Identity.DirectoryManagement
    Import-Module -Name Microsoft.Graph.Authentication
    Import-Module -Name Microsoft.Graph.DeviceManagement
    Import-Module -Name Microsoft.Graph.DeviceManagement.Enrollment
    Write-Output "Modules Imported with success"
}
    catch {
        Write-Error "Modules not imported with success"
        Exit
    }

##*===============================================
##* END IMPORT MODULES
##*===============================================


##*===============================================
##* VARIABLE DECLARATION
##*===============================================

#VARIABLE FOR STALE DATE 
$StaleDate = (Get-Date).AddDays(-180)

##*===============================================
##* END VARIABLE DECLARATION
##*===============================================


##*===============================================
##* FUNCTIONS
##*===============================================



##*===============================================
##* END FUNCTIONS
##*===============================================



##*===============================================
##* START SCRIPT
##*===============================================

#Connect the mgGraph 

try {
Write-Output "Connection to MgGraph..." 
Connect-MgGraph -Identity
Write-Output "Connection established with success" 
}
catch {
Write-Error "Error on MgGraph Connection"
Exit
}


# Get stale Devices
$Devices = Get-MgDevice -All | Where {$_.ApproximateLastSignInDateTime -le $StaleDate}
$AutopilotDeviceslist = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity 

$DevicesCount = $Devices.Count

Write-Output "There is $DevicesCount devices to remove" 

#Loop to remove stale devices
foreach ($Device in $Devices) { 
    $DeviceName = $Device.DisplayName
    $DeviceID = $Device.Id
    
    If ($AutopilotDevicesList.AzureActiveDirectoryDeviceId -contains $DeviceID)
    {
    Write-Output "Device $DeviceName is Autopilot" 
    }
    Else
    {
        try {
            $DeviceName = $Device.DisplayName
            Write-Output "Deleting device : $DeviceName - $DeviceID" 
            Remove-MgDevice -DeviceId $Device.Id
            Write-Output "Device $DeviceName successfully deleted" 
        }
        catch {
            Write-Output "Device $DeviceName - $DeviceID can't be deleted" 
        }
    
}
}



#Disconnect MgGraph
Write-Output "Disconnecting MgGraph"
Disconnect-MgGraph 


##*===============================================
##* END SCRIPT
##*===============================================
