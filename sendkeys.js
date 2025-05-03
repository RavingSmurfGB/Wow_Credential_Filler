var WshShell = WScript.CreateObject("WScript.Shell");
var fso = new ActiveXObject("Scripting.FileSystemObject");

// Log file path
var logFile = "C:\\Users\\Jo\\AppData\\Roaming\\Wow_Credential_Filler\\sendkeys_log.txt";  // Specify the log file name

// Enable logging to log file (set to true to enable) LOGGING DOES NOT WORK CURRENTLY
var enable_log_file = false;  // Set this to `true` to enable logging to file, `false` to disable

// Ensure log file exists, create it if it doesn't
function ensureLogFileExists() {
    try {
        if (enable_log_file) {
            // Check if the file exists, create it if not
            if (!fso.FileExists(logFile)) {
                var log = fso.CreateTextFile(logFile, true);  // Create the file if it doesn't exist
                log.Close();
                log("Log file created: " + logFile);
            }
        }
    } catch (e) {
        WScript.Echo("Error checking or creating log file: " + e.message);
    }
}

// Get arguments
var username = WScript.Arguments(0);
var password = WScript.Arguments(1);
var echoOutput = WScript.Arguments(2);

// Optional debug output
function log(msg) {
    // Log to console if echoOutput is 1
    if (echoOutput == 1) {
        WScript.Echo(msg);
    }

    // Log to file if enable_log_file is true
    if (enable_log_file) {
        try {
            var file = fso.OpenTextFile(logFile, 8, true);  // Open log file in append mode
            file.WriteLine(new Date().toISOString() + " - " + msg);  // Log timestamp with message
            file.Close();
        } catch (e) {
            WScript.Echo("Error writing to log file: " + e.message);
        }
    }
}

// Ensure log file exists (create it if needed)
ensureLogFileExists();

// Log arguments
log("Arguments received:");
log("Username: " + (username ? username : "Not provided"));
//log("Password: " + (password ? password : "Not provided"));
log("echoOutput: " + echoOutput);

// Ensure text was passed
if (!username || !password) {
    log("No username or password provided to sendkeys.js.");
    WScript.Quit(1);
}

// Function to ensure WoW is focused
function ensureFocus() {
    var maxTries = 40;
    var tries = 0;
    var focused = false;

    log("Attempting to focus World of Warcraft window...");

    // Ensure we are trying multiple times to focus the window
    while (tries < maxTries && !focused) {
        focused = WshShell.AppActivate("World of Warcraft");
        log("Attempt " + (tries + 1) + ": AppActivate returned " + focused);
        WScript.Sleep(2000);  // Sleep for 2 seconds between attempts for better focus
        tries++;
    }

    return focused;
}

// Try to focus WoW window
if (ensureFocus()) {
    log("WoW window is focused. Sending credentials...");

    WScript.Sleep(3000);  // Wait for UI to be ready (increased wait time)

    log("Typing username: " + username);
    WshShell.SendKeys(username + "{TAB}");

    WScript.Sleep(1000);  // Short pause between fields

    log("Typing password.");
    WshShell.SendKeys(password + "{ENTER}");

    log("Credentials sent successfully.");
} else {
    log("Failed to focus WoW window.");
    WScript.Quit(2);
}

// Optional pause for any final log output
WScript.Sleep(2000);
