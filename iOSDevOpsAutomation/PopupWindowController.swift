import Cocoa

/// Purpose: Manages popup windows for CI/CD pipeline options.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions:
/// - Popup window is displayed with option details
/// - Only one popup can be open at a time
/// Throws: Never
/// Complexity: O(1)
/// Used By: PipelineOptimizationViewController
class PopupWindowController: NSWindowController {
    
    // MARK: - Properties
    
    private var optionTitle: String
    private var optionDescription: String
    private var optionDetails: [String]
    private var jenkinsTemplate: String?
    private var customizationWindows: [NSWindow] = []
    
    // MARK: - UI Elements
    
    private var titleLabel: NSTextField!
    private var descriptionLabel: NSTextField!
    private var detailsStackView: NSStackView!
    private var customizeButton: NSButton!
    private var closeButton: NSButton!
    
    // MARK: - Initialization
    
    /// Purpose: Initialize popup window with option details.
    /// Parameters:
    ///   - title: The title of the CI/CD option
    ///   - description: Brief description of the option
    ///   - details: Array of detailed information about the option
    ///   - jenkinsTemplate: Optional Jenkins template for customization
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Popup window is ready to display
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: PipelineOptimizationViewController
    init(title: String, description: String, details: [String], jenkinsTemplate: String? = nil) {
        self.optionTitle = title
        self.optionDescription = description
        self.optionDetails = details
        self.jenkinsTemplate = jenkinsTemplate
        
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Pipeline Option Details"
        window.center()
        window.isReleasedWhenClosed = false
        
        super.init(window: window)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    /// Purpose: Set up the popup window UI elements.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: Window is initialized
    /// Postconditions: UI elements are configured and displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: init
    private func setupUI() {
        guard let window = window else { return }
        
        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        window.contentView = contentView
        
        // Create title label
        titleLabel = NSTextField(labelWithString: optionTitle)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = NSColor.labelColor
        titleLabel.alignment = .center
        contentView.addSubview(titleLabel)
        
        // Create description label
        descriptionLabel = NSTextField(labelWithString: optionDescription)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = NSColor.secondaryLabelColor
        descriptionLabel.alignment = .center
        descriptionLabel.maximumNumberOfLines = 0
        contentView.addSubview(descriptionLabel)
        
        // Create details stack view
        detailsStackView = NSStackView()
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.orientation = .vertical
        detailsStackView.spacing = 8
        detailsStackView.alignment = .leading
        contentView.addSubview(detailsStackView)
        
        // Add detail items
        for detail in optionDetails {
            let detailLabel = NSTextField(labelWithString: "• \(detail)")
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
            detailLabel.textColor = NSColor.labelColor
            detailLabel.maximumNumberOfLines = 0
            detailsStackView.addArrangedSubview(detailLabel)
        }
        
        // Create customize button (only for Jenkins)
        if jenkinsTemplate != nil {
            customizeButton = NSButton()
            customizeButton.translatesAutoresizingMaskIntoConstraints = false
            customizeButton.bezelStyle = .rounded
            customizeButton.title = "Customize Jenkinsfile"
            customizeButton.target = self
            customizeButton.action = #selector(customizeButtonTapped(_:))
            contentView.addSubview(customizeButton)
        }
        
        // Create close button
        closeButton = NSButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.bezelStyle = .rounded
        closeButton.title = "Close"
        closeButton.target = self
        closeButton.action = #selector(closeButtonTapped(_:))
        contentView.addSubview(closeButton)
        
        // Set up constraints
        var constraints: [NSLayoutConstraint] = [
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Description label constraints
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Details stack view constraints
            detailsStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            detailsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ]
        
        // Add customize button constraints if present
        if let customizeButton = customizeButton {
            constraints.append(contentsOf: [
                customizeButton.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 20),
                customizeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                customizeButton.widthAnchor.constraint(equalToConstant: 180),
                customizeButton.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        // Add close button constraints
        let closeButtonTopAnchor = customizeButton?.bottomAnchor ?? detailsStackView.bottomAnchor
        let closeButtonTopConstant: CGFloat = customizeButton != nil ? 10 : 20
        
        constraints.append(contentsOf: [
            closeButton.topAnchor.constraint(equalTo: closeButtonTopAnchor, constant: closeButtonTopConstant),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Actions
    
    /// Purpose: Handle customize button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: Template is available
    /// Postconditions: Appropriate customization view is shown
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: customizeButton
    @objc private func customizeButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("PopupWindowController.customizeButtonTapped")
        
        guard let template = jenkinsTemplate else {
            Logger.shared.warning("Template not available", category: .ui)
            return
        }
        
        let customizationVC = createCustomizationViewController(for: optionTitle, template: template)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Customize \(getConfigurationFileName(for: optionTitle))"
        window.contentViewController = customizationVC
        window.center()
        window.isReleasedWhenClosed = false
        
        // Track and clean up the window lifecycle
        customizationWindows.append(window)
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { [weak self, weak window] _ in
            guard let self = self, let window = window else { return }
            self.customizationWindows.removeAll { $0 == window }
        }
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        Logger.shared.methodExit("PopupWindowController.customizeButtonTapped")
    }
    
    /// Purpose: Create the appropriate customization view controller for the option.
    /// Parameters:
    ///   - optionTitle: The title of the CI/CD option
    ///   - template: The template content
    /// Returns: Customization view controller
    /// Preconditions: Template is valid
    /// Postconditions: Appropriate view controller is created
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: customizeButtonTapped
    private func createCustomizationViewController(for optionTitle: String, template: String) -> NSViewController {
        if optionTitle.contains("Jenkins") {
            return JenkinsCustomizationViewController(template: template)
        } else if optionTitle.contains("GitHub Actions") {
            return GitHubActionsCustomizationViewController(template: template)
        } else if optionTitle.contains("GitLab CI") {
            return GitLabCICustomizationViewController(template: template)
        } else if optionTitle.contains("CircleCI") {
            return CircleCICustomizationViewController(template: template)
        } else if optionTitle.contains("Bitrise") {
            return BitriseCustomizationViewController(template: template)
        } else if optionTitle.contains("Azure Pipelines") {
            return AzurePipelinesCustomizationViewController(template: template)
        } else if optionTitle.contains("Codemagic") {
            return CodemagicCustomizationViewController(template: template)
        } else if optionTitle.contains("Travis CI") {
            return TravisCICustomizationViewController(template: template)
        }
        
        // Fallback to base customization
        return BaseCustomizationViewController(template: template)
    }
    
    /// Purpose: Get the configuration file name for the option.
    /// Parameters:
    ///   - optionTitle: The title of the CI/CD option
    /// Returns: Configuration file name
    /// Preconditions: None
    /// Postconditions: File name is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: customizeButtonTapped
    private func getConfigurationFileName(for optionTitle: String) -> String {
        if optionTitle.contains("Jenkins") {
            return "Jenkinsfile"
        } else if optionTitle.contains("GitHub Actions") {
            return "GitHub Actions Workflow"
        } else if optionTitle.contains("GitLab CI") {
            return "GitLab CI Pipeline"
        } else if optionTitle.contains("CircleCI") {
            return "CircleCI Pipeline"
        } else if optionTitle.contains("Bitrise") {
            return "Bitrise Pipeline"
        } else if optionTitle.contains("Azure Pipelines") {
            return "Azure Pipelines"
        } else if optionTitle.contains("Codemagic") {
            return "Codemagic Pipeline"
        } else if optionTitle.contains("Travis CI") {
            return "Travis CI Pipeline"
        }
        
        return "Configuration"
    }
    
    /// Purpose: Handle close button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Popup window is closed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: closeButton
    @objc private func closeButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("PopupWindowController.closeButtonTapped")
        close()
        Logger.shared.methodExit("PopupWindowController.closeButtonTapped")
    }
    
    // MARK: - Public Methods
    
    /// Purpose: Show the popup window.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Popup window is displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: PipelineOptimizationViewController
    func showPopup() {
        Logger.shared.methodEntry("PopupWindowController.showPopup")
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        Logger.shared.methodExit("PopupWindowController.showPopup")
    }
}
