# Function to decrypt a password using DPAPI (from setup.ps1)
function Decrypt-Password {
    param (
        [string]$encryptedPassword
    )

    # Decrypt the encrypted password using the Windows DPAPI
    $securePassword = $encryptedPassword | ConvertTo-SecureString

    # Convert SecureString to plain text password
    $plainPassword = [System.Net.NetworkCredential]::new('', $securePassword).Password

    return $plainPassword
}

# Set the ECHO_OUTPUT variable to 1 to enable echoing, or 0 to disable
$ECHO_OUTPUT = 1

# Default config path
$defaultConfigPath = "C:\Users\Jo\AppData\Roaming\Wow_Credential_Filler\classic"

# Check if a config path argument is provided, if not, use the default path
if ($args.Count -eq 0) {
    $configDir = $defaultConfigPath
} else {
    $configDir = $args[0].Trim('"')  # Remove any potential surrounding quotes
}

# Construct the config file path
$configFile = Join-Path $configDir "config.txt"
$aesKeyFile = Join-Path $configDir "aes.key"
$aesIvFile = Join-Path $configDir "aes.iv"

# Print the informational messages for the config files
Write-Host "[INFO] Config file path: $configFile"
Write-Host "[INFO] AES key file path: $aesKeyFile"
Write-Host "[INFO] AES IV file path: $aesIvFile"

# Verify that the necessary files exist in the config directory
if (!(Test-Path $configFile)) {
    Write-Host "[ERROR] Config file not found: $configFile"
    exit 1
}

if (!(Test-Path $aesKeyFile)) {
    Write-Host "[ERROR] AES key file not found: $aesKeyFile"
    exit 1
}

if (!(Test-Path $aesIvFile)) {
    Write-Host "[ERROR] AES IV file not found: $aesIvFile"
    exit 1
}

# Read the config file contents and extract the necessary information
$config = Get-Content $configFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -match "^(.+?):\s*(.+)$") {
        $matches[1] = $matches[1].Trim()
        $matches[2] = $matches[2].Trim()
        New-Object PSObject -property @{ $matches[1] = $matches[2] }
    }
}

$WoWVersion = ($config | Where-Object { $_.PSObject.Properties.Name -eq 'WoWVersion' }).WoWVersion
$WoWDirectory = ($config | Where-Object { $_.PSObject.Properties.Name -eq 'WoWDirectory' }).WoWDirectory
$WoWUsername = ($config | Where-Object { $_.PSObject.Properties.Name -eq 'WoWUsername' }).WoWUsername
$WoWPassword = ($config | Where-Object { $_.PSObject.Properties.Name -eq 'WoWPassword' }).WoWPassword

# Set the WoW executable path based on WoWVersion
if ($WoWVersion -eq "Vanilla") {
    $WOW_PATH = Join-Path $WoWDirectory "_classic_era_\WowClassic.exe"
} elseif ($WoWVersion -eq "Classic") {
    $WOW_PATH = Join-Path $WoWDirectory "_classic_\WowClassic.exe"
} elseif ($WoWVersion -eq "Retail") {
    $WOW_PATH = Join-Path $WoWDirectory "_retail_\Wow.exe"
} else {
    Write-Host "[ERROR] Invalid WoWVersion specified. Exiting."
    exit 1
}

# Print the informational messages for WoW variables
Write-Host "[INFO] WoW Version: $WoWVersion"
Write-Host "[INFO] WoW Directory: $WoWDirectory"
Write-Host "[INFO] WoW Username: $WoWUsername"
Write-Host "[INFO] WoW Password: $WoWPassword"
Write-Host "[INFO] WoW Executable Path: $WOW_PATH"

# Log the start of the script execution
Write-Host "[INFO] PowerShell script started."

# Decrypt the username and password using the DPAPI Decrypt-Password function
$username = $WoWUsername
$password = Decrypt-Password -encryptedPassword $WoWPassword

# Output the decrypted credentials
Write-Host "`nUsername: $username"
#Write-Host "Decrypted Password: $password"

# Log the start of WoW launch
Write-Host "[INFO] Starting World of Warcraft..."

# Launch World of Warcraft using the variable for the executable path
Start-Process $WOW_PATH

# Loop to check if any WoW process (WowClassic.exe, WowRetail.exe, etc.) is running
Write-Host "[INFO] Checking if World of Warcraft is running..."

# Loop to check for WoW processes
while ($true) {
    # Check if WowClassic.exe is running
    $wowClassicRunning = Get-Process | Where-Object { $_.Name -eq "WowClassic" }
    if ($wowClassicRunning) {
        Write-Host "[INFO] WoW process WowClassic.exe is running."
        break
    }

    # Check if WowRetail.exe is running
    $wowRetailRunning = Get-Process | Where-Object { $_.Name -eq "WowRetail" }
    if ($wowRetailRunning) {
        Write-Host "[INFO] WoW process WowRetail.exe is running."
        break
    }

    # Check if any Wow*.exe process is running
    $wowRunning = Get-Process | Where-Object { $_.Name -like "Wow*" }
    if ($wowRunning) {
        Write-Host "[INFO] WoW process Wow*.exe is running."
        break
    }

    # If no WoW process found, wait and check again
    Write-Host "[INFO] WoW is not running. Waiting for 5 seconds before checking again..."
    Start-Sleep -Seconds 5
}

# Log the username and password to send
Write-Host "[INFO] Sending username and password to WoW..."

# Call the sendkeys.js script using cscript.exe and pass the decrypted username and password
if ($ECHO_OUTPUT -eq 1) {
    Write-Host "[INFO] Echo mode enabled, sending with verbose logging."
    Start-Process "C:\Windows\System32\cscript.exe" -ArgumentList "//nologo", "C:\Users\Jo\Documents\Wow_Credential_Filler\sendkeys.js", $username, $password, $ECHO_OUTPUT
} else {
    Write-Host "[INFO] Echo mode disabled, sending without verbose logging."
    Start-Process "C:\Windows\System32\cscript.exe" -ArgumentList "//nologo", "C:\Users\Jo\Documents\Wow_Credential_Filler\sendkeys.js", $username, $password, 0
}

# Log completion of PowerShell script
Write-Host "[INFO] PowerShell script completed. Checking for errors..."

Start-Sleep -Seconds 7

