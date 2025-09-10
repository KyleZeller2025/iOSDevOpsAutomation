//
//  ViewController.swift
//  iOSDevOpsAutomation
//
//  Created by Kyle Zeller on 9/9/25.
//

import Cocoa
import Combine

/// Purpose: Main view controller for the DevOps automation app using strict MVC pattern.
/// Parameters: None (class)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All methods are pure functions
/// Throws: Never
/// Complexity: O(1)
/// Used By: AppDelegate, main app flow
public class ViewController: NSViewController {
    
    // MARK: - Properties
    
    private var model: ProjectModel?
    private var cancellables = Set<AnyCancellable>()
    private var pipelineOptimizationViewController: PipelineOptimizationViewController?
    private var fileWriter: PipelineFileWriter
    private var scanner: SemgrepScanner
    weak var coordinator: PipelineOptimizationViewControllerDelegate?
    private var customizationWindows: [NSWindow] = []
    
    // MARK: - Required Initializers
    
    required init?(coder: NSCoder) {
        // Fallback for storyboard/xib init; keep defaults minimal
        self.fileWriter = PipelineFileWriter()
        self.scanner = SemgrepScanner()
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.fileWriter = PipelineFileWriter()
        self.scanner = SemgrepScanner()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: - UI Elements
    
    private var containerView: NSView!
    private var mainLabel: NSTextField!
    private var selectFolderButton: NSButton!
    
    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.methodEntry("ViewController.viewDidLoad")
        
        setupModel()
        setupUI()

        Logger.shared.appLifecycle("ViewController loaded")
        Logger.shared.methodExit("ViewController.viewDidLoad")
    }

    public override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - Model Setup
    
    /// Purpose: Sets up the model and binds to its properties.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Model is created and bound
    /// - UI updates are connected to model changes
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: viewDidLoad
    private func setupModel() {
        if model == nil { model = ProjectModel() }
        
        // Bind to model changes
        model?.$selectedFolderPath
            .receive(on: DispatchQueue.main)
            .sink { [weak self] path in
                self?.updateMainLabel(path)
            }
            .store(in: &cancellables)
        
        model?.$currentView
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentView in
                self?.handleViewChange(currentView)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Setup
    
    /// Purpose: Sets up the initial UI state and appearance.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - UI elements are configured with initial state
    /// - Button states are properly set
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: viewDidLoad
    private func setupUI() {
        // Create the main container view
        containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Create main label
        mainLabel = NSTextField(labelWithString: "Please select a folder containing an iOS application")
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        mainLabel.textColor = NSColor.labelColor
        mainLabel.alignment = .center
        containerView.addSubview(mainLabel)
        
        // Create select folder button
        selectFolderButton = NSButton()
        selectFolderButton.translatesAutoresizingMaskIntoConstraints = false
        selectFolderButton.bezelStyle = .rounded
        selectFolderButton.title = "Select iOS Project Folder"
        selectFolderButton.target = self
        selectFolderButton.action = #selector(selectFolderButtonTapped(_:))
        containerView.addSubview(selectFolderButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Main label constraints
            mainLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Select button constraints
            selectFolderButton.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 20),
            selectFolderButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            selectFolderButton.widthAnchor.constraint(equalToConstant: 200),
            selectFolderButton.heightAnchor.constraint(equalToConstant: 30),
            selectFolderButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    
    
    
    // MARK: - Actions
    
    /// Purpose: Handles the select folder button tap.
    /// Parameters:
    ///   - sender: The button that was tapped
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Folder selection dialog is presented
    /// - Selected folder is passed to model
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: UI interaction
    @objc private func selectFolderButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("ViewController.selectFolderButtonTapped")
        Logger.shared.uiEvent("buttonTapped", component: "selectFolderButton")
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.title = "Select iOS Project Folder"
        panel.message = "Choose a folder containing an iOS application"

        panel.begin { [weak self] response in
            guard response == .OK, let url = panel.url else { 
                Logger.shared.info("Folder selection cancelled", category: .ui)
                return 
            }
            Logger.shared.info("Folder selected by user", category: .ui, metadata: ["path": url.path])
            self?.model?.selectFolder(url.path)
        }
        
        Logger.shared.methodExit("ViewController.selectFolderButtonTapped")
    }
    
   
    
    // MARK: - Model Updates
    
    /// Purpose: Updates the main label based on folder selection state.
    /// Parameters:
    ///   - path: The selected folder path
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Main label shows appropriate message based on state
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: Model binding
    private func updateMainLabel(_ path: String?) {
        if let path = path {
            let folderName = URL(fileURLWithPath: path).lastPathComponent
            mainLabel.stringValue = "Selected folder: \(folderName)"
        } else {
            mainLabel.stringValue = "Please select a folder containing an iOS application"
        }
    }
    
    /// Purpose: Handles view changes based on model state.
    /// Parameters:
    ///   - currentView: The current view state
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Appropriate view is displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: Model binding
    private func handleViewChange(_ currentView: AppView) {
        Logger.shared.methodEntry("ViewController.handleViewChange", parameters: ["currentView": "\(currentView)"])
        switch currentView {
        case .projectSelection:
            Logger.shared.info("Showing project selection view", category: .navigation)
            showProjectSelectionView()
        case .pipelineOptimization:
            Logger.shared.info("Showing pipeline optimization view", category: .navigation)
            showPipelineOptimizationView()
        }
        Logger.shared.methodExit("ViewController.handleViewChange")
    }
    
    /// Purpose: Shows the project selection view.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Project selection view is visible
    /// - Pipeline optimization view is hidden
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: handleViewChange
    private func showProjectSelectionView() {
        Logger.shared.methodEntry("ViewController.showProjectSelectionView")
        containerView.isHidden = false
        pipelineOptimizationViewController?.view.isHidden = true
        Logger.shared.methodExit("ViewController.showProjectSelectionView")
    }
    
    /// Purpose: Shows the pipeline optimization view.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Pipeline optimization view is visible
    /// - Project selection view is hidden
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: handleViewChange
    private func showPipelineOptimizationView() {
        Logger.shared.methodEntry("ViewController.showPipelineOptimizationView")
        if pipelineOptimizationViewController == nil {
            Logger.shared.info("Creating PipelineOptimizationViewController", category: .navigation)
            pipelineOptimizationViewController = PipelineOptimizationViewController(model: model!, scanner: scanner)
            pipelineOptimizationViewController?.delegate = coordinator
            
            // Add as child view controller
            addChild(pipelineOptimizationViewController!)
            view.addSubview(pipelineOptimizationViewController!.view)
            pipelineOptimizationViewController!.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                pipelineOptimizationViewController!.view.topAnchor.constraint(equalTo: view.topAnchor),
                pipelineOptimizationViewController!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pipelineOptimizationViewController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pipelineOptimizationViewController!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            Logger.shared.info("PipelineOptimizationViewController added to view hierarchy", category: .navigation)
        }
        
        Logger.shared.info("Hiding main view content and showing pipeline view", category: .navigation)
        containerView.isHidden = true
        pipelineOptimizationViewController?.view.isHidden = false
        
        // Force layout update
        pipelineOptimizationViewController?.view.needsLayout = true
        pipelineOptimizationViewController?.view.layoutSubtreeIfNeeded()
        
        Logger.shared.navigation(from: "ProjectSelection", to: "PipelineOptimization")
        Logger.shared.methodExit("ViewController.showPipelineOptimizationView")
    }
    
    /// Purpose: Handles change project notification.
    /// Parameters:
    ///   - notification: The notification object
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Navigation back to project selection is triggered
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: NotificationCenter
    @objc private func handleChangeProjectRequested(_ notification: Notification) {
        model?.goBackToProjectSelection()
    }
    
    /// Purpose: Handles optimize pipelines notification.
    /// Parameters:
    ///   - notification: The notification object
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Pipeline optimization is initiated
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: NotificationCenter
    @objc private func handleOptimizePipelinesRequested(_ notification: Notification) {
        guard let selectedPipelines = notification.object as? [String] else { return }
        
        Logger.shared.methodEntry("ViewController.handleOptimizePipelinesRequested")
        Logger.shared.info("Starting optimization for \(selectedPipelines.count) pipelines", metadata: ["pipelines": selectedPipelines])
        
        // Check if we have a project selected
        guard let projectPath = model?.selectedFolderPath else {
            let alert = NSAlert()
            alert.messageText = "No Project Selected"
            alert.informativeText = "Please select an iOS project folder first."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        
        // Start the customization flow
        startCustomizationFlow(for: selectedPipelines, projectPath: projectPath)
        
        Logger.shared.methodExit("ViewController.handleOptimizePipelinesRequested")
    }
    
    /// Purpose: Starts the sequential customization flow for selected pipelines.
    /// Parameters:
    ///   - pipelines: Array of selected pipeline names
    ///   - projectPath: Path to the iOS project directory
    /// Returns: Void
    /// Preconditions: Valid pipelines array and project path
    /// Postconditions: Customization flow is initiated
    /// Throws: Never
    /// Complexity: O(n) where n is the number of pipelines
    /// Used By: handleOptimizePipelinesRequested
    func startCustomizationFlow(for pipelines: [String], projectPath: String) {
        Logger.shared.methodEntry("ViewController.startCustomizationFlow")
        
        // Store the customization data
        var customizationResults: [String: String] = [:]
        var currentPipelineIndex = 0
        
        func processNextPipeline() {
            guard currentPipelineIndex < pipelines.count else {
                // All pipelines processed, generate files
                generatePipelineFiles(from: customizationResults, projectPath: projectPath)
                return
            }
            
            let pipelineName = pipelines[currentPipelineIndex]
            Logger.shared.info("Processing pipeline: \(pipelineName)")
            
            // Get the template for this pipeline
            guard let template = getTemplateForPipeline(pipelineName) else {
                Logger.shared.warning("No template found for pipeline: \(pipelineName)")
                currentPipelineIndex += 1
                processNextPipeline()
                return
            }
            
            // Create and present customization view controller
            presentCustomizationViewController(
                for: pipelineName,
                template: template,
                completion: { [weak self] customizedContent in
                    if let content = customizedContent {
                        customizationResults[pipelineName] = content
                        Logger.shared.info("Customization completed for \(pipelineName)")
                    } else {
                        Logger.shared.warning("Customization cancelled for \(pipelineName)")
                    }
                    
                    currentPipelineIndex += 1
                    processNextPipeline()
                }
            )
        }
        
        processNextPipeline()
        Logger.shared.methodExit("ViewController.startCustomizationFlow")
    }
    
    /// Purpose: Presents the appropriate customization view controller for a pipeline.
    /// Parameters:
    ///   - pipelineName: Name of the pipeline to customize
    ///   - template: Template string for the pipeline
    ///   - completion: Completion handler with customized content
    /// Returns: Void
    /// Preconditions: Valid pipeline name and template
    /// Postconditions: Customization view controller is presented
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: startCustomizationFlow
    private func presentCustomizationViewController(
        for pipelineName: String,
        template: String,
        completion: @escaping (String?) -> Void
    ) {
        Logger.shared.methodEntry("ViewController.presentCustomizationViewController")
        
        guard let customizationVC = PipelineCatalog.makeCustomizationViewController(for: pipelineName, template: template) else {
            Logger.shared.warning("Unknown pipeline type: \(pipelineName)")
            completion(nil)
            return
        }
        
        // Set up completion handler
        customizationVC.onCustomizationComplete = { [weak self] customizedContent in
            Logger.shared.info("Customization completed for \(pipelineName)")
            completion(customizedContent)
        }
        
        // Create and present the window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Customize \(pipelineName)"
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
        
        Logger.shared.methodExit("ViewController.presentCustomizationViewController")
    }
    
    /// Purpose: Generates and saves pipeline files based on customization results.
    /// Parameters:
    ///   - results: Dictionary of pipeline names to customized content
    ///   - projectPath: Path to the iOS project directory
    /// Returns: Void
    /// Preconditions: Valid results dictionary and project path
    /// Postconditions: Pipeline files are generated and saved
    /// Throws: Never
    /// Complexity: O(n) where n is the number of results
    /// Used By: startCustomizationFlow
    private func generatePipelineFiles(from results: [String: String], projectPath: String) {
        Logger.shared.methodEntry("ViewController.generatePipelineFiles")
        
        let (generatedFiles, errors) = fileWriter.generatePipelineFiles(from: results, projectPath: projectPath)
        
        // Show results to user
        showGenerationResults(generatedFiles: generatedFiles, errors: errors)
        
        Logger.shared.methodExit("ViewController.generatePipelineFiles")
    }
    
    // File path resolution and writing are delegated to PipelineFileWriter service.
    
    /// Purpose: Shows the results of pipeline file generation to the user.
    /// Parameters:
    ///   - generatedFiles: Array of successfully generated file paths
    ///   - errors: Array of error messages
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Results are displayed to the user
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: generatePipelineFiles
    private func showGenerationResults(generatedFiles: [String], errors: [String]) {
        var message = ""
        
        if !generatedFiles.isEmpty {
            message += "✅ Successfully generated \(generatedFiles.count) pipeline file(s):\n\n"
            for file in generatedFiles {
                message += "• \(file)\n"
            }
        }
        
        if !errors.isEmpty {
            if !message.isEmpty { message += "\n" }
            message += "❌ Errors:\n\n"
            for error in errors {
                message += "• \(error)\n"
            }
        }
        
        if message.isEmpty {
            message = "No files were generated."
        }
        
        let alert = NSAlert()
        alert.messageText = "Pipeline Generation Complete"
        alert.informativeText = message
        alert.alertStyle = generatedFiles.isEmpty ? .warning : .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    /// Purpose: Gets the template for a specific pipeline type.
    /// Parameters:
    ///   - pipelineName: Name of the pipeline
    /// Returns: Template string or nil if not found
    /// Preconditions: Valid pipeline name
    /// Postconditions: Template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: startCustomizationFlow
    private func getTemplateForPipeline(_ pipelineName: String) -> String? {
        // Create a temporary PipelineOptimizationViewController to get templates
        let tempVC = PipelineOptimizationViewController(model: model ?? ProjectModel(), scanner: scanner)
        return tempVC.getTemplateForOption(pipelineName)
    }
    
    deinit { }
}

// MARK: - Initialization (DI)
extension ViewController {
    // Convenience initializer for DI
    convenience init(model: ProjectModel, fileWriter: PipelineFileWriter, scanner: SemgrepScanner) {
        self.init(nibName: nil, bundle: nil)
        self.model = model
        self.fileWriter = fileWriter
        self.scanner = scanner
    }
}

