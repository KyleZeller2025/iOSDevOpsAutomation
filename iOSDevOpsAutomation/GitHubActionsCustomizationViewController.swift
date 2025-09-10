import Cocoa

/// Purpose: Manages GitHub Actions workflow customization with form-based input.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions:
/// - GitHub Actions workflow is customized based on user input
/// - Form validation ensures proper values
/// Throws: Never
/// Complexity: O(1)
/// Used By: PopupWindowController
class GitHubActionsCustomizationViewController: BaseCustomizationViewController {
    
    // MARK: - Form Fields
    
    private var workflowNameField: NSTextField!
    private var triggerEventsPopUp: NSPopUpButton!
    private var branchesField: NSTextField!
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
    
    // MARK: - Initialization
    
    /// Purpose: Initialize GitHub Actions customization view with template.
    /// Parameters:
    ///   - template: The GitHub Actions workflow template to customize
    /// Returns: Void
    /// Preconditions: Template is valid YAML workflow
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
        // Workflow Configuration Section
        addSectionHeader("Workflow Configuration")
        
        addTextField(label: "Workflow Name:", field: &workflowNameField, placeholder: "iOS CI")
        addPopUpButton(label: "Trigger Events:", popUp: &triggerEventsPopUp, options: [
            "push", "pull_request", "push + pull_request", "schedule", "workflow_dispatch"
        ])
        addTextField(label: "Branches:", field: &branchesField, placeholder: "main, develop")
        
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
        workflowNameField.stringValue = "iOS CI"
        triggerEventsPopUp.selectItem(at: 1) // pull_request
        branchesField.stringValue = "main"
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
        var workflow = template
        
        // Replace placeholders with form values
        workflow = workflow.replacingOccurrences(of: "__WORKFLOW_NAME__", with: workflowNameField.stringValue.isEmpty ? "iOS CI" : workflowNameField.stringValue)
        workflow = workflow.replacingOccurrences(of: "__TRIGGER_EVENTS__", with: getTriggerEvents())
        workflow = workflow.replacingOccurrences(of: "__BRANCHES__", with: branchesField.stringValue.isEmpty ? "main" : branchesField.stringValue)
        workflow = workflow.replacingOccurrences(of: "__XCODE_VERSION__", with: xcodeVersionPopUp.titleOfSelectedItem ?? "15.4")
        workflow = workflow.replacingOccurrences(of: "__SCHEME__", with: schemeField.stringValue)
        workflow = workflow.replacingOccurrences(of: "__CONFIGURATION__", with: configurationPopUp.titleOfSelectedItem ?? "Debug")
        workflow = workflow.replacingOccurrences(of: "__DESTINATION__", with: destinationField.stringValue.isEmpty ? "platform=iOS Simulator,name=iPhone 15,OS=latest" : destinationField.stringValue)
        workflow = workflow.replacingOccurrences(of: "__PARALLEL_TESTS__", with: parallelTestsPopUp.titleOfSelectedItem ?? "NO")
        workflow = workflow.replacingOccurrences(of: "__USE_COCOAPODS__", with: useCocoaPodsPopUp.titleOfSelectedItem ?? "NO")
        workflow = workflow.replacingOccurrences(of: "__USE_CARTHAGE__", with: useCarthagePopUp.titleOfSelectedItem ?? "NO")
        workflow = workflow.replacingOccurrences(of: "__ENABLE_SIGNING__", with: enableSigningPopUp.titleOfSelectedItem ?? "NO")
        workflow = workflow.replacingOccurrences(of: "__TESTFLIGHT_UPLOAD__", with: testflightUploadPopUp.titleOfSelectedItem ?? "NO")
        workflow = workflow.replacingOccurrences(of: "__TEAM_ID__", with: teamIdField.stringValue)
        workflow = workflow.replacingOccurrences(of: "__BUNDLE_ID__", with: bundleIdField.stringValue)
        workflow = workflow.replacingOccurrences(of: "__RETENTION_DAYS__", with: artifactRetentionField.stringValue.isEmpty ? "30" : artifactRetentionField.stringValue)
        
        return workflow
    }
    
    // MARK: - Helper Methods
    
    /// Purpose: Get trigger events based on selection.
    /// Parameters: None
    /// Returns: Formatted trigger events string
    /// Preconditions: None
    /// Postconditions: Trigger events are formatted for YAML
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: generateCustomizedContent
    private func getTriggerEvents() -> String {
        let selected = triggerEventsPopUp.titleOfSelectedItem ?? "pull_request"
        switch selected {
        case "push":
            return "push:"
        case "pull_request":
            return "pull_request:"
        case "push + pull_request":
            return """
            push:
            pull_request:
            """
        case "schedule":
            return "schedule:"
        case "workflow_dispatch":
            return "workflow_dispatch:"
        default:
            return "pull_request:"
        }
    }
}
