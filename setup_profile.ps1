# Function to Encrypt a password using DPAPI
function Encrypt-Password {
    param (
        [string]$password
    )

    # Convert the password to SecureString
    $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

    # Encrypt the SecureString using the Windows DPAPI
    $encryptedPassword = $securePassword | ConvertFrom-SecureString

    return $encryptedPassword
}

# Function to Decrypt a password using DPAPI
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

# Function to ask the user which version of World of Warcraft is being used
function Get-WowVersion {
    Write-Host "`nStep 1: Which version of World of Warcraft would you like to use?"
    Write-Host "    1. Vanilla (Hardcore/Fresh servers)"
    Write-Host "    2. Classic (Wrath or earlier)"
    Write-Host "    3. Retail (Dragonflight)"
    
    while ($true) {
        $choice = Read-Host "Enter 1, 2, or 3"
        switch ($choice) {
            "1" {
                $global:WoWVersion = "Vanilla"
                return "vanilla"
            }
            "2" {
                $global:WoWVersion = "Classic"
                return "classic"
            }
            "3" {
                $global:WoWVersion = "Retail"
                return "retail"
            }
            default {
                Write-Host "❌ Invalid input. Please enter 1, 2, or 3." -ForegroundColor Yellow
            }
        }
    }
}

# Start the World of Warcraft Setup
Write-Host "Welcome to the World of Warcraft Setup"

# Step 1: Select WoW Version using the Get-WowVersion function
$WoWVersionFolder = Get-WowVersion
Write-Host "You selected $WoWVersion version."

# Step 2: Get the World of Warcraft directory (default: C:\Program Files (x86)\World of Warcraft\)
$defaultWoWDirectory = "C:\Program Files (x86)\World of Warcraft"
$WoWDirectory = Read-Host "Confirm your World of Warcraft directory (default: $defaultWoWDirectory)"
if (-not $WoWDirectory) {
    $WoWDirectory = $defaultWoWDirectory
}

# Verify that the World of Warcraft directory exists
if (-not (Test-Path -Path $WoWDirectory)) {
    Write-Host "❌ The directory $WoWDirectory does not exist. Please ensure the path is correct and try again." -ForegroundColor Red
    exit
}

# Step 3: Create the parent directory for storing WoW credentials (Wow_Credential_Filler)
$CredentialFolderPath = "C:\Users\$env:USERNAME\AppData\Roaming\Wow_Credential_Filler"
if (-not (Test-Path -Path $CredentialFolderPath)) {
    New-Item -Path $CredentialFolderPath -ItemType Directory | Out-Null
}

# Step 4: Create the directory for the selected WoW version (if not already created)
$ConfigDirectory = Join-Path -Path $CredentialFolderPath -ChildPath $WoWVersionFolder
if (-not (Test-Path -Path $ConfigDirectory)) {
    New-Item -Path $ConfigDirectory -ItemType Directory | Out-Null
}

# Step 5: Check if the config.txt or aes.key or aes.iv files already exist
$configFilePath = Join-Path -Path $ConfigDirectory -ChildPath "config.txt"
$aesKeyFilePath = Join-Path -Path $ConfigDirectory -ChildPath "aes.key"
$aesIVFilePath = Join-Path -Path $ConfigDirectory -ChildPath "aes.iv"

# Use separate Test-Path checks for each file
if ((Test-Path $configFilePath) -or (Test-Path $aesKeyFilePath) -or (Test-Path $aesIVFilePath)) {
    Write-Host "⚠️ It looks like there is already a profile for this WoW version."
    $overwrite = Read-Host "Would you like to overwrite the existing files? (Y/N)"
    if ($overwrite -ne "Y") {
        Write-Host "Exiting the script without overwriting files."
        exit
    }
}

# Step 6: Ask the user for their BattleNet Username
$WoWUsername = Read-Host "Enter your BattleNet Username"

# Step 7: Ask the user for their BattleNet Password
$WoWPassword = Read-Host "Enter your BattleNet Password"

# Step 8: Encrypt the password and save it
$encryptedPassword = Encrypt-Password -password $WoWPassword

# Step 9: Save AES Key and IV to the corresponding directory
$AESKey = [System.Text.Encoding]::UTF8.GetBytes("mysecretkey12345")
$AESIV = [System.Text.Encoding]::UTF8.GetBytes("1234567890123456")
$AESKey | Out-File -FilePath $aesKeyFilePath
$AESIV | Out-File -FilePath $aesIVFilePath

Write-Host "AES Key file saved at: $aesKeyFilePath"
Write-Host "AES IV file saved at: $aesIVFilePath"

# Step 10: Create and save the config.txt file in the corresponding directory
$configContent = @"
WoWVersion: $WoWVersion
WoWDirectory: $WoWDirectory
WoWUsername: $WoWUsername
WoWPassword: $encryptedPassword
"@
$configContent | Out-File -FilePath $configFilePath

Write-Host "Your credentials have been saved and encrypted successfully in $ConfigDirectory."

# Step 11: Load and decrypt the password from the config file (for testing)
Write-Host "Loading and decrypting the password from the config file..."

if (Test-Path $configFilePath) {
    $LoadedConfig = Get-Content -Path $configFilePath

    # Extract the encrypted password (assumes the password is on the line starting with 'WoWPassword:')
    $EncryptedPasswordFromFile = ($LoadedConfig | Where-Object { $_ -match 'WoWPassword: ' }) -replace 'WoWPassword: ', ''

    # Decrypt the password using the function we defined
    $DecryptedPasswordFromConfig = Decrypt-Password -encryptedPassword $EncryptedPasswordFromFile

    # Check if the decrypted password matches the original WoWPassword
    if ($DecryptedPasswordFromConfig -eq $WoWPassword) {
        Write-Host "✅ The credentials have been saved correctly."
    } else {
        Write-Host "❌ There was an error decrypting the password. Please try again."
    }
} else {
    Write-Host "Config file not found at: $configFilePath"
}

# Step 12: Ask the user what they want to name the shortcut
Write-Host "`nStep 12: What would you like to name the shortcut? (e.g., hardcore, launch_cataclysm)"
Write-Host "We recommend a name like 'hardcore', 'launch_cataclysm', or any specific name related to your WoW setup."

$shortcutName = Read-Host "Enter shortcut name"
if (-not $shortcutName) {
    Write-Host "❌ Shortcut name cannot be empty. Exiting."
    exit
}

# Define the shortcut target path and arguments
$OpenWowPath = "C:\Program Files\Wow_Credential_Filler\OpenWow.ps1"
$configFilePath = Join-Path -Path $ConfigDirectory -ChildPath ""

# Validate if OpenWow.ps1 exists
if (-not (Test-Path -Path $OpenWowPath)) {
    Write-Host "❌ OpenWow.ps1 not found at $OpenWowPath. Please ensure the file exists before proceeding."
    exit
}

# Define where to save the shortcut (e.g., on the user's desktop)
$desktopPath = [System.Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path -Path $desktopPath -ChildPath "$shortcutName.lnk"

# Create a new WScript.Shell COM object to create the shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)

# Set the target of the shortcut
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$OpenWowPath`" `"$configFilePath`""

# Optionally, set the shortcut icon (using a default icon or a custom one)
$Shortcut.IconLocation = "C:\Program Files (x86)\World of Warcraft\_retail_\wow.exe,0"  # Use WoW executable icon

# Save the shortcut
$Shortcut.Save()

Write-Host "✅ Shortcut created successfully: $shortcutPath"
Write-Host "You can now launch World of Warcraft using the shortcut '$shortcutName' on your Desktop."

# Optional: Open the created shortcut to test if it works
# Start-Process $shortcutPath
