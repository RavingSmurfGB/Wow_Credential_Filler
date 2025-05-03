var WshShell = WScript.CreateObject("WScript.Shell");

// Get arguments
var username = WScript.Arguments(0);
var password = WScript.Arguments(1);
var echoOutput = WScript.Arguments(2);

// Optional debug output
function log(msg) {
    if (echoOutput == 1) {
        WScript.Echo(msg);
    }
}

// Ensure text was passed
if (!username || !password) {
    log("No username or password provided to sendkeys.js.");
    WScript.Quit(1);
}

// Function to ensure WoW is focused
function ensureFocus() {
    var maxTries = 25;
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
