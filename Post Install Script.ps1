#Creates NxData folder
New-Item -Path "c:\" -Name "IT_data" -ItemType "directory"

Copy-item "\\Server\powerconfig.pow" -Destination "C:\IT_data"

#used to set powerplans
powercfg /IMPORT C:\powerconfig.pow 39827f5b-cce6-4844-886b-28f59d53d2bc

powercfg /s 39827f5b-cce6-4844-886b-28f59d53d2bc
Write-Output "Powerplan Set"

Remove-Item -Path "C:\IT_data\powerconfig.pow"


#sets UAC to disabled, Requires restart
Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 0

#remove XPS Doc writer; requires restart
Remove-Printer -Name "Microsoft XPS Document Writer" 

#Folder options
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0
Set-ItemProperty $key ShowHidden 1
Set-ItemProperty $key ShowSuperHidden 2
#adds reg entry for sharing wizard
New-ItemProperty -Path $key -Name "SharingWizardOn" -Value "0" -PropertyType DWORD -Force
#adds reg entry for Display full path
New-ItemProperty -Path $key -Name "FullPathAddress" -Value "1" -PropertyType DWORD -Force


New-ItemProperty -Path $key -Name "AutoCheckSelect" -Value "0" -PropertyType DWORD -Force


Stop-Process -processname explorer


$Source = '\\Server\shortcuts\*'
$Destination = 'C:\users\*\Desktop'
Get-ChildItem $Destination | ForEach-Object {Copy-Item -Path $Source -Destination $_ -Force -Recurse}


# Disable Location Tracking
Write-Host "Disabling Location Tracking..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0

# Stop and disable WAP Push Service
Write-Host "Stopping and disabling WAP Push Service..."
Stop-Service "dmwappushservice"
Set-Service "dmwappushservice" -StartupType Disabled

#Network speed test Windows app
Get-AppxPackage *NetworkSpeedTest* | Remove-AppxPackage
Get-appxprovisionedpackage –online | where-object {$_.packagename –like "*NetworkSpeedTest*"} | remove-appxprovisionedpackage –online

#Whiteboard Windows app
Get-AppxPackage *Whiteboard* | Remove-AppxPackage
Get-appxprovisionedpackage –online | where-object {$_.packagename –like "*Whiteboard*"} | remove-appxprovisionedpackage –online



#Restart PC
Write-Host "Press any key to restart your system..." -ForegroundColor Black -BackgroundColor White
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host "Restarting..."
Restart-Computer