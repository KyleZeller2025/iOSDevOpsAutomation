import Cocoa

/// Purpose: Manages Travis CI pipeline customization with form-based input.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions:
/// - Travis CI pipeline is customized based on user input
/// - Form validation ensures proper values
/// Throws: Never
/// Complexity: O(1)
/// Used By: PopupWindowController
class TravisCICustomizationViewController: BaseCustomizationViewController {
    
    // MARK: - Form Fields
    
    private var xcodeVersionPopUp: NSPopUpButton!
    private var schemeField: NSTextField!
    private var configurationPopUp: NSPopUpButton!
    private var destinationField: NSTextField!
    private var parallelTestsPopUp: NSPopUpButton!
    private var useCocoaPodsPopUp: NSPopUpButton!
    private var useCarthagePopUp: NSPopUpButton!
    private var enableSigningPopUp: NSPopUpButton!
    private var testflightUploadPopUp: NSPopUpButton!
    private var teamIdField: NSTextField!
    private var bundleIdField: NSTextField!
    private var artifactRetentionField: NSTextField!
    private var osPopUp: NSPopUpButton!
    private var languagePopUp: NSPopUpButton!
    
    // MARK: - Initialization
    
    /// Purpose: Initialize Travis CI customization view with template.
    /// Parameters:
    ///   - template: The Travis CI template to customize
    /// Returns: Void
    /// Preconditions: Template is valid YAML pipeline
    /// Postconditions: View controller is ready for customization
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: PopupWindowController
    override init(template: String) {
        super.init(template: template)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Form Setup
    
    override func setupFormFields() {
        // Environment Configuration Section
        addSectionHeader("Environment Configuration")
        
        addPopUpButton(label: "OS:", popUp: &osPopUp, options: [
            "osx", "linux"
        ])
        addPopUpButton(label: "Language:", popUp: &languagePopUp, options: [
            "objective-c", "swift", "ruby", "python"
        ])
        addPopUpButton(label: "Xcode Version:", popUp: &xcodeVersionPopUp, options: [
            "15.4", "15.3", "15.2", "15.1", "15.0", "14.4", "14.3", "14.2", "14.1", "14.0"
        ])
        
        // Build Configuration Section
        addSectionHeader("Build Configuration")
        
        addTextField(label: "Scheme:", field: &schemeField, placeholder: "Auto-detect if empty")
        addPopUpButton(label: "Configuration:", popUp: &configurationPopUp, options: ["Debug", "Release"])
        addTextField(label: "Destination:", field: &destinationField, placeholder: "platform=iOS Simulator,name=iPhone 15,OS=latest")
        addPopUpButton(label: "Parallel Tests:", popUp: &parallelTestsPopUp, options: ["YES", "NO"])
        
        // Dependencies Section
        addSectionHeader("Dependencies")
        
        addPopUpButton(label: "Use CocoaPods:", popUp: &useCocoaPodsPopUp, options: ["YES", "NO"])
        addPopUpButton(label: "Use Carthage:", popUp: &useCarthagePopUp, options: ["YES", "NO"])
        
        // Signing & Deployment Section
        addSectionHeader("Signing & Deployment")
        
        addPopUpButton(label: "Enable Signing:", popUp: &enableSigningPopUp, options: ["YES", "NO"])
        addPopUpButton(label: "TestFlight Upload:", popUp: &testflightUploadPopUp, options: ["YES", "NO"])
        addTextField(label: "Apple Team ID:", field: &teamIdField, placeholder: "Your Apple Team ID")
        addTextField(label: "Bundle ID:", field: &bundleIdField, placeholder: "com.yourcompany.yourapp")
        
        // Artifacts Section
        addSectionHeader("Artifacts")
        
        addTextField(label: "Retention Days:", field: &artifactRetentionField, placeholder: "30")
    }
    
    override func loadDefaultValues() {
        osPopUp.selectItem(at: 0) // osx
        languagePopUp.selectItem(at: 1) // swift
        xcodeVersionPopUp.selectItem(at: 0) // 15.4
        schemeField.stringValue = ""
        configurationPopUp.selectItem(at: 0) // Debug
        destinationField.stringValue = "platform=iOS Simulator,name=iPhone 15,OS=latest"
        parallelTestsPopUp.selectItem(at: 1) // NO
        useCocoaPodsPopUp.selectItem(at: 1) // NO
        useCarthagePopUp.selectItem(at: 1) // NO
        enableSigningPopUp.selectItem(at: 1) // NO
        testflightUploadPopUp.selectItem(at: 1) // NO
        teamIdField.stringValue = ""
        bundleIdField.stringValue = ""
        artifactRetentionField.stringValue = "30"
    }
    
    override func generateCustomizedContent() -> String {
        var pipeline = template
        
        // Replace placeholders with form values
        pipeline = pipeline.replacingOccurrences(of: "__OS__", with: osPopUp.titleOfSelectedItem ?? "osx")
        pipeline = pipeline.replacingOccurrences(of: "__LANGUAGE__", with: languagePopUp.titleOfSelectedItem ?? "swift")
        pipeline = pipeline.replacingOccurrences(of: "__XCODE_VERSION__", with: xcodeVersionPopUp.titleOfSelectedItem ?? "15.4")
        pipeline = pipeline.replacingOccurrences(of: "__SCHEME__", with: schemeField.stringValue)
        pipeline = pipeline.replacingOccurrences(of: "__CONFIGURATION__", with: configurationPopUp.titleOfSelectedItem ?? "Debug")
        pipeline = pipeline.replacingOccurrences(of: "__DESTINATION__", with: destinationField.stringValue.isEmpty ? "platform=iOS Simulator,name=iPhone 15,OS=latest" : destinationField.stringValue)
        pipeline = pipeline.replacingOccurrences(of: "__PARALLEL_TESTS__", with: parallelTestsPopUp.titleOfSelectedItem ?? "NO")
        pipeline = pipeline.replacingOccurrences(of: "__USE_COCOAPODS__", with: useCocoaPodsPopUp.titleOfSelectedItem ?? "NO")
        pipeline = pipeline.replacingOccurrences(of: "__USE_CARTHAGE__", with: useCarthagePopUp.titleOfSelectedItem ?? "NO")
        pipeline = pipeline.replacingOccurrences(of: "__ENABLE_SIGNING__", with: enableSigningPopUp.titleOfSelectedItem ?? "NO")
        pipeline = pipeline.replacingOccurrences(of: "__TESTFLIGHT_UPLOAD__", with: testflightUploadPopUp.titleOfSelectedItem ?? "NO")
        pipeline = pipeline.replacingOccurrences(of: "__TEAM_ID__", with: teamIdField.stringValue)
        pipeline = pipeline.replacingOccurrences(of: "__BUNDLE_ID__", with: bundleIdField.stringValue)
        pipeline = pipeline.replacingOccurrences(of: "__RETENTION_DAYS__", with: artifactRetentionField.stringValue.isEmpty ? "30" : artifactRetentionField.stringValue)
        
        return pipeline
    }
}
