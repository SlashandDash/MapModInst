# Check for administrative privileges
function Test-Admin {
    try {
        $null = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-Admin)) {
    # Display an error message and exit
    Write-Host "Error: Run this script with administrative privileges." -ForegroundColor Red
    exit
}

# Initial destination path
$destinationPath = "C:\Program Files (x86)\Steam\steamapps\common\Crab Game"
$zipFilePath = "$env:USERPROFILE\Downloads\BepInEx_UnityIL2CPP.zip"  # Changed to Downloads folder
$bepInExPath = "$destinationPath\BepInEx"
$pluginsPath = "$bepInExPath\plugins"
$mapModPath = "$pluginsPath\MapMod.dll"
$crabGameExePath = "$destinationPath\Crab Game.exe"

# Check if MapMod is already installed
if (Test-Path -Path $mapModPath) {
    Write-Host "MapMod is already installed." -ForegroundColor Green
    exit
}

# Check if Crab Game executable exists
if (-not (Test-Path -Path $crabGameExePath)) {
    # If the executable does not exist, set confirmation to 'n'
    $confirmation = 'n'
} else {
    # Ask the user if the destination path is correct
    do {
        $confirmation = Read-Host "Is the destination path for Crab Game correct? ($destinationPath) [y/n]"
        
        if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
            # Continue as normal
            break
        } elseif ($confirmation -eq 'n' -or $confirmation -eq 'N') {
            # Prompt the user to change the path
            do {
                $destinationPath = Read-Host "Please enter the correct path for Crab Game"
                
                # Check if the provided path exists
                if (-not (Test-Path -Path $destinationPath)) {
                    Write-Host "The path does not exist. Please enter a valid path." -ForegroundColor Red
                } elseif (-not (Test-Path -Path "$destinationPath\Crab Game.exe")) {
                    Write-Host "The folder does not contain 'Crab Game.exe'. Please enter a valid path." -ForegroundColor Red
                }
            } while (-not (Test-Path -Path $destinationPath) -or -not (Test-Path -Path "$destinationPath\Crab Game.exe"))  # Repeat until a valid path is provided
            
            $bepInExPath = "$destinationPath\BepInEx"
            $pluginsPath = "$bepInExPath\plugins"
            $mapModPath = "$pluginsPath\MapMod.dll"  # Update the path after changing destination
            break
        } else {
            Write-Host "Please only enter yes (y) or no (n)."
        }
    } while ($true)
}

# If the confirmation is 'n', exit the script
if ($confirmation -eq 'n') {
    Write-Host "Crab Game executable not found. Exiting script." -ForegroundColor Red
    exit
}

# Check if the plugins directory exists
if (Test-Path -Path $pluginsPath) {
    # Download the MapMod.dll file and place it in the plugins folder
    Invoke-WebRequest -Uri "https://github.com/o7Moon/CrabGame.MapMod/releases/download/v0.7.8/MapMod.dll" -OutFile $mapModPath
} elseif (Test-Path -Path $bepInExPath) {
    # Create the BepInEx\plugins directory if it does not exist
    New-Item -ItemType Directory -Path $pluginsPath -Force
    
    # Download the MapMod.dll file and place it in the plugins folder
    Invoke-WebRequest -Uri "https://github.com/o7Moon/CrabGame.MapMod/releases/download/v0.7.8/MapMod.dll" -OutFile $mapModPath
} else {
    # Download the ZIP file
    Invoke-WebRequest -Uri "https://builds.bepinex.dev/projects/bepinex_be/577/BepInEx_UnityIL2CPP_x64_ec79ad0_6.0.0-be.577.zip" -OutFile "$env:USERPROFILE\Downloads\BepInEx.zip"

    # Extract the ZIP file to the destination path
    Expand-Archive -Path "$env:USERPROFILE\Downloads\BepInEx.zip" -DestinationPath $destinationPath -Force

    # Create the plugins directory
    New-Item -ItemType Directory -Path $pluginsPath -Force

    # Download the MapMod.dll file and place it in the plugins folder
    Invoke-WebRequest -Uri "https://github.com/o7Moon/CrabGame.MapMod/releases/download/v0.7.8/MapMod.dll" -OutFile $mapModPath
}

# Confirm installation
if (Test-Path -Path $mapModPath) {
    Write-Host "MapMod has been successfully installed to $pluginsPath." -ForegroundColor Green
} else {
    Write-Host "Error: MapMod installation failed." -ForegroundColor Red
}

# Clean up: Remove the downloaded ZIP file
if (Test-Path -Path "$env:USERPROFILE\Downloads\BepInEx.zip") {
    Remove-Item -Path "$env:USERPROFILE\Downloads\BepInEx.zip" -Force
}

# Final message
Write-Host "Script execution completed." -ForegroundColor Cyan