# Experimental code to test automatic privilege escalation

# Get the current user's identity to check their roles and permissions
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

# Check if the current user is running in the "Administrator" role
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Current window is standard. Attempting to relaunch as Administrator..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    
    # Relaunch the current script file in a new process with "RunAs" (Administrator) verb
    # -NoExit is added to keep the new window open to see the result
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -NoExit -File `"$PSCommandPath`"" -Verb RunAs
    
    # Exit the current (standard) window
    exit
}

# If the script reaches this point, it is running with elevated privileges
Write-Host "Success! This window is now running with Administrator privileges." -ForegroundColor Green
Write-Host "The currently running script path is: $PSCommandPath"

#Find the app in the repository 

function Test-Installed($APP) {
   $Paths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", 
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*", 
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"


 Get-ItemProperty $Paths -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -ne $null } | 
    Select-Object DisplayName | Where-Object {$_.DisplayName -match $APP}
}

# Define script path and scheduled task name for auto-resume logic

$ScriptPath = $PSCommandPath

$TaskName = "ResumeSetupTask"

# --- Phase 1: WSL 2 Installation & Reboot Logic ---

if (-not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
   
    Write-Host "--- Installing WSL 2 and preparing for Reboot ---" -ForegroundColor Cyan
    
    # Install WSL core components (No distribution yet to handle reboot first)
    wsl --install --no-distribution
    
    # Create a Scheduled Task to resume the script automatically after login
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""

    $Trigger = New-ScheduledTaskTrigger -AtLogOn

    $Principal = New-ScheduledTaskPrincipal -UserId (WhoAmI) -RunLevel Highest

    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force

    Write-Host "System will restart in 5 seconds to complete WSL installation..." -ForegroundColor Yellow

    Start-Sleep -Seconds 5
    Restart-Computer
    return
}

# --- Phase 2: Ubuntu & Docker Setup (Runs after Reboot) ---


Write-Host "--- Resuming Environment Setup ---" -ForegroundColor Green

# 1. Install Ubuntu and set as default distribution

$Check_Ubuntu = wsl --list --quiet | ForEach-Object {$_.replace("`0","").Trim()} | where {$_ -ne ""}

if (-not ($Check_Ubuntu -match "Ubuntu")) {

    Write-Host "Installing Ubuntu distribution..." -ForegroundColor Cyan
    wsl --install -d Ubuntu --web-download
    wsl --set-default Ubuntu

} else { wsl --set-default Ubuntu  Write-Host "I Found Ubuntu" -ForegroundColor Green }

# 2. Install Docker Desktop using Winget

if (-not (Test-Installed "Docker")) {

    Write-Host "Installing Docker Desktop..." -ForegroundColor Cyan
    winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements

} else {Write-Host "you'have Docker" -ForegroundColor Green }

# 3. Download and Run docker.yml from GitHub

$dockerYamlUrl = "https://githubusercontent.com" # REPLACE WITH YOUR URL

$destinationDir = "C:\DockerSetup"

$destinationFile = "$destinationDir\docker.yml"


if (-not (Test-Path $destinationDir)) { New-Item -Path $destinationDir -ItemType Directory }

Write-Host "Downloading docker.yml from GitHub..." -ForegroundColor Cyan

#Send Https Request 

curl.exe --location -C - "$dockerYamlUrl" -o "$destinationFile" -#

if ($? -and (Test-Path $destinationFile)) { 

Write-Host "Download successful. Starting Docker Compose..." -ForegroundColor Green

    Push-Location $destinationDir #pushd 

    docker-compose -f "$destinationFile" up -d 
    docker-compose -f "docker.yml" up -d
    Pop-Location                  #popd

} else { Write-Error "Failed to download the file or file not found." -ForegroundColor red }


# --- Phase 3: Virtualization Tools ---

$found_VB = Test-Installed "VirtualBox"
$found_VM = Test-Installed "VMware"

if (-not ($found_VB -or $found_VM)) {
    Write-Host "No Virtualization software found. Installing Oracle VirtualBox..." -ForegroundColor Cyan
    # Install Oracle VirtualBox
    winget install -e --id Oracle.VirtualBox --accept-package-agreements --accept-source-agreements
} else {
    
    $foundApps = @($found_VB, $found_VM) | Where-Object { $_ }
    $appNames = $foundApps -join " & "
    
    Write-Host "Found: [$appNames] is already installed." -ForegroundColor Green
}

# --- Phase 4: Cleanup Scheduled Tasks ---

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {

    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

    Write-Host "Post-reboot task cleaned up successfully." -ForegroundColor Magenta
}

Write-Host "All tasks completed successfully!" -ForegroundColor Green

Write-Host " Now, You've all thing"  "without parrot os image , plase download in internet " -ForegroundColor red