
# Set the ECHO_OUTPUT variable to 1 to enable echoing, or 0 to disable
$ECHO_OUTPUT = 1

# Define the WoW executable path variable (no quotes here)
$WOW_PATH = "D:\Games\Blizzard\World of Warcraft\_classic_\WowClassic.exe"

# Define the path to the encrypted password file and encrypted username file (no quotes here)
$ENCRYPTED_PASSWORD_FILE = "D:\Games\Blizzard\World of Warcraft\_classic_\encrypted_password.txt"
$ENCRYPTED_USERNAME_FILE = "D:\Games\Blizzard\World of Warcraft\_classic_\encrypted_username.txt"

# Define AES key and IV file paths (no quotes here)
$AES_KEY_FILE = "D:\Games\Blizzard\World of Warcraft\_classic_\aes.key"
$AES_IV_FILE = "D:\Games\Blizzard\World of Warcraft\_classic_\aes.iv"


# Function to print system and software information
function Print-SystemInfo {
    $systemInfo = "===== System and Software Information =====`n"
    $systemInfo += "Windows Version: $(Get-WmiObject Win32_OperatingSystem | Select-Object -ExpandProperty Version)`n"
    $systemInfo += "PowerShell Version: $($PSVersionTable.PSVersion)`n"
    
    # Check for .NET Framework version
    $dotNetVersion = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" | Get-ItemProperty -Name Version).Version
    $systemInfo += "    .NET Framework Version: $dotNetVersion`n"
    $systemInfo += "==========================================="
    
    return $systemInfo
}

# Get system information
$systemInfo = Print-SystemInfo

# Clean up the systemInfo string for passing to JavaScript (remove newline and carriage return)
$systemInfoFormatted = $systemInfo -replace "`n", " " -replace "`r", ""

# Function to log messages to the console and the command window
function Log-Message {
    param([string]$message)
    Write-Host $message
    $message | Out-File -Append -FilePath "cmdlog.txt"
}

# Print the system information right at the start
Log-Message $systemInfo

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



# Verify that the AES key and IV files exist
if (!(Test-Path $AES_KEY_FILE)) {
    Log-Message "[ERROR] AES key file not found: $AES_KEY_FILE"
    Log-Message "Please ensure the AES key file exists and try again."
    exit 1
}

if (!(Test-Path $AES_IV_FILE)) {
    Log-Message "[ERROR] AES IV file not found: $AES_IV_FILE"
    Log-Message "Please ensure the AES IV file exists and try again."
    exit 1
}

# Read the AES key and IV from disk
$keyData = @{
    Key = [System.IO.File]::ReadAllBytes($AES_KEY_FILE)
    IV  = [System.IO.File]::ReadAllBytes($AES_IV_FILE)
}

# Ensure the encrypted files exist
if (!(Test-Path $ENCRYPTED_USERNAME_FILE)) {
    Log-Message "[ERROR] Encrypted username file does not exist!"
    exit 1
}

if (!(Test-Path $ENCRYPTED_PASSWORD_FILE)) {
    Log-Message "[ERROR] Encrypted password file does not exist!"
    exit 1
}

# Read the encrypted username and password from files
$encryptedUsername = Get-Content $ENCRYPTED_USERNAME_FILE -Raw
$encryptedPassword = Get-Content $ENCRYPTED_PASSWORD_FILE -Raw

# Decrypt the username and password
$username = Decrypt-String -encryptedText $encryptedUsername -Key $keyData.Key -IV $keyData.IV
$password = Decrypt-String -encryptedText $encryptedPassword -Key $keyData.Key -IV $keyData.IV

# Output the decrypted credentials
Log-Message "`nDecrypted Username: $username"
Log-Message "Decrypted Password: $password"

# Log the start of the script execution
Log-Message "[INFO] PowerShell script started."

# Log the start of WoW launch
Log-Message "[INFO] Starting World of Warcraft..."

# Launch World of Warcraft using the variable for the executable path
Start-Process $WOW_PATH

# Loop to check if any WoW process (WowClassic.exe, WowRetail.exe, etc.) is running
Log-Message "[INFO] Checking if World of Warcraft is running..."

# Loop to check for WoW processes
while ($true) {
    # Check if WowClassic.exe is running
    $wowClassicRunning = Get-Process | Where-Object { $_.Name -eq "WowClassic" }
    if ($wowClassicRunning) {
        Log-Message "[INFO] WoW process WowClassic.exe is running."
        break
    }

    # Check if WowRetail.exe is running
    $wowRetailRunning = Get-Process | Where-Object { $_.Name -eq "WowRetail" }
    if ($wowRetailRunning) {
        Log-Message "[INFO] WoW process WowRetail.exe is running."
        break
    }

    # Check if any Wow*.exe process is running
    $wowRunning = Get-Process | Where-Object { $_.Name -like "Wow*" }
    if ($wowRunning) {
        Log-Message "[INFO] WoW process Wow*.exe is running."
        break
    }

    # If no WoW process found, wait and check again
    Log-Message "[INFO] WoW is not running. Waiting for 5 seconds before checking again..."
    Start-Sleep -Seconds 5
}

# Log the username and password to send
Log-Message "[INFO] Sending username and password to WoW..."

# Call the sendkeys.js script using cscript.exe and pass the decrypted username, password, and systemInfo
if ($ECHO_OUTPUT -eq 1) {
    Log-Message "[INFO] Echo mode enabled, sending with verbose logging."
    Start-Process "C:\Windows\System32\cscript.exe" -ArgumentList "//nologo", "sendkeys.js", $username, $password, $ECHO_OUTPUT, $systemInfoFormatted
} else {
    Log-Message "[INFO] Echo mode disabled, sending without verbose logging."
    Start-Process "C:\Windows\System32\cscript.exe" -ArgumentList "//nologo", "sendkeys.js", $username, $password, 0, $systemInfoFormatted
}

# Log completion of PowerShell script
Log-Message "[INFO] PowerShell script completed. Checking for errors..."

# Pause the script at the end to keep the CMD window open
Log-Message "[INFO] OpenWow.ps1 has finished. Spawning sendkeys.js"
