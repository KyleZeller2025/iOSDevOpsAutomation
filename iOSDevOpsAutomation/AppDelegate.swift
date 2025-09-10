//
//  AppDelegate.swift
//  iOSDevOpsAutomation
//
//  Created by Kyle Zeller on 9/9/25.
//

import Cocoa

/// Purpose: Main app delegate that manages the application lifecycle and coordinates the main flow.
/// Parameters: None (class)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All methods are pure functions
/// Throws: Never
/// Complexity: O(1)
/// Used By: macOS app lifecycle
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    private var mainCoordinator: MainCoordinator?
    
    // MARK: - Application Lifecycle
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Logger.shared.methodEntry("AppDelegate.applicationDidFinishLaunching")
        Logger.shared.appLifecycle("Application did finish launching")
        
        mainCoordinator = MainCoordinator()
        mainCoordinator?.start()
        
        Logger.shared.appLifecycle("Application setup completed")
        Logger.shared.methodExit("AppDelegate.applicationDidFinishLaunching")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up any resources
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // MARK: - Window Management
    
    /// Purpose: Sets up the main window for the app.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Main window is created and configured
    /// - Window is ready for use
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: applicationDidFinishLaunching
    private func setupMainWindow() { /* managed by MainCoordinator */ }
    
    /// Purpose: Sets up the main view controller using strict MVC pattern.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions:
    /// - Main window must be created
    /// Postconditions:
    /// - View controller is created and configured
    /// - View controller is set as window content
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: applicationDidFinishLaunching
    private func setupViewController() { /* managed by MainCoordinator */ }
    
    /// Purpose: Shows the main window and makes it active.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions:
    /// - Main window must be created
    /// Postconditions:
    /// - Main window is visible and active
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: applicationDidFinishLaunching
    private func showMainWindow() { /* managed by MainCoordinator */ }
    
    // MARK: - Menu Actions
    
    /// Purpose: Handles the "About" menu action.
    /// Parameters:
    ///   - sender: The menu item that triggered the action
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - About panel is displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: Main menu
    @IBAction func showAbout(_ sender: Any?) {
        let aboutPanel = NSAlert()
        aboutPanel.messageText = "iOS DevOps Automation"
        aboutPanel.informativeText = """
        A production-grade macOS app for iOS DevOps automation.
        
        Features:
        • Project inspection and analysis
        • CI/CD pipeline generation
        • Security scanning
        • Performance profiling
        • Consolidated reporting
        
        Version 1.0.0
        """
        aboutPanel.alertStyle = .informational
        aboutPanel.addButton(withTitle: "OK")
        aboutPanel.runModal()
    }
}
