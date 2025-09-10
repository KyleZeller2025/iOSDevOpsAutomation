import Cocoa
import Combine

/// Purpose: View controller for CI/CD pipeline optimization using strict MVC pattern.
/// Parameters: None (class)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All methods are pure functions
/// Throws: Never
/// Complexity: O(1)
/// Used By: MainCoordinator, navigation flow
public class PipelineOptimizationViewController: NSViewController {
    
    // MARK: - Properties
    
    private var model: ProjectModel?
    private var cancellables = Set<AnyCancellable>()
    private var semgrepScanner: SemgrepScanner?
    weak var delegate: PipelineOptimizationViewControllerDelegate?
    private var securityScanWindow: NSWindow?
    private var securityScanWindowDelegate: SecurityScanWindowDelegate?
    
    // MARK: - UI Elements
    
    private var projectLabel: NSTextField!
    private var changeProjectButton: NSButton!
    private var pipelineOptionsScrollView: NSScrollView!
    private var pipelineOptionsStackView: NSStackView!
    private var securityScanButton: NSButton!
    
    // MARK: - Pipeline Options
    
    private var pipelineCheckboxes: [NSButton] = []
    private var currentPopup: PopupWindowController?
    private let pipelineOptions = [
        "GitHub Actions (.github/workflows/ci.yml)",
        "GitLab CI (.gitlab-ci.yml)",
        "Jenkins (Jenkinsfile)",
        "CircleCI (.circleci/config.yml)",
        "Bitrise (bitrise.yml)",
        "Azure Pipelines (azure-pipelines.yml)",
        "Buildkite (.buildkite/pipeline.yml)",
        "TeamCity (build.xml)",
        "Codemagic (codemagic.yaml)",
        "Travis CI (.travis.yml)"
    ]
    
    // MARK: - Pipeline Option Details
    
    private let pipelineOptionDetails: [String: (description: String, details: [String])] = [
        "GitHub Actions (.github/workflows/ci.yml)": (
            description: "GitHub's native CI/CD platform with YAML-based workflows",
            details: [
                "Runs on GitHub's hosted runners or self-hosted runners",
                "Supports matrix builds for multiple OS and language versions",
                "Integrates seamlessly with GitHub repositories",
                "Free for public repositories, limited free minutes for private repos",
                "Supports secrets management and environment variables",
                "Built-in caching and artifact management"
            ]
        ),
        "GitLab CI (.gitlab-ci.yml)": (
            description: "GitLab's integrated CI/CD platform with powerful pipeline features",
            details: [
                "Runs on GitLab's shared runners or self-hosted runners",
                "Supports parallel and sequential job execution",
                "Advanced caching and artifact management",
                "Built-in container registry and package registry",
                "Supports multiple deployment strategies",
                "Free for public projects, paid plans for private projects"
            ]
        ),
        "Jenkins (Jenkinsfile)": (
            description: "Open-source automation server with extensive plugin ecosystem",
            details: [
                "Self-hosted solution with full control over infrastructure",
                "Supports both declarative and scripted pipeline syntax",
                "Extensive plugin ecosystem for integrations",
                "Supports distributed builds across multiple agents",
                "Free and open-source with community support",
                "Requires server maintenance and updates"
            ]
        ),
        "CircleCI (.circleci/config.yml)": (
            description: "Cloud-native CI/CD platform with fast builds and easy setup",
            details: [
                "Runs on CircleCI's cloud infrastructure or self-hosted runners",
                "Supports Docker and machine executors",
                "Advanced caching and parallelization features",
                "Free tier with limited build minutes",
                "Easy integration with GitHub, GitLab, and Bitbucket",
                "Supports matrix builds and workflow orchestration"
            ]
        ),
        "Bitrise (bitrise.yml)": (
            description: "Mobile-focused CI/CD platform with iOS and Android expertise",
            details: [
                "Specialized in mobile app development workflows",
                "Pre-built steps for iOS and Android builds",
                "Supports multiple deployment targets (App Store, Google Play)",
                "Free tier with limited build minutes",
                "Easy setup for React Native, Flutter, and native apps",
                "Built-in code signing and certificate management"
            ]
        ),
        "Azure Pipelines (azure-pipelines.yml)": (
            description: "Microsoft's cloud-native CI/CD platform with Azure integration",
            details: [
                "Runs on Microsoft-hosted agents or self-hosted agents",
                "Deep integration with Azure services",
                "Supports multiple languages and platforms",
                "Free tier with limited build minutes",
                "Advanced security and compliance features",
                "Supports both YAML and classic editor interfaces"
            ]
        ),
        "Buildkite (.buildkite/pipeline.yml)": (
            description: "Developer-friendly CI/CD platform with self-hosted agents",
            details: [
                "Self-hosted agents with cloud management",
                "Supports Docker and native builds",
                "Advanced pipeline visualization and debugging",
                "Free for open-source projects",
                "Excellent for complex build requirements",
                "Supports parallel builds and matrix builds"
            ]
        ),
        "TeamCity (build.xml)": (
            description: "JetBrains' powerful CI/CD server with advanced build management",
            details: [
                "Self-hosted solution with cloud options",
                "Advanced build configuration and management",
                "Excellent integration with JetBrains IDEs",
                "Free for small teams, paid for larger organizations",
                "Supports complex build chains and dependencies",
                "Advanced reporting and analytics"
            ]
        ),
        "Codemagic (codemagic.yaml)": (
            description: "Mobile-first CI/CD platform with fast iOS and Android builds",
            details: [
                "Specialized in mobile app development",
                "Fast iOS and Android build times",
                "Easy setup for Flutter, React Native, and native apps",
                "Free tier with limited build minutes",
                "Built-in code signing and app store deployment",
                "Supports multiple testing frameworks"
            ]
        ),
        "Travis CI (.travis.yml)": (
            description: "Cloud-based CI platform with simple YAML configuration",
            details: [
                "Runs on Travis CI's cloud infrastructure",
                "Simple YAML-based configuration",
                "Free for open-source projects",
                "Supports multiple languages and platforms",
                "Easy GitHub integration",
                "Limited free tier for private repositories"
            ]
        )
    ]
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.methodEntry("PipelineOptimizationViewController.viewDidLoad")
        
        setupUI()
        
        // Update UI with model data after setup is complete
        updateProjectLabel()
        
        Logger.shared.appLifecycle("PipelineOptimizationViewController loaded")
        Logger.shared.methodExit("PipelineOptimizationViewController.viewDidLoad")
    }
    
    deinit {
        Logger.shared.methodEntry("PipelineOptimizationViewController.deinit")
        closeCurrentPopup()
        Logger.shared.methodExit("PipelineOptimizationViewController.deinit")
    }
    
    // MARK: - Setup
    
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
        // Model will be set by the parent coordinator
    }

    // MARK: - Initialization (DI)
    convenience init(model: ProjectModel, scanner: SemgrepScanner) {
        self.init(nibName: nil, bundle: nil)
        self.model = model
        self.semgrepScanner = scanner
    }
    
    /// Purpose: Sets up the initial UI state and appearance.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - UI elements are configured with initial state
    /// - All controls are properly set up
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: viewDidLoad
    private func setupUI() {
        // Create the main container view
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Create project info section
        let projectInfoView = createProjectInfoView()
        containerView.addSubview(projectInfoView)
        
        // Create pipeline options section
        let pipelineOptionsView = createPipelineOptionsView()
        containerView.addSubview(pipelineOptionsView)
        
        // Create action buttons section
        let actionButtonsView = createActionButtonsView()
        containerView.addSubview(actionButtonsView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            
            // Project info constraints
            projectInfoView.topAnchor.constraint(equalTo: containerView.topAnchor),
            projectInfoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            projectInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            projectInfoView.heightAnchor.constraint(equalToConstant: 60),
            
            // Pipeline options constraints
            pipelineOptionsView.topAnchor.constraint(equalTo: projectInfoView.bottomAnchor, constant: 20),
            pipelineOptionsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pipelineOptionsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pipelineOptionsView.bottomAnchor.constraint(equalTo: actionButtonsView.topAnchor, constant: -20),
            
            // Action buttons constraints
            actionButtonsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            actionButtonsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            actionButtonsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            actionButtonsView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    /// Purpose: Creates the project information section.
    /// Parameters: None
    /// Returns: The configured project info view
    /// Preconditions: None
    /// Postconditions:
    /// - Project info view is created and configured
    /// - All UI elements are properly set up
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupUI method
    private func createProjectInfoView() -> NSView {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Project label
        projectLabel = NSTextField(labelWithString: "Current Project: None")
        projectLabel.translatesAutoresizingMaskIntoConstraints = false
        projectLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        projectLabel.textColor = NSColor.labelColor
        view.addSubview(projectLabel)
        
        // Change project button
        changeProjectButton = NSButton()
        changeProjectButton.translatesAutoresizingMaskIntoConstraints = false
        changeProjectButton.bezelStyle = .rounded
        changeProjectButton.title = "Change Project"
        changeProjectButton.target = self
        changeProjectButton.action = #selector(changeProjectButtonTapped(_:))
        view.addSubview(changeProjectButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Project label
            projectLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            projectLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            projectLabel.trailingAnchor.constraint(equalTo: changeProjectButton.leadingAnchor, constant: -20),
            
            // Change project button
            changeProjectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            changeProjectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            changeProjectButton.widthAnchor.constraint(equalToConstant: 120),
            changeProjectButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return view
    }
    
    /// Purpose: Creates the pipeline options section.
    /// Parameters: None
    /// Returns: The configured pipeline options view
    /// Preconditions: None
    /// Postconditions:
    /// - Pipeline options view is created and configured
    /// - All checkboxes are properly set up
    /// Throws: Never
    /// Complexity: O(n) where n is the number of pipeline options
    /// Used By: setupUI method
    private func createPipelineOptionsView() -> NSView {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        let titleLabel = NSTextField(labelWithString: "Select CI/CD Pipeline Files to Optimize:")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = NSColor.labelColor
        view.addSubview(titleLabel)
        
        // Scroll view for options
        pipelineOptionsScrollView = NSScrollView()
        pipelineOptionsScrollView.translatesAutoresizingMaskIntoConstraints = false
        pipelineOptionsScrollView.hasVerticalScroller = true
        pipelineOptionsScrollView.hasHorizontalScroller = false
        pipelineOptionsScrollView.autohidesScrollers = true
        view.addSubview(pipelineOptionsScrollView)
        
        // Stack view for checkboxes
        pipelineOptionsStackView = NSStackView()
        pipelineOptionsStackView.translatesAutoresizingMaskIntoConstraints = false
        pipelineOptionsStackView.orientation = .vertical
        pipelineOptionsStackView.alignment = .leading
        pipelineOptionsStackView.distribution = .fill
        pipelineOptionsStackView.spacing = 8
        
        // Create checkboxes for each pipeline option
        for option in pipelineOptions {
            let checkbox = NSButton()
            checkbox.setButtonType(.switch)
            checkbox.title = option
            checkbox.target = self
            checkbox.action = #selector(pipelineOptionChanged(_:))
            pipelineCheckboxes.append(checkbox)
            pipelineOptionsStackView.addArrangedSubview(checkbox)
        }
        
        pipelineOptionsScrollView.documentView = pipelineOptionsStackView
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Scroll view
            pipelineOptionsScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            pipelineOptionsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pipelineOptionsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pipelineOptionsScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Stack view
            pipelineOptionsStackView.leadingAnchor.constraint(equalTo: pipelineOptionsScrollView.leadingAnchor, constant: 10),
            pipelineOptionsStackView.trailingAnchor.constraint(equalTo: pipelineOptionsScrollView.trailingAnchor, constant: -10),
            pipelineOptionsStackView.topAnchor.constraint(equalTo: pipelineOptionsScrollView.topAnchor, constant: 10),
            pipelineOptionsStackView.bottomAnchor.constraint(equalTo: pipelineOptionsScrollView.bottomAnchor, constant: -10)
        ])
        
        return view
    }
    
    /// Purpose: Creates the action buttons section.
    /// Parameters: None
    /// Returns: The configured action buttons view
    /// Preconditions: None
    /// Postconditions:
    /// - Action buttons view is created and configured
    /// - All buttons are properly set up
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setupUI method
    private func createActionButtonsView() -> NSView {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create button stack view
        let buttonStackView = NSStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.orientation = .horizontal
        buttonStackView.spacing = 16
        buttonStackView.alignment = .centerY
        view.addSubview(buttonStackView)
        
        // Security scan button
        securityScanButton = NSButton()
        securityScanButton.translatesAutoresizingMaskIntoConstraints = false
        securityScanButton.bezelStyle = .rounded
        securityScanButton.title = "🔒 Security Scan"
        securityScanButton.target = self
        securityScanButton.action = #selector(securityScanButtonTapped(_:))
        securityScanButton.isEnabled = false // Disabled until project is selected
        buttonStackView.addArrangedSubview(securityScanButton)
        
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Button stack view
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Security scan button
            securityScanButton.widthAnchor.constraint(equalToConstant: 150),
            securityScanButton.heightAnchor.constraint(equalToConstant: 30),
            
        ])
        
        return view
    }
    
    // MARK: - Actions
    
    /// Purpose: Handles the change project button tap.
    /// Parameters:
    ///   - sender: The button that was tapped
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Navigation back to project selection is triggered
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: UI interaction
    @objc private func changeProjectButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("PipelineOptimizationViewController.changeProjectButtonTapped")
        Logger.shared.uiEvent("buttonTapped", component: "changeProjectButton")
        
        // Delegate to coordinator instead of NotificationCenter
        delegate?.changeProjectRequested()
        
        Logger.shared.methodExit("PipelineOptimizationViewController.changeProjectButtonTapped")
    }
    
    /// Purpose: Handles pipeline option checkbox changes.
    /// Parameters:
    ///   - sender: The checkbox that was changed
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Pipeline selection state is updated
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: UI interaction
    @objc private func pipelineOptionChanged(_ sender: NSButton) {
        Logger.shared.methodEntry("PipelineOptimizationViewController.pipelineOptionChanged")
        Logger.shared.uiEvent("checkboxChanged", component: "pipelineOption", metadata: ["title": sender.title, "state": sender.state.rawValue])
        
        // Show popup when checkbox is selected (checked)
        if sender.state == .on {
            showPopupForOption(sender.title)
        }
        
        // Update button state based on selections
        let hasSelections = pipelineCheckboxes.contains { $0.state == .on }
        
        Logger.shared.debug("Pipeline selection updated", category: .pipeline, metadata: ["hasSelections": hasSelections])
        Logger.shared.methodExit("PipelineOptimizationViewController.pipelineOptionChanged")
    }
    
    /// Purpose: Handles the optimize button tap.
    /// Parameters:
    ///   - sender: The button that was tapped
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Pipeline optimization is initiated
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: UI interaction
    
    /// Purpose: Handles the security scan button tap.
    /// Parameters:
    ///   - sender: The button that was tapped
    /// Returns: Void
    /// Preconditions: Project is selected and Semgrep is available
    /// Postconditions:
    /// - Security scan is initiated
    /// - Results are displayed in a new window
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: UI interaction
    @objc private func securityScanButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("PipelineOptimizationViewController.securityScanButtonTapped")
        Logger.shared.uiEvent("buttonTapped", component: "securityScanButton")
        
        guard let projectPath = model?.selectedFolderPath else {
            Logger.shared.warning("No project selected for security scan")
            return
        }
        
        // Initialize scanner if needed
        if semgrepScanner == nil {
            semgrepScanner = SemgrepScanner()
        }
        
        // Show progress indicator
        showScanProgress()
        
        // Run security scan
        semgrepScanner?.scanProject(at: projectPath) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideScanProgress()
                
                switch result {
                case .success(let scanResults):
                    self?.showScanResults(scanResults)
                    Logger.shared.info("Security scan completed successfully", metadata: [
                        "totalFindings": scanResults.totalFindings,
                        "critical": scanResults.criticalCount,
                        "high": scanResults.highCount
                    ])
                    
                case .failure(let error):
                    self?.showScanError(error)
                    Logger.shared.error("Security scan failed", metadata: ["error": "\(error)"])
                }
            }
        }
        
        Logger.shared.methodExit("PipelineOptimizationViewController.securityScanButtonTapped")
    }
    
    // MARK: - Popup Management
    
    /// Purpose: Shows a popup window for the selected pipeline option.
    /// Parameters:
    ///   - optionTitle: The title of the selected pipeline option
    /// Returns: Void
    /// Preconditions: Option title exists in pipelineOptionDetails
    /// Postconditions:
    /// - Popup window is displayed with option details
    /// - Previous popup is closed if open
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: pipelineOptionChanged
    private func showPopupForOption(_ optionTitle: String) {
        Logger.shared.methodEntry("PipelineOptimizationViewController.showPopupForOption", parameters: ["optionTitle": optionTitle])
        
        // Close any existing popup
        closeCurrentPopup()
        
        // Get option details
        guard let optionDetails = pipelineOptionDetails[optionTitle] else {
            Logger.shared.warning("No details found for pipeline option", category: .ui, metadata: ["optionTitle": optionTitle])
            return
        }
        
        // Create and show popup
        let template = getTemplateForOption(optionTitle)
        currentPopup = PopupWindowController(
            title: optionTitle,
            description: optionDetails.description,
            details: optionDetails.details,
            jenkinsTemplate: template
        )
        
        currentPopup?.showPopup()
        
        Logger.shared.uiEvent("popupShown", component: "pipelineOption", metadata: ["optionTitle": optionTitle])
        Logger.shared.methodExit("PipelineOptimizationViewController.showPopupForOption")
    }
    
    /// Purpose: Closes the current popup window if one is open.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Current popup is closed and reference is cleared
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: showPopupForOption, deinit
    private func closeCurrentPopup() {
        if let popup = currentPopup {
            Logger.shared.methodEntry("PipelineOptimizationViewController.closeCurrentPopup")
            popup.close()
            currentPopup = nil
            Logger.shared.methodExit("PipelineOptimizationViewController.closeCurrentPopup")
        }
    }
    
    /// Purpose: Returns the template for the specified CI/CD option.
    /// Parameters:
    ///   - optionTitle: The title of the CI/CD option
    /// Returns: Template string for the option, or nil if not supported
    /// Preconditions: None
    /// Postconditions: Template is returned for supported options
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: showPopupForOption
    func getTemplateForOption(_ optionTitle: String) -> String? {
        if optionTitle.contains("Jenkins") {
            return getJenkinsTemplate()
        } else if optionTitle.contains("GitHub Actions") {
            return getGitHubActionsTemplate()
        } else if optionTitle.contains("GitLab CI") {
            return getGitLabCITemplate()
        } else if optionTitle.contains("CircleCI") {
            return getCircleCITemplate()
        } else if optionTitle.contains("Bitrise") {
            return getBitriseTemplate()
        } else if optionTitle.contains("Azure Pipelines") {
            return getAzurePipelinesTemplate()
        } else if optionTitle.contains("Codemagic") {
            return getCodemagicTemplate()
        } else if optionTitle.contains("Travis CI") {
            return getTravisCITemplate()
        }
        return nil
    }
    
    /// Purpose: Returns the Jenkins file template.
    /// Parameters: None
    /// Returns: Jenkins file template string
    /// Preconditions: None
    /// Postconditions: Jenkins template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: getTemplateForOption
    private func getJenkinsTemplate() -> String {
        return """
pipeline {
  // ===== Top-level placeholders =====
  agent { label '__RUNNER_LABEL__' } // e.g. 'macos' or 'macos-self-hosted'

  options {
    timestamps()
    ansiColor('xterm')
    timeout(time: __TIMEOUT_MINUTES__, unit: 'MINUTES') // e.g. 30
    disableConcurrentBuilds()
  }

  // Optional cron trigger (uncomment and set)
  // triggers { cron('__CRON_SCHEDULE__') } // e.g. 'H 11 * * 1'  (UTC)

  environment {
    // --- Build identifiers ---
    SCHEME            = '__SCHEME__'          // if empty, auto-detect first shared scheme
    WORKSPACE_PATH    = '__WORKSPACE_PATH__'  // e.g. 'App.xcworkspace' or leave empty to auto-detect
    PROJECT_PATH      = '__PROJECT_PATH__'    // e.g. 'App.xcodeproj'  or leave empty to auto-detect
    CONFIGURATION     = '__CONFIGURATION__'   // e.g. 'Debug' or 'Release' (default Debug)
    CLEAN_BEFORE_BUILD= '__CLEAN__'           // 'YES' or 'NO' (default YES)

    // --- Tooling ---
    XCODE_VERSION     = '__XCODE_VERSION__'   // e.g. '15.4' (switches to /Applications/Xcode_15.4.app if set)

    // --- Simulator / testing ---
    DESTINATION       = '__DESTINATION__'     // e.g. 'platform=iOS Simulator,name=iPhone 15,OS=18.5'
    PARALLEL_TESTS    = '__PARALLEL_TESTS__'  // 'YES' or 'NO'
    SHARD_COUNT       = '__SHARD_COUNT__'     // integer as string, optional

    // --- Dependencies ---
    USE_SPM_CACHE     = '__USE_SPM_CACHE__'   // 'YES' or 'NO' (placeholder hook)
    USE_COCOAPODS     = '__USE_COCOAPODS__'   // 'YES' or 'NO'
    USE_CARTHAGE      = '__USE_CARTHAGE__'    // 'YES' or 'NO'
    CUSTOM_BOOTSTRAP  = '__CUSTOM_BOOTSTRAP__'// optional command

    // --- Signing / deploy (optional) ---
    ENABLE_SIGNING    = '__ENABLE_SIGNING__'  // 'YES' or 'NO'
    TESTFLIGHT_UPLOAD = '__TESTFLIGHT__'      // 'YES' or 'NO'
    ASC_API_KEY_ID    = '__ASC_API_KEY_CRED_ID__' // Jenkins credentials ID
    TEAM_ID           = '__APPLE_TEAM_ID__'
    BUNDLE_ID         = '__BUNDLE_ID__'

    // --- Artifacts / notifications (optional) ---
    ARTIFACT_RETENTION_DAYS = '__ARTIFACT_DAYS__' // e.g. '7' (informational)
    SLACK_CHANNEL     = '__SLACK_CHANNEL__'  // e.g. '#ci'
    SLACK_WEBHOOK_ID  = '__SLACK_WEBHOOK_CRED_ID__' // Jenkins credentials ID
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup') {
      steps {
        sh '''
          set -euo pipefail
          if [ -n "${XCODE_VERSION}" ] && [ -d "/Applications/Xcode_${XCODE_VERSION}.app" ]; then
            sudo xcode-select -s "/Applications/Xcode_${XCODE_VERSION}.app"
          fi
        '''
        // <HOOK:PRE-DEPS-STEPS>
      }
    }

    stage('Dependencies') {
      steps {
        sh '''
          set -euo pipefail

          # SwiftPM (always safe to resolve)
          if [ -f "Package.swift" ]; then
            xcrun swift package resolve
          fi

          # CocoaPods
          if [ "${USE_COCOAPODS:-NO}" = "YES" ] && [ -f "Podfile" ]; then
            if command -v bundle >/dev/null 2>&1 && [ -f "Gemfile" ]; then
              bundle install --path vendor/bundle
              bundle exec pod install --repo-update
            else
              pod install --repo-update
            fi
          fi

          # Carthage (XCFrameworks recommended)
          if [ "${USE_CARTHAGE:-NO}" = "YES" ] && [ -f "Cartfile" ]; then
            carthage bootstrap --use-xcframeworks --platform iOS
          fi

          # Custom bootstrap hook
          if [ -n "${CUSTOM_BOOTSTRAP}" ]; then
            eval "${CUSTOM_BOOTSTRAP}"
          fi
        '''
      }
    }

    stage('Build') {
      steps {
        sh '''
          set -euo pipefail

          # Detect workspace/project if placeholders are blank
          WS="${WORKSPACE_PATH}"
          PJ="${PROJECT_PATH}"
          if [ -z "$WS" ]; then WS=$(ls -1 *.xcworkspace 2>/dev/null | head -n1 || true); fi
          if [ -z "$PJ" ]; then PJ=$(ls -1 *.xcodeproj   2>/dev/null | head -n1 || true); fi

          # Discover a default scheme if not provided
          SC="${SCHEME}"
          if [ -z "$SC" ]; then
            if [ -n "$WS" ]; then
              LIST=$(xcodebuild -list -json -workspace "$WS")
            else
              LIST=$(xcodebuild -list -json -project "$PJ")
            fi
            SC=$(python3 - <<'PY' "$LIST"
import json,sys
j=json.loads(sys.argv[1])
s=j.get("workspace",{}).get("schemes") or j.get("project",{}).get("schemes") or []
print(s[0] if s else(""))
PY
)
          fi
          [ -n "$SC" ] || { echo "No shared schemes found"; exit 1; }

          CFG="${CONFIGURATION:-Debug}"
          CLEAN="${CLEAN_BEFORE_BUILD:-YES}"

          # Build
          if [ -n "$WS" ]; then SRC_OPTS=(-workspace "$WS"); else SRC_OPTS=(-project "$PJ"); fi
          CMD=(xcodebuild "${SRC_OPTS[@]}" -scheme "$SC" -configuration "$CFG")
          if [ "$CLEAN" = "YES" ]; then CMD+=("clean"); fi
          CMD+=("build")

          echo "Building: ${CMD[*]}"
          "${CMD[@]}" | tee build.log
        '''
        // <HOOK:POST-BUILD-STEPS>
      }
    }

    stage('Test') {
      steps {
        sh '''
          set -euo pipefail

          # Resolve WS/PJ and scheme again for clarity
          WS=$(ls -1 *.xcworkspace 2>/dev/null | head -n1 || true)
          PJ=$(ls -1 *.xcodeproj   2>/dev/null | head -n1 || true)
          SC="${SCHEME}"
          if [ -z "$SC" ]; then
            if [ -n "$WS" ]; then
              LIST=$(xcodebuild -list -json -workspace "$WS")
            else
              LIST=$(xcodebuild -list -json -project "$PJ")
            fi
            SC=$(python3 - <<'PY' "$LIST"
import json,sys
j=json.loads(sys.argv[1])
s=j.get("workspace",{}).get("schemes") or j.get("project",{}).get("schemes") or []
print(s[0] if s else(""))
PY
)
          fi

          DEST="${DESTINATION:-platform=iOS Simulator,name=iPhone 15,OS=latest}"
          PAR="${PARALLEL_TESTS:-NO}"

          xcodebuild ${WS:+-workspace "$WS"} ${PJ:+-project "$PJ"} -scheme "$SC" \\
            -destination "$DEST" \\
            -parallel-testing-enabled $PAR \\
            test -resultBundlePath build/Results.xcresult | tee test.log

          # Zip result bundle for archiving
          if [ -d "build/Results.xcresult" ]; then
            ditto -c -k --sequesterRsrc --keepParent build/Results.xcresult build/Results.xcresult.zip
          fi
        '''
        // <HOOK:POST-TEST-STEPS>
      }
      post {
        always {
          junit '**/reports/**/*.xml' // if you generate JUnit; safe if absent
          archiveArtifacts artifacts: 'build/Results.xcresult.zip, build.log, test.log, **/*.dSYM.zip',
                           fingerprint: true, allowEmptyArchive: true
        }
      }
    }

    stage('Quality Gates') {
      when { expression { return false /* set to true when ready */ } }
      steps {
        // <HOOK:QUALITY-GATES> // e.g., SwiftLint, Sonar
        echo 'Quality gates placeholder'
      }
    }

    stage('Deploy (TestFlight)') {
      when { expression { return env.TESTFLIGHT_UPLOAD == 'YES' } }
      steps {
        // Example: requires Fastlane and credentials configured
        sh '''
          set -euo pipefail
          bundle exec fastlane beta \\
            --env ios \\
            --verbose
        '''
      }
    }
  }

  post {
    failure {
      script {
        // Optional Slack notification hook:
        // withCredentials([string(credentialsId: env.SLACK_WEBHOOK_ID, variable: 'SLACK_WEBHOOK')]) {
        //   sh 'curl -X POST -H "Content-type: application/json" --data "{\\"text\\": \\"Jenkins build failed: ${BUILD_URL}\\"}" "$SLACK_WEBHOOK"'
        // }
      }
    }
    cleanup {
      cleanWs()
    }
  }
}
"""
    }
    
    /// Purpose: Returns the GitHub Actions workflow template.
    /// Parameters: None
    /// Returns: GitHub Actions workflow template string
    /// Preconditions: None
    /// Postconditions: GitHub Actions template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: getTemplateForOption
    private func getGitHubActionsTemplate() -> String {
        return """
name: __WORKFLOW_NAME__

on:
  __TRIGGER_EVENTS__
    branches: [ __BRANCHES__ ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Select Xcode Version
      run: sudo xcode-select -s /Applications/Xcode___XCODE_VERSION__.app
    
    - name: Setup Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: __XCODE_VERSION__
    
    - name: Cache Swift Package Manager
      uses: actions/cache@v3
      with:
        path: .build
        key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
        restore-keys: |
          ${{ runner.os }}-spm-
    
    - name: Install Dependencies
      run: |
        if [ -f "Package.swift" ]; then
          xcrun swift package resolve
        fi
        if [ "__USE_COCOAPODS__" = "YES" ] && [ -f "Podfile" ]; then
          pod install --repo-update
        fi
        if [ "__USE_CARTHAGE__" = "YES" ] && [ -f "Cartfile" ]; then
          carthage bootstrap --use-xcframeworks --platform iOS
        fi
    
    - name: Build
      run: |
        xcodebuild -scheme __SCHEME__ -configuration __CONFIGURATION__ -destination "__DESTINATION__" build
    
    - name: Test
      run: |
        xcodebuild -scheme __SCHEME__ -configuration __CONFIGURATION__ -destination "__DESTINATION__" test
    
    - name: Upload Test Results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: build/Results.xcresult
"""
    }
    
    /// Purpose: Returns the GitLab CI pipeline template.
    /// Parameters: None
    /// Returns: GitLab CI pipeline template string
    /// Preconditions: None
    /// Postconditions: GitLab CI template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: getTemplateForOption
    private func getGitLabCITemplate() -> String {
        return """
stages:
  - build
  - test
  - deploy

variables:
  XCODE_VERSION: "__XCODE_VERSION__"
  SCHEME: "__SCHEME__"
  CONFIGURATION: "__CONFIGURATION__"
  DESTINATION: "__DESTINATION__"

build:
  stage: build
  image: cimg/xcode:__XCODE_VERSION__
  script:
    - xcodebuild -scheme $SCHEME -configuration $CONFIGURATION -destination "$DESTINATION" build
  artifacts:
    paths:
      - build/
    expire_in: __RETENTION_DAYS__ days

test:
  stage: test
  image: cimg/xcode:__XCODE_VERSION__
  script:
    - xcodebuild -scheme $SCHEME -configuration $CONFIGURATION -destination "$DESTINATION" test
  artifacts:
    paths:
      - build/Results.xcresult
    expire_in: __RETENTION_DAYS__ days
  coverage: '/Code coverage: \\d+\\.\\d+%/'

deploy:
  stage: deploy
  image: cimg/xcode:__XCODE_VERSION__
  script:
    - echo "Deployment steps would go here"
  only:
    - main
"""
    }
    
    /// Purpose: Returns the CircleCI pipeline template.
    /// Parameters: None
    /// Returns: CircleCI pipeline template string
    /// Preconditions: None
    /// Postconditions: CircleCI template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: getTemplateForOption
    private func getCircleCITemplate() -> String {
        return """
version: 2.1

jobs:
  build:
    macos:
      xcode: "__XCODE_VERSION__"
    resource_class: __RESOURCE_CLASS__
    parallelism: __PARALLELISM__
    steps:
      - checkout
      - restore_cache:
          keys:
            - v1-deps-{{ checksum "Package.resolved" }}
            - v1-deps-
      - run:
          name: Install Dependencies
          command: |
            if [ -f "Package.swift" ]; then
              xcrun swift package resolve
            fi
            if [ "__USE_COCOAPODS__" = "YES" ] && [ -f "Podfile" ]; then
              pod install --repo-update
            fi
            if [ "__USE_CARTHAGE__" = "YES" ] && [ -f "Cartfile" ]; then
              carthage bootstrap --use-xcframeworks --platform iOS
            fi
      - save_cache:
          key: v1-deps-{{ checksum "Package.resolved" }}
          paths:
            - .build
      - run:
          name: Build
          command: |
            xcodebuild -scheme __SCHEME__ -configuration __CONFIGURATION__ -destination "__DESTINATION__" build
      - run:
          name: Test
          command: |
            xcodebuild -scheme __SCHEME__ -configuration __CONFIGURATION__ -destination "__DESTINATION__" test
      - store_test_results:
          path: build/Results.xcresult
      - store_artifacts:
          path: build/
          destination: build

workflows:
  __WORKFLOW_NAME__:
    jobs:
      - build
"""
    }
    
    /// Purpose: Returns the Bitrise pipeline template.
    /// Parameters: None
    /// Returns: Bitrise pipeline template string
    /// Preconditions: None
    /// Postconditions: Bitrise template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: getTemplateForOption
    private func getBitriseTemplate() -> String {
        return """
format_version: '11'
default_step_lib_source: https://github.com/bitrise-io/bitrise-steplib.git

workflows:
  __WORKFLOW_NAME__:
    steps:
    - activate-ssh-key@4:
        run_if: '{{getenv "SSH_RSA_PRIVATE_KEY" | ne ""}}'
    - git-clone@7: {}
    - cache-pull@2: {}
    - certificate-and-profile-installer@3: {}
    - xcode-archive@4:
        inputs:
        - project_path: __PROJECT_PATH__
        - scheme: __SCHEME__
        - configuration: __CONFIGURATION__
        - export_method: development
    - xcode-test@4:
        inputs:
        - project_path: __PROJECT_PATH__
        - scheme: __SCHEME__
        - destination: __DESTINATION__
    - cache-push@2: {}
    - deploy-to-bitrise-io@2: {}
"""
    }
    
    /// Purpose: Returns the Azure Pipelines template.
    /// Parameters: None
    /// Returns: Azure Pipelines template string
    /// Preconditions: None
    /// Postconditions: Azure Pipelines template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: getTemplateForOption
    private func getAzurePipelinesTemplate() -> String {
        return """
trigger:
  branches:
    include:
    - __TRIGGER_BRANCHES__

pool:
  vmImage: '__VM_IMAGE__'

variables:
  XCODE_VERSION: '__XCODE_VERSION__'
  SCHEME: '__SCHEME__'
  CONFIGURATION: '__CONFIGURATION__'
  DESTINATION: '__DESTINATION__'

stages:
- stage: Build
  displayName: Build stage
  jobs:
  - job: Build
    displayName: Build
    steps:
    - task: Xcode@5
      displayName: 'Build Xcode Project'
      inputs:
        actions: 'build'
        configuration: '$(CONFIGURATION)'
        sdk: 'iphoneos'
        xcWorkspacePath: '$(Build.SourcesDirectory)/*.xcworkspace'
        scheme: '$(SCHEME)'
        packageApp: true
        exportPath: '$(build.artifactStagingDirectory)'
        exportOptions: 'plist'
        exportOptionsPlist: '$(Build.SourcesDirectory)/ExportOptions.plist'

- stage: Test
  displayName: Test stage
  jobs:
  - job: Test
    displayName: Test
    steps:
    - task: Xcode@5
      displayName: 'Test Xcode Project'
      inputs:
        actions: 'test'
        configuration: '$(CONFIGURATION)'
        sdk: 'iphonesimulator'
        xcWorkspacePath: '$(Build.SourcesDirectory)/*.xcworkspace'
        scheme: '$(SCHEME)'
        destinationPlatformOption: 'iOS'
        destinationSimulators: '__DESTINATION__'
"""
    }
    
    /// Purpose: Returns the Codemagic template.
    /// Parameters: None
    /// Returns: Codemagic template string
    /// Preconditions: None
    /// Postconditions: Codemagic template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: getTemplateForOption
    private func getCodemagicTemplate() -> String {
        return """
workflows:
  __WORKFLOW_NAME__:
    name: __WORKFLOW_NAME__
    max_build_duration: __MAX_BUILD_DURATION__
    environment:
      vars:
        XCODE_WORKSPACE: "*.xcworkspace"
        XCODE_SCHEME: "__SCHEME__"
        BUNDLE_ID: "__BUNDLE_ID__"
      xcode: __XCODE_VERSION__
      cocoapods: default
    scripts:
      - name: Set up keychain to be used for codesigning
        script: |
          keychain initialize
      - name: Fetch signing files
        script: |
          app-store-connect fetch-signing-files __BUNDLE_ID__ --type IOS_APP_STORE --create
      - name: Set up signing certificate
        script: |
          keychain add-certificates
      - name: Set up provisioning profile
        script: |
          keychain add-profiles
      - name: Increment build number
        script: |
          agvtool new-version -all $(($(agvtool vers-version -all | tail -1 | cut -d ' ' -f 3) + 1))
      - name: Build ipa for distribution
        script: |
          xcode-project build-ipa \
            --workspace "$XCODE_WORKSPACE" \
            --scheme "$XCODE_SCHEME" \
            --codesigning-files "*.p12" \
            --provisioning-profiles "*.mobileprovision"
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - $HOME/Library/Developer/Xcode/DerivedData/**/Build/**/*.app
      - $HOME/Library/Developer/Xcode/DerivedData/**/Build/**/*.dSYM
    publishing:
      email:
        recipients:
          - user@example.com
        notify:
          success: true
          failure: false
      app_store_connect:
        auth: integration
        submit_to_testflight: __TESTFLIGHT_UPLOAD__
"""
    }
    
    /// Purpose: Returns the Travis CI template.
    /// Parameters: None
    /// Returns: Travis CI template string
    /// Preconditions: None
    /// Postconditions: Travis CI template is returned
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: getTemplateForOption
    private func getTravisCITemplate() -> String {
        return """
language: __LANGUAGE__
os: __OS__
osx_image: xcode__XCODE_VERSION__

before_install:
  - if [ "__USE_COCOAPODS__" = "YES" ] && [ -f "Podfile" ]; then gem install cocoapods; fi
  - if [ "__USE_CARTHAGE__" = "YES" ] && [ -f "Cartfile" ]; then brew install carthage; fi

install:
  - if [ "__USE_COCOAPODS__" = "YES" ] && [ -f "Podfile" ]; then pod install; fi
  - if [ "__USE_CARTHAGE__" = "YES" ] && [ -f "Cartfile" ]; then carthage bootstrap --use-xcframeworks --platform iOS; fi

script:
  - xcodebuild -scheme __SCHEME__ -configuration __CONFIGURATION__ -destination "__DESTINATION__" build
  - xcodebuild -scheme __SCHEME__ -configuration __CONFIGURATION__ -destination "__DESTINATION__" test

after_success:
  - if [ "__TESTFLIGHT_UPLOAD__" = "YES" ]; then echo "TestFlight upload would go here"; fi

cache:
  directories:
    - DerivedData
    - ~/Library/Developer/Xcode/DerivedData
"""
    }
    
    // MARK: - Security Scan Helpers
    
    /// Purpose: Shows progress indicator during security scan.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Progress indicator is displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: securityScanButtonTapped
    private func showScanProgress() {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.style = .spinning
        progressIndicator.startAnimation(nil)
        progressIndicator.identifier = NSUserInterfaceItemIdentifier("scanProgressIndicator")
        
        view.addSubview(progressIndicator)
        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Disable scan button during scan
        securityScanButton.isEnabled = false
        securityScanButton.title = "🔒 Scanning..."
    }
    
    /// Purpose: Hides progress indicator after security scan.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: Progress indicator is displayed
    /// Postconditions: Progress indicator is removed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: securityScanButtonTapped
    private func hideScanProgress() {
        if let progressIndicator = view.subviews.first(where: { $0.identifier?.rawValue == "scanProgressIndicator" }) {
            progressIndicator.removeFromSuperview()
        }
        
        // Re-enable scan button
        securityScanButton.isEnabled = true
        securityScanButton.title = "🔒 Security Scan"
    }
    
    /// Purpose: Shows security scan results in a new window.
    /// Parameters:
    ///   - scanResults: The results from the security scan
    /// Returns: Void
    /// Preconditions: Scan results are valid
    /// Postconditions: Results window is displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: securityScanButtonTapped
    private func showScanResults(_ scanResults: SemgrepScanner.ScanResults) {
        guard let scanner = semgrepScanner else { return }
        
        // Close existing window if open
        securityScanWindow?.close()
        securityScanWindowDelegate = nil
        
        let resultsViewController = SemgrepResultsViewController(scanResults: scanResults, scanner: scanner)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Security Scan Results"
        window.contentViewController = resultsViewController
        window.center()
        window.isReleasedWhenClosed = false
        
        // Create and store window delegate to handle cleanup
        securityScanWindowDelegate = SecurityScanWindowDelegate { [weak self] in
            self?.securityScanWindow = nil
            self?.securityScanWindowDelegate = nil
        }
        window.delegate = securityScanWindowDelegate
        
        // Store reference to window
        securityScanWindow = window
        
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Purpose: Shows error message for failed security scan.
    /// Parameters:
    ///   - error: The error that occurred during scanning
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Error alert is displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: securityScanButtonTapped
    private func showScanError(_ error: Error) {
        let alert = NSAlert()
        
        if case SemgrepError.semgrepNotAvailable = error {
            alert.messageText = "Semgrep Not Available"
            alert.informativeText = error.localizedDescription
        } else {
            alert.messageText = "Security Scan Failed"
            alert.informativeText = error.localizedDescription
        }
        
        alert.addButton(withTitle: "OK")
        
        if case SemgrepError.notInstalled = error {
            alert.addButton(withTitle: "Install Semgrep")
            alert.buttons[1].target = self
            alert.buttons[1].action = #selector(installSemgrepButtonTapped(_:))
        }
        
        alert.runModal()
    }
    
    /// Purpose: Handles install Semgrep button tap.
    /// Parameters:
    ///   - sender: The button that was tapped
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Installation instructions are shown
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: showScanError
    @objc private func installSemgrepButtonTapped(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = "Install Semgrep"
        alert.informativeText = """
        To install Semgrep, run the following command in Terminal:
        
        pip install semgrep
        
        Or visit: https://semgrep.dev/docs/getting-started/
        """
        alert.addButton(withTitle: "Open Terminal")
        alert.addButton(withTitle: "Open Website")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open Terminal
            if let terminalURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal") {
                NSWorkspace.shared.openApplication(at: terminalURL, configuration: NSWorkspace.OpenConfiguration()) { _, _ in }
            }
        } else if response == .alertSecondButtonReturn {
            // Open website
            if let url = URL(string: "https://semgrep.dev/docs/getting-started/") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Purpose: Sets the project model and updates the UI.
    /// Parameters:
    ///   - model: The project model to use
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Model is set and UI is updated
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: Coordinator
    public func setProjectModel(_ model: ProjectModel) {
        self.model = model
        // Don't update UI here - wait until viewDidLoad completes
    }
    
    /// Purpose: Updates the project label with current project info.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Project label shows current project name
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: setProjectModel, internal updates
    private func updateProjectLabel() {
        guard let projectLabel = projectLabel else {
            Logger.shared.warning("projectLabel is nil, UI not yet initialized", category: .ui)
            return
        }
        
        if let projectPath = model?.selectedFolderPath {
            let projectName = URL(fileURLWithPath: projectPath).lastPathComponent
            projectLabel.stringValue = "Current Project: \(projectName)"
            
            // Enable security scan button when project is selected
            securityScanButton?.isEnabled = true
        } else {
            projectLabel.stringValue = "Current Project: None"
            
            // Disable security scan button when no project is selected
            securityScanButton?.isEnabled = false
        }
    }
    
    // MARK: - Required Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}

// MARK: - Window Delegate

/// Purpose: Handles window lifecycle for security scan results window.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions: Window cleanup is handled properly
/// Throws: Never
/// Complexity: O(1)
/// Used By: PipelineOptimizationViewController
class SecurityScanWindowDelegate: NSObject, NSWindowDelegate {
    private let onWindowClose: () -> Void
    
    init(onWindowClose: @escaping () -> Void) {
        self.onWindowClose = onWindowClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onWindowClose()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let changeProjectRequested = Notification.Name("changeProjectRequested")
    static let optimizePipelinesRequested = Notification.Name("optimizePipelinesRequested")
}
