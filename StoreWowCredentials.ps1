# Function to get WoW version from user
function Get-WowVersion {
    Write-Host "Which version of World of Warcraft would you like to use?"
    Write-Host "1. Vanilla (Hardcore/Fresh servers)"
    Write-Host "2. Classic (Wrath or earlier)"
    Write-Host "3. Retail (Dragonflight)"
    
    while ($true) {
        $choice = Read-Host "Enter 1, 2, or 3"
        switch ($choice) {
            "1" {
                $global:WoWVersion = "Vanilla"
                return "C:\Program Files (x86)\World of Warcraft\_classic_era_"
            }
            "2" {
                $global:WoWVersion = "Classic"
                return "C:\Program Files (x86)\World of Warcraft\_classic_"
            }
            "3" {
                $global:WoWVersion = "Retail"
                return "C:\Program Files (x86)\World of Warcraft\_retail_"
            }
            default {
                Write-Host "❌ Invalid input. Please enter 1, 2, or 3." -ForegroundColor Yellow
            }
        }
    }
}

# Function to prompt for a valid install path
function Get-ValidInstallPath {
    $defaultPath = Get-WowVersion

    while ($true) {
        Write-Host "`nPlease enter the path to your World of Warcraft install directory."
        Write-Host "Tip: You can find the install location by clicking the gear icon next to 'Play' in the Battle.net client, then selecting 'Show in Explorer'."
        Write-Host "Press Enter to use the default path for ${WoWVersion}: $defaultPath"
        $inputPath = Read-Host "WoW install directory"

        if ([string]::IsNullOrWhiteSpace($inputPath)) {
            $inputPath = $defaultPath
            Write-Host "Using default path: $inputPath"
        }

        if (Test-Path $inputPath) {
            return $inputPath
        } else {
            Write-Host ""
            Write-Host "❌ The specified path does not exist:"
            Write-Host "   $inputPath" -ForegroundColor Red
            Write-Host ""
            Write-Host "⚠ Please try again or verify the path in the Battle.net client." -ForegroundColor Yellow
        }
    }
}

# Start the process
$installPath = Get-ValidInstallPath

# Define paths for encrypted files
$encryptedPasswordFile = Join-Path $installPath "encrypted_password.txt"
$encryptedUsernameFile = Join-Path $installPath "encrypted_username.txt"

# Remove existing encrypted files if they exist
if (Test-Path $encryptedUsernameFile) {
    Remove-Item $encryptedUsernameFile
    Write-Host "Existing encrypted username file found and replaced."
}

if (Test-Path $encryptedPasswordFile) {
    Remove-Item $encryptedPasswordFile
    Write-Host "Existing encrypted password file found and replaced."
}

# Prompt for credentials
$username = Read-Host "Please enter your username"
$password = Read-Host "Please enter your password"

# Encrypt and convert to strings
$secureUsername = ConvertTo-SecureString $username -AsPlainText -Force
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$encryptedUsername = $secureUsername | ConvertFrom-SecureString
$encryptedPassword = $securePassword | ConvertFrom-SecureString

# Save to files
$encryptedUsername | Out-File $encryptedUsernameFile
$encryptedPassword | Out-File $encryptedPasswordFile

# Confirmation
Write-Host ""
Write-Host "✅ Encrypted username and password have been saved to:"
Write-Host "   $installPath"
Write-Host ""
Write-Host "👉 You may now run test.bat to launch World of Warcraft and auto-login for the $WoWVersion version."
