import Cocoa

/// Purpose: Base class for CI/CD pipeline customization views.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions: Base functionality is provided for customization views
/// Throws: Never
/// Complexity: O(1)
/// Used By: All customization view controllers
class BaseCustomizationViewController: NSViewController {
    
    // MARK: - Properties
    
    internal var template: String
    internal var customizedContent: String = ""
    
    /// Purpose: Completion callback for when customization is complete.
    /// Parameters: Customized content string or nil if cancelled
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Callback is called when customization is complete
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: ViewController
    var onCustomizationComplete: ((String?) -> Void)?
    
    // MARK: - UI Elements
    
    internal var scrollView: NSScrollView!
    internal var contentView: NSView!
    internal var formStackView: NSStackView!
    internal var generateButton: NSButton!
    internal var previewButton: NSButton!
    internal var closeButton: NSButton!
    
    // MARK: - Initialization
    
    /// Purpose: Initialize base customization view with template.
    /// Parameters:
    ///   - template: The template content to customize
    /// Returns: Void
    /// Preconditions: Template is valid content
    /// Postconditions: View controller is ready for customization
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: Subclasses
    init(template: String) {
        self.template = template
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.methodEntry("BaseCustomizationViewController.viewDidLoad")
        
        setupUI()
        setupFormFields()
        loadDefaultValues()
        
        Logger.shared.appLifecycle("BaseCustomizationViewController loaded")
        Logger.shared.methodExit("BaseCustomizationViewController.viewDidLoad")
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
    internal func setupUI() {
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
    internal func setupButtons() {
        let buttonStackView = NSStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.orientation = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.alignment = .centerY
        view.addSubview(buttonStackView)
        
        // Generate button
        generateButton = NSButton()
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.bezelStyle = .rounded
        generateButton.title = "Generate Configuration"
        generateButton.target = self
        generateButton.action = #selector(generateButtonTapped(_:))
        buttonStackView.addArrangedSubview(generateButton)
        
        // Preview button
        previewButton = NSButton()
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.bezelStyle = .rounded
        previewButton.title = "Preview"
        previewButton.target = self
        previewButton.action = #selector(previewButtonTapped(_:))
        buttonStackView.addArrangedSubview(previewButton)
        
        // Close button
        closeButton = NSButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.bezelStyle = .rounded
        closeButton.title = "Close"
        closeButton.target = self
        closeButton.action = #selector(closeButtonTapped(_:))
        buttonStackView.addArrangedSubview(closeButton)
        
        // Button constraints
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 10),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Form Helpers
    
    /// Purpose: Add a section header to the form.
    /// Parameters:
    ///   - title: The section title
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Section header is added to form
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupFormFields
    internal func addSectionHeader(_ title: String) {
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
    internal func addTextField(label: String, field: inout NSTextField!, placeholder: String) {
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
    internal func addPopUpButton(label: String, popUp: inout NSPopUpButton!, options: [String]) {
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
    
    // MARK: - Abstract Methods (Override in subclasses)
    
    /// Purpose: Set up form fields specific to the CI/CD platform.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Form fields are configured
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: viewDidLoad
    func setupFormFields() {
        // Override in subclasses
    }
    
    /// Purpose: Load default values into form fields.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: Form fields are initialized
    /// Postconditions: Form fields contain default values
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: viewDidLoad
    func loadDefaultValues() {
        // Override in subclasses
    }
    
    /// Purpose: Generate customized content from form values.
    /// Parameters: None
    /// Returns: Customized content string
    /// Preconditions: Form fields are populated
    /// Postconditions: Content is customized with user values
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: generateButtonTapped, previewButtonTapped
    func generateCustomizedContent() -> String {
        // Override in subclasses
        return template
    }
    
    // MARK: - Actions
    
    /// Purpose: Handle generate button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Content is generated and customized
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: generateButton
    @objc private func generateButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("BaseCustomizationViewController.generateButtonTapped")
        
        customizedContent = generateCustomizedContent()
        
        // Call completion callback with customized content
        onCustomizationComplete?(customizedContent)
        
        // Properly dismiss the window
        if let window = view.window {
            window.performClose(nil)
        }
        
        Logger.shared.methodExit("BaseCustomizationViewController.generateButtonTapped")
    }
    
    /// Purpose: Handle preview button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Preview window is shown
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: previewButton
    @objc private func previewButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("BaseCustomizationViewController.previewButtonTapped")
        
        let preview = generateCustomizedContent()
        showPreviewWindow(content: preview)
        
        Logger.shared.methodExit("BaseCustomizationViewController.previewButtonTapped")
    }
    
    /// Purpose: Handle close button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: View controller is dismissed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: closeButton
    @objc private func closeButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("BaseCustomizationViewController.closeButtonTapped")
        
        // Call completion callback with nil (cancelled)
        onCustomizationComplete?(nil)
        
        // Properly dismiss the window
        if let window = view.window {
            window.performClose(nil)
        }
        
        Logger.shared.methodExit("BaseCustomizationViewController.closeButtonTapped")
    }
    
    // MARK: - Preview
    
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
        window.title = "Configuration Preview"
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
