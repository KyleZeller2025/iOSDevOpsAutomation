import Cocoa

/// Purpose: Main entry point for the macOS application.
/// Parameters: None
/// Returns: Never
/// Preconditions: None
/// Postconditions: Application is launched and running
/// Throws: Never
/// Complexity: O(1)
/// Used By: macOS app lifecycle
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
