# not finished
# need script to download and place files in C:\Program Files\Wow_Credential_Filler
# create folder if needed 
# then call setup_profile.ps1


# Function to check if script is running as administrator
function Test-IsAdmin {
    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)
    return $currentPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to download files from GitHub repository
function Download-GitHubRepo {
    $repoUrl = "https://github.com/RavingSmurfGB/Wow_Credential_Filler/archive/refs/heads/Development.zip"
    $downloadsFolder = [System.Environment]::GetFolderPath("MyDocuments")
    $downloadsFolder = Join-Path -Path $downloadsFolder -ChildPath "..\Downloads" # Navigating to "Downloads" folder
    $destinationPath = Join-Path -Path $downloadsFolder -ChildPath "Development.zip"

    Write-Host "Downloading repository from $repoUrl to $destinationPath..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $repoUrl -OutFile $destinationPath
        Write-Host "Download complete!" -ForegroundColor Green
    } catch {
        Write-Host "Error downloading the repository: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to extract the ZIP file to the temporary folder
function Extract-ZipFile {
    $downloadsFolder = [System.Environment]::GetFolderPath("MyDocuments")
    $downloadsFolder = Join-Path -Path $downloadsFolder -ChildPath "..\Downloads"
    $zipFilePath = Join-Path -Path $downloadsFolder -ChildPath "Development.zip"
    
    # Create temporary folder to extract to
    $tempFolder = Join-Path -Path $downloadsFolder -ChildPath "Wow_Credential_TMP"
    if (-not (Test-Path -Path $tempFolder)) {
        Write-Host "Creating temporary extraction folder at $tempFolder..." -ForegroundColor Cyan
        New-Item -Path $tempFolder -ItemType Directory
    }

    Write-Host "Extracting ZIP file to $tempFolder..." -ForegroundColor Cyan
    try {
        Expand-Archive -Path $zipFilePath -DestinationPath $tempFolder -Force
        Write-Host "Extraction complete!" -ForegroundColor Green
    } catch {
        Write-Host "Error extracting the ZIP file: $_" -ForegroundColor Red
        exit 1
    }
}

# Check if running as administrator, if not, re-run as administrator
if (-not (Test-IsAdmin)) {
    Write-Host "This script is not running as an administrator. Re-running as administrator..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath" -Verb RunAs
    exit
}

# Main script execution
Write-Host "Script is running as an administrator!" -ForegroundColor Green

# Download files from GitHub repository
Download-GitHubRepo

# Extract the ZIP file to a temporary folder
Extract-ZipFile

# Wait for user confirmation before continuing
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "Installation process complete!" -ForegroundColor Green
