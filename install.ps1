# Function to check if script is running as administrator
function Test-IsAdmin {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)
    return $currentPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to write logs
function Write-Log {
    param (
        [string]$Message,
        [string]$LogFilePath = "C:\Program Files\Wow_Credential_Filler\install_log.txt"
    )

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $Message"
    
    # Write to console
    Write-Host $logMessage

    # Write to log file
    if (Test-Path $LogFilePath) {
        Add-Content -Path $LogFilePath -Value "$logMessage`r`n"
    } else {
        New-Item -Path $LogFilePath -ItemType File -Force
        Add-Content -Path $LogFilePath -Value "$logMessage`r`n"
    }
}

# Function to download files from GitHub repository
function Download-GitHubRepo {
    $repoUrl = "https://github.com/RavingSmurfGB/Wow_Credential_Filler/archive/refs/heads/Development.zip"
    $downloadsFolder = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('UserProfile'), 'Downloads')  # Correct Downloads path
    $destinationPath = Join-Path -Path $downloadsFolder -ChildPath "Development.zip"
    $tmpFolderPath = Join-Path -Path $downloadsFolder -ChildPath "Wow_Credential_TMP"  # Folder to check for

    Write-Host "Starting the download of the repository..."
    Write-Host "Repository URL: $repoUrl"

    # Check if the file already exists
    if (Test-Path -Path $destinationPath) {
        Write-Host "The file 'Development.zip' already exists in the Downloads folder."

        # Ask the user if they want to redownload
        $userChoice = Read-Host "Do you want to redownload it? (Y/N)"
        
        if ($userChoice -eq "Y" -or $userChoice -eq "y") {
            Write-Host "Redownloading the repository..."

            # Delete the existing file
            try {
                Remove-Item -Path $destinationPath -Force
                Write-Host "'Development.zip' has been deleted."
            } catch {
                Write-Host "Error deleting existing file: $_"
                exit 1
            }

            # Check if the temporary folder exists and delete it
            if (Test-Path -Path $tmpFolderPath) {
                try {
                    Remove-Item -Path $tmpFolderPath -Recurse -Force
                    Write-Host "'Wow_Credential_TMP' folder has been deleted."
                } catch {
                    Write-Host "Error deleting 'Wow_Credential_TMP' folder: $_"
                    exit 1
                }
            }

            # Proceed to download the file again
            try {
                Invoke-WebRequest -Uri $repoUrl -OutFile $destinationPath
                Write-Host "Download complete!"  # Logs successful download
            } catch {
                Write-Host "Error downloading the repository: $_"
                exit 1
            }
        } else {
            Write-Host "Skipping the download."
        }
    } else {
        Write-Host "Downloading repository from $repoUrl to $destinationPath..."

        # Proceed to download the file as it does not exist
        try {
            Invoke-WebRequest -Uri $repoUrl -OutFile $destinationPath
            Write-Host "Download complete!"  # Logs successful download
        } catch {
            Write-Host "Error downloading the repository: $_"
            exit 1
        }
    }

    # Check if the file has been downloaded successfully before proceeding
    if (-not (Test-Path -Path $destinationPath)) {
        Write-Host "Error: Failed to download the ZIP file."
        exit 1
    }

    # Clear the console
    Clear-Host
}

# Function to extract the ZIP file to the temporary folder
function Extract-ZipFile {
    $downloadsFolder = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('UserProfile'), 'Downloads')  # Correct Downloads path
    $zipFilePath = Join-Path -Path $downloadsFolder -ChildPath "Development.zip"
    
    # Ensure that the file exists before trying to extract
    if (-not (Test-Path -Path $zipFilePath)) {
        Write-Log "Error: Zip file does not exist at $zipFilePath"
        Write-Host "Error: Zip file does not exist at $zipFilePath"
        exit 1
    }

    # Create temporary folder to extract to
    $tempFolder = Join-Path -Path $downloadsFolder -ChildPath "Wow_Credential_TMP"
    if (-not (Test-Path -Path $tempFolder)) {
        Write-Log "Creating temporary extraction folder at $tempFolder..."
        Write-Host "Creating temporary extraction folder at $tempFolder..."
        New-Item -Path $tempFolder -ItemType Directory
    }

    Write-Log "Extracting ZIP file to $tempFolder..."
    Write-Host "Extracting ZIP file to $tempFolder..."
    try {
        Expand-Archive -Path $zipFilePath -DestinationPath $tempFolder -Force
        Write-Log "Extraction complete!"
        Write-Host "Extraction complete!"
    } catch {
        Write-Log "Error extracting the ZIP file: $_"
        Write-Host "Error extracting the ZIP file: $_"
        exit 1
    }

    # Clear the console
    Clear-Host
}

# Function to check if a folder exists, and ask for reinstall if it does
function Check-ExistingInstall {
    $folderPath = "C:\Program Files\Wow_Credential_Filler"
    $roamingFolderPath = "C:\Users\Jo\AppData\Roaming\Wow_Credential_Filler"

    if (Test-Path -Path $folderPath -PathType Container) {
        Write-Host "An existing installation of Wow_Credential_Filler has been detected."
        Write-Log "An existing installation of Wow_Credential_Filler has been detected."

        # Prompt user if they want to reinstall
        $userChoice = Read-Host "Do you want to reinstall? (Y/N)"
        
        if ($userChoice -eq "Y" -or $userChoice -eq "y") {
            Write-Host "Reinstalling... Removing existing installation..."
            Write-Log "Reinstalling... Removing existing installation..."
            
            # Delete the installation folder
            try {
                Remove-Item -Path $folderPath -Recurse -Force
                Write-Host "Existing installation folder deleted."
                Write-Log "Existing installation folder deleted."
            } catch {
                Write-Host "Error deleting existing installation folder: $_"
                Write-Log "Error deleting existing installation folder: $_"
                exit 1
            }

            # Delete the roaming folder if it exists
            if (Test-Path -Path $roamingFolderPath) {
                try {
                    Remove-Item -Path $roamingFolderPath -Recurse -Force
                    Write-Host "Existing roaming folder deleted."
                    Write-Log "Existing roaming folder deleted."
                } catch {
                    Write-Log "Error deleting roaming folder: $_"
                    Write-Host "Error deleting roaming folder: $_"
                    exit 1
                }
            }

            # Recreate the installation folder
            Write-Host "Recreating the installation folder at $folderPath..."
            Write-Log "Recreating the installation folder at $folderPath..."
            try {
                New-Item -Path $folderPath -ItemType Directory -Force
                Write-Host "Installation folder recreated at $folderPath."
                Write-Log "Installation folder recreated at $folderPath."
            } catch {
                Write-Log "Error recreating installation folder: $_"
                Write-Host "Error recreating installation folder: $_"
                exit 1
            }
        } else {
            Write-Host "Installation aborted by user."
            Write-Log "Installation aborted by user."
            exit 0
        }
    } else {
        Write-Host "The install directory does not exist. Creating - $folderPath"
        Write-Log "The install directory does not exist. Creating - $folderPath"
        New-Item -Path $folderPath -ItemType Directory -Force
        Write-Host "Folder created at $folderPath"
        Write-Log "Folder created at $folderPath"
    }

    # Clear the console
    Clear-Host
}

# Function to copy extracted files to the destination folder
function Copy-ExtractedFiles {
    $downloadsFolder = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('UserProfile'), 'Downloads')  # Correct Downloads path
    $tempFolder = Join-Path -Path $downloadsFolder -ChildPath "Wow_Credential_TMP"
    $installPath = "C:\Program Files\Wow_Credential_Filler"

    # The path to the folder inside the temp directory that contains the extracted files
    $sourceFolder = Join-Path -Path $tempFolder -ChildPath "Wow_Credential_Filler-Development"

    Write-Log "Copying extracted files from $sourceFolder to $installPath..."
    Write-Host "Copying extracted files from $sourceFolder to $installPath..."

    # Ensure that the destination folder exists
    if (-not (Test-Path -Path $installPath)) {
        try {
            New-Item -Path $installPath -ItemType Directory -Force
            Write-Host "Created the install path: $installPath"
        } catch {
            Write-Host "Error creating install path: $_"
            Write-Log "Error creating install path: $_"
            exit 1
        }
    }

    # Check if the source folder exists
    if (-not (Test-Path -Path $sourceFolder)) {
        Write-Host "Error: Source folder $sourceFolder does not exist."
        Write-Log "Error: Source folder $sourceFolder does not exist."
        exit 1
    }

    # Copy the files directly from the Wow_Credential_Filler-Development folder to the target directory
    try {
        # Get all files and subfolders inside the source folder
        $filesAndSubfolders = Get-ChildItem -Path $sourceFolder -Recurse

        # Copy the files to the target directory
        foreach ($item in $filesAndSubfolders) {
            $destination = Join-Path -Path $installPath -ChildPath $item.Name

            # If the item is a file, copy it
            if ($item.PSIsContainer -eq $false) {
                Copy-Item -Path $item.FullName -Destination $destination -Force
            } elseif ($item.PSIsContainer -eq $true) {
                # If it's a directory, create it in the destination
                $destinationDir = Join-Path -Path $installPath -ChildPath $item.Name
                if (-not (Test-Path -Path $destinationDir)) {
                    New-Item -Path $destinationDir -ItemType Directory -Force
                }
            }
        }

        Write-Log "Files copied successfully!"
        Write-Host "Files copied successfully!"
    } catch {
        Write-Log "Error copying files: $_"
        Write-Host "Error copying files: $_"
        exit 1
    }

    # Clear the console
    Clear-Host
}

# Main Install Process
Write-Host "Starting the installation process..."

# Function to run as admin if necessary
if (-not (Test-IsAdmin)) {
    Write-Output "This script is not running as an administrator. Re-running as administrator..."
    try {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    } catch {
        Write-Output "Error trying to re-run script as administrator: $_"
        Write-Host "Error trying to re-run script as administrator: $_"
        exit 1
    }
    exit
}

# Step 1: Check if the install folder exists
Check-ExistingInstall

# Step 2: Download the repository
Download-GitHubRepo

# Step 3: Extract ZIP file
Extract-ZipFile

# Step 4: Copy files to install location
Copy-ExtractedFiles

# Step 5: Inform the user that installation was successful


Write-Host "        -- Setup complete! -- " 
Write-Host " You now need to configure your credentials by following the instructions in setup_profile.ps1"
Write-Host " This is located at C:\Program Files\Wow_Credential_Filler"
Write-Host "  "


# Wait for the user to press Enter
Read-Host "Press Enter to continue..."

# Clean up downloaded files and temp folder
$downloadsFolder = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('UserProfile'), 'Downloads')
$zipFilePath = Join-Path -Path $downloadsFolder -ChildPath "Development.zip"
$tempFolder = Join-Path -Path $downloadsFolder -ChildPath "Wow_Credential_TMP"

# Remove Development.zip and Wow_Credential_TMP
Remove-Item -Path $zipFilePath -Force
Remove-Item -Path $tempFolder -Recurse -Force

# Clear the console
Clear-Host

# Step 6: Launch setup_profile.ps1
$setupProfileScript = "C:\Program Files\Wow_Credential_Filler\setup_profile.ps1"

# Checking if the script exists before launching
if (Test-Path $setupProfileScript) {
    Write-Host "Launching setup_profile.ps1..."
    
    # Ensure script is launched with the proper execution policy and arguments
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$setupProfileScript`""

    Write-Host "The setup_profile.ps1 script has been launched. Follow the prompts to configure your credentials."
} else {
    Write-Host "Error: setup_profile.ps1 was not found at C:\Program Files\Wow_Credential_Filler."
}