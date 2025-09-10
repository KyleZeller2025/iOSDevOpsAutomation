import Cocoa

/// Purpose: Manages GitLab CI pipeline customization with form-based input.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions:
/// - GitLab CI pipeline is customized based on user input
/// - Form validation ensures proper values
/// Throws: Never
/// Complexity: O(1)
/// Used By: PopupWindowController
class GitLabCICustomizationViewController: BaseCustomizationViewController {
    
    // MARK: - Form Fields
    
    private var pipelineNameField: NSTextField!
    private var triggerBranchesField: NSTextField!
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
    private var cacheStrategyPopUp: NSPopUpButton!
    
    // MARK: - Initialization
    
    /// Purpose: Initialize GitLab CI customization view with template.
    /// Parameters:
    ///   - template: The GitLab CI pipeline template to customize
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
        // Pipeline Configuration Section
        addSectionHeader("Pipeline Configuration")
        
        addTextField(label: "Pipeline Name:", field: &pipelineNameField, placeholder: "iOS Pipeline")
        addTextField(label: "Trigger Branches:", field: &triggerBranchesField, placeholder: "main, develop")
        addPopUpButton(label: "Cache Strategy:", popUp: &cacheStrategyPopUp, options: [
            "None", "Basic", "Advanced", "Custom"
        ])
        
        // Build Configuration Section
        addSectionHeader("Build Configuration")
        
        addPopUpButton(label: "Xcode Version:", popUp: &xcodeVersionPopUp, options: [
            "15.4", "15.3", "15.2", "15.1", "15.0", "14.4", "14.3", "14.2", "14.1", "14.0"
        ])
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
        pipelineNameField.stringValue = "iOS Pipeline"
        triggerBranchesField.stringValue = "main"
        cacheStrategyPopUp.selectItem(at: 1) // Basic
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
        pipeline = pipeline.replacingOccurrences(of: "__PIPELINE_NAME__", with: pipelineNameField.stringValue.isEmpty ? "iOS Pipeline" : pipelineNameField.stringValue)
        pipeline = pipeline.replacingOccurrences(of: "__TRIGGER_BRANCHES__", with: triggerBranchesField.stringValue.isEmpty ? "main" : triggerBranchesField.stringValue)
        pipeline = pipeline.replacingOccurrences(of: "__CACHE_STRATEGY__", with: cacheStrategyPopUp.titleOfSelectedItem ?? "Basic")
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
