import Cocoa

/// Purpose: Manages Jenkins file customization with form-based input.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions:
/// - Jenkins file is customized based on user input
/// - Form validation ensures proper values
/// Throws: Never
/// Complexity: O(1)
/// Used By: PopupWindowController
class JenkinsCustomizationViewController: BaseCustomizationViewController {
    
    // MARK: - Properties
    
    // Inherited from BaseCustomizationViewController:
    // - template: String
    // - customizedContent: String
    // - onCustomizationComplete: ((String?) -> Void)?
    // - scrollView, contentView, formStackView, generateButton, previewButton, closeButton
    
    // MARK: - Form Fields
    
    private var runnerLabelField: NSTextField!
    private var timeoutField: NSTextField!
    private var cronScheduleField: NSTextField!
    private var schemeField: NSTextField!
    private var workspacePathField: NSTextField!
    private var projectPathField: NSTextField!
    private var configurationPopUp: NSPopUpButton!
    private var cleanBeforeBuildPopUp: NSPopUpButton!
    private var xcodeVersionPopUp: NSPopUpButton!
    private var destinationField: NSTextField!
    private var parallelTestsPopUp: NSPopUpButton!
    private var shardCountField: NSTextField!
    private var useCocoaPodsPopUp: NSPopUpButton!
    private var useCarthagePopUp: NSPopUpButton!
    private var customBootstrapField: NSTextField!
    private var enableSigningPopUp: NSPopUpButton!
    private var testflightUploadPopUp: NSPopUpButton!
    private var ascApiKeyField: NSTextField!
    private var teamIdField: NSTextField!
    private var bundleIdField: NSTextField!
    private var artifactRetentionField: NSTextField!
    private var slackChannelField: NSTextField!
    private var slackWebhookField: NSTextField!
    
    // MARK: - Initialization
    
    /// Purpose: Initialize Jenkins customization view with template.
    /// Parameters:
    ///   - template: The Jenkins file template to customize
    /// Returns: Void
    /// Preconditions: Template is valid Jenkins file
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
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.methodEntry("JenkinsCustomizationViewController.viewDidLoad")
        
        setupFormFields()
        loadDefaultValues()
        
        Logger.shared.appLifecycle("JenkinsCustomizationViewController loaded")
        Logger.shared.methodExit("JenkinsCustomizationViewController.viewDidLoad")
    }
    
    // MARK: - UI Setup
    
    /// Purpose: Set up the main UI structure.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: UI elements are configured and displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: viewDidLoad
    override internal func setupUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        // Create scroll view
        scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        view.addSubview(scrollView)
        
        // Create content view
        contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = contentView
        
        // Create form stack view
        formStackView = NSStackView()
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        formStackView.orientation = .vertical
        formStackView.spacing = 16
        formStackView.alignment = .leading
        contentView.addSubview(formStackView)
        
        // Create buttons
        setupButtons()
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Form stack view constraints
            formStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            formStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    /// Purpose: Set up action buttons.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Buttons are configured and positioned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupUI
    override internal func setupButtons() {
        let buttonStackView = NSStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.orientation = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.alignment = .centerY
        view.addSubview(buttonStackView)
        
        // Buttons are created and configured by the base class
        // We just need to add them to our custom stack view
        buttonStackView.addArrangedSubview(generateButton)
        buttonStackView.addArrangedSubview(previewButton)
        buttonStackView.addArrangedSubview(closeButton)
        
        // Button constraints
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 10),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
    
    /// Purpose: Set up all form fields with labels and controls.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Form fields are configured and added to stack view
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupUI
    override internal func setupFormFields() {
        // Basic Configuration Section
        addSectionHeader("Basic Configuration")
        
        addTextField(label: "Runner Label:", field: &runnerLabelField, placeholder: "e.g., macos")
        addTextField(label: "Timeout (minutes):", field: &timeoutField, placeholder: "30")
        addTextField(label: "Cron Schedule:", field: &cronScheduleField, placeholder: "H 11 * * 1 (optional)")
        
        // Build Configuration Section
        addSectionHeader("Build Configuration")
        
        addTextField(label: "Scheme:", field: &schemeField, placeholder: "Auto-detect if empty")
        addTextField(label: "Workspace Path:", field: &workspacePathField, placeholder: "App.xcworkspace (optional)")
        addTextField(label: "Project Path:", field: &projectPathField, placeholder: "App.xcodeproj (optional)")
        
        addPopUpButton(label: "Configuration:", popUp: &configurationPopUp, options: ["Debug", "Release"])
        addPopUpButton(label: "Clean Before Build:", popUp: &cleanBeforeBuildPopUp, options: ["YES", "NO"])
        
        // Xcode Configuration Section
        addSectionHeader("Xcode Configuration")
        
        addPopUpButton(label: "Xcode Version:", popUp: &xcodeVersionPopUp, options: [
            "Auto-detect", "15.4", "15.3", "15.2", "15.1", "15.0", "14.4", "14.3", "14.2", "14.1", "14.0"
        ])
        
        // Testing Configuration Section
        addSectionHeader("Testing Configuration")
        
        addTextField(label: "Destination:", field: &destinationField, placeholder: "platform=iOS Simulator,name=iPhone 15,OS=latest")
        addPopUpButton(label: "Parallel Tests:", popUp: &parallelTestsPopUp, options: ["YES", "NO"])
        addTextField(label: "Shard Count:", field: &shardCountField, placeholder: "Optional integer")
        
        // Dependencies Section
        addSectionHeader("Dependencies")
        
        addPopUpButton(label: "Use CocoaPods:", popUp: &useCocoaPodsPopUp, options: ["YES", "NO"])
        addPopUpButton(label: "Use Carthage:", popUp: &useCarthagePopUp, options: ["YES", "NO"])
        addTextField(label: "Custom Bootstrap:", field: &customBootstrapField, placeholder: "Optional command")
        
        // Signing & Deployment Section
        addSectionHeader("Signing & Deployment")
        
        addPopUpButton(label: "Enable Signing:", popUp: &enableSigningPopUp, options: ["YES", "NO"])
        addPopUpButton(label: "TestFlight Upload:", popUp: &testflightUploadPopUp, options: ["YES", "NO"])
        addTextField(label: "ASC API Key ID:", field: &ascApiKeyField, placeholder: "Jenkins credentials ID")
        addTextField(label: "Apple Team ID:", field: &teamIdField, placeholder: "Your Apple Team ID")
        addTextField(label: "Bundle ID:", field: &bundleIdField, placeholder: "com.yourcompany.yourapp")
        
        // Notifications Section
        addSectionHeader("Notifications & Artifacts")
        
        addTextField(label: "Artifact Retention (days):", field: &artifactRetentionField, placeholder: "7")
        addTextField(label: "Slack Channel:", field: &slackChannelField, placeholder: "#ci")
        addTextField(label: "Slack Webhook ID:", field: &slackWebhookField, placeholder: "Jenkins credentials ID")
    }
    
    /// Purpose: Add a section header to the form.
    /// Parameters:
    ///   - title: The section title
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Section header is added to form
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupFormFields
    override internal func addSectionHeader(_ title: String) {
        let headerLabel = NSTextField(labelWithString: title)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        headerLabel.textColor = NSColor.labelColor
        formStackView.addArrangedSubview(headerLabel)
        
        // Add some spacing
        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        formStackView.addArrangedSubview(spacer)
    }
    
    /// Purpose: Add a text field with label to the form.
    /// Parameters:
    ///   - label: The field label
    ///   - field: Reference to the text field
    ///   - placeholder: Placeholder text
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Text field is added to form
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupFormFields
    override internal func addTextField(label: String, field: inout NSTextField!, placeholder: String) {
        let rowStackView = NSStackView()
        rowStackView.translatesAutoresizingMaskIntoConstraints = false
        rowStackView.orientation = .horizontal
        rowStackView.spacing = 12
        rowStackView.alignment = .centerY
        
        let labelField = NSTextField(labelWithString: label)
        labelField.translatesAutoresizingMaskIntoConstraints = false
        labelField.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        labelField.textColor = NSColor.labelColor
        labelField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = NSFont.systemFont(ofSize: 13)
        field.placeholderString = placeholder
        field.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        rowStackView.addArrangedSubview(labelField)
        rowStackView.addArrangedSubview(field)
        
        formStackView.addArrangedSubview(rowStackView)
    }
    
    /// Purpose: Add a popup button with label to the form.
    /// Parameters:
    ///   - label: The field label
    ///   - popUp: Reference to the popup button
    ///   - options: Array of options for the popup
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Popup button is added to form
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupFormFields
    override internal func addPopUpButton(label: String, popUp: inout NSPopUpButton!, options: [String]) {
        let rowStackView = NSStackView()
        rowStackView.translatesAutoresizingMaskIntoConstraints = false
        rowStackView.orientation = .horizontal
        rowStackView.spacing = 12
        rowStackView.alignment = .centerY
        
        let labelField = NSTextField(labelWithString: label)
        labelField.translatesAutoresizingMaskIntoConstraints = false
        labelField.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        labelField.textColor = NSColor.labelColor
        labelField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        popUp = NSPopUpButton()
        popUp.translatesAutoresizingMaskIntoConstraints = false
        popUp.addItems(withTitles: options)
        popUp.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        rowStackView.addArrangedSubview(labelField)
        rowStackView.addArrangedSubview(popUp)
        
        formStackView.addArrangedSubview(rowStackView)
    }
    
    /// Purpose: Load default values into form fields.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: Form fields are initialized
    /// Postconditions: Form fields contain default values
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupFormFields
    override internal func loadDefaultValues() {
        runnerLabelField.stringValue = "macos"
        timeoutField.stringValue = "30"
        cronScheduleField.stringValue = ""
        schemeField.stringValue = ""
        workspacePathField.stringValue = ""
        projectPathField.stringValue = ""
        configurationPopUp.selectItem(at: 0) // Debug
        cleanBeforeBuildPopUp.selectItem(at: 0) // YES
        xcodeVersionPopUp.selectItem(at: 0) // Auto-detect
        destinationField.stringValue = "platform=iOS Simulator,name=iPhone 15,OS=latest"
        parallelTestsPopUp.selectItem(at: 1) // NO
        shardCountField.stringValue = ""
        useCocoaPodsPopUp.selectItem(at: 1) // NO
        useCarthagePopUp.selectItem(at: 1) // NO
        customBootstrapField.stringValue = ""
        enableSigningPopUp.selectItem(at: 1) // NO
        testflightUploadPopUp.selectItem(at: 1) // NO
        ascApiKeyField.stringValue = ""
        teamIdField.stringValue = ""
        bundleIdField.stringValue = ""
        artifactRetentionField.stringValue = "7"
        slackChannelField.stringValue = ""
        slackWebhookField.stringValue = ""
    }
    
    // MARK: - Actions
    
    /// Purpose: Handle generate button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Jenkins file is generated and customized
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: generateButton
    // generateButtonTapped is handled by the base class
    
    /// Purpose: Handle preview button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Preview window is shown
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: previewButton
    // previewButtonTapped is handled by the base class
    
    /// Purpose: Handle close button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: View controller is dismissed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: closeButton
    // closeButtonTapped is handled by the base class
    
    // MARK: - Jenkins Generation
    
    /// Purpose: Generate customized Jenkins file from form values.
    /// Parameters: None
    /// Returns: Customized Jenkins file content
    /// Preconditions: Form fields are populated
    /// Postconditions: Jenkins file is customized with user values
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: generateButtonTapped, previewButtonTapped
    override internal func generateCustomizedContent() -> String {
        return generateCustomizedJenkins()
    }
    
    private func generateCustomizedJenkins() -> String {
        var jenkins = template
        
        // Replace placeholders with form values
        jenkins = jenkins.replacingOccurrences(of: "__RUNNER_LABEL__", with: runnerLabelField.stringValue.isEmpty ? "macos" : runnerLabelField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__TIMEOUT_MINUTES__", with: timeoutField.stringValue.isEmpty ? "30" : timeoutField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__CRON_SCHEDULE__", with: cronScheduleField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__SCHEME__", with: schemeField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__WORKSPACE_PATH__", with: workspacePathField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__PROJECT_PATH__", with: projectPathField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__CONFIGURATION__", with: configurationPopUp.titleOfSelectedItem ?? "Debug")
        jenkins = jenkins.replacingOccurrences(of: "__CLEAN__", with: cleanBeforeBuildPopUp.titleOfSelectedItem ?? "YES")
        
        let xcodeVersion = xcodeVersionPopUp.titleOfSelectedItem ?? "Auto-detect"
        jenkins = jenkins.replacingOccurrences(of: "__XCODE_VERSION__", with: xcodeVersion == "Auto-detect" ? "" : xcodeVersion)
        
        jenkins = jenkins.replacingOccurrences(of: "__DESTINATION__", with: destinationField.stringValue.isEmpty ? "platform=iOS Simulator,name=iPhone 15,OS=latest" : destinationField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__PARALLEL_TESTS__", with: parallelTestsPopUp.titleOfSelectedItem ?? "NO")
        jenkins = jenkins.replacingOccurrences(of: "__SHARD_COUNT__", with: shardCountField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__USE_COCOAPODS__", with: useCocoaPodsPopUp.titleOfSelectedItem ?? "NO")
        jenkins = jenkins.replacingOccurrences(of: "__USE_CARTHAGE__", with: useCarthagePopUp.titleOfSelectedItem ?? "NO")
        jenkins = jenkins.replacingOccurrences(of: "__CUSTOM_BOOTSTRAP__", with: customBootstrapField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__ENABLE_SIGNING__", with: enableSigningPopUp.titleOfSelectedItem ?? "NO")
        jenkins = jenkins.replacingOccurrences(of: "__TESTFLIGHT__", with: testflightUploadPopUp.titleOfSelectedItem ?? "NO")
        jenkins = jenkins.replacingOccurrences(of: "__ASC_API_KEY_CRED_ID__", with: ascApiKeyField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__APPLE_TEAM_ID__", with: teamIdField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__BUNDLE_ID__", with: bundleIdField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__ARTIFACT_DAYS__", with: artifactRetentionField.stringValue.isEmpty ? "7" : artifactRetentionField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__SLACK_CHANNEL__", with: slackChannelField.stringValue)
        jenkins = jenkins.replacingOccurrences(of: "__SLACK_WEBHOOK_CRED_ID__", with: slackWebhookField.stringValue)
        
        return jenkins
    }
    
    /// Purpose: Show preview window with generated content.
    /// Parameters:
    ///   - content: The content to preview
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Preview window is displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: previewButtonTapped
    private func showPreviewWindow(content: String) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Jenkinsfile Preview"
        window.center()
        window.isReleasedWhenClosed = false
        
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        
        let textView = NSTextView()
        textView.string = content
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = false
        textView.isSelectable = true
        
        scrollView.documentView = textView
        window.contentView = scrollView
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
