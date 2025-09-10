import Cocoa

/// Purpose: Displays Semgrep security scan results in a user-friendly interface.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions:
/// - Scan results are displayed with proper categorization
/// - Users can navigate to specific findings and files
/// Throws: Never
/// Complexity: O(1)
/// Used By: PipelineOptimizationViewController
class SemgrepResultsViewController: NSViewController {
    
    // MARK: - Properties
    
    private var scanResults: SemgrepScanner.ScanResults
    private var scanner: SemgrepScanner
    
    // MARK: - UI Elements
    
    private var scrollView: NSScrollView!
    private var contentView: NSView!
    private var summaryStackView: NSStackView!
    private var findingsStackView: NSStackView!
    private var closeButton: NSButton!
    private var rescanButton: NSButton!
    
    // MARK: - Initialization
    
    /// Purpose: Initialize results view with scan data.
    /// Parameters:
    ///   - scanResults: The results from Semgrep scan
    ///   - scanner: The scanner instance for rescanning
    /// Returns: Void
    /// Preconditions: Scan results are valid
    /// Postconditions: View controller is ready to display results
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: PipelineOptimizationViewController
    init(scanResults: SemgrepScanner.ScanResults, scanner: SemgrepScanner) {
        self.scanResults = scanResults
        self.scanner = scanner
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        Logger.shared.methodEntry("SemgrepResultsViewController.viewDidLoad")
        
        setupUI()
        displayResults()
        
        Logger.shared.appLifecycle("SemgrepResultsViewController loaded")
        Logger.shared.methodExit("SemgrepResultsViewController.viewDidLoad")
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
    private func setupUI() {
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
        
        // Create summary stack view
        summaryStackView = NSStackView()
        summaryStackView.translatesAutoresizingMaskIntoConstraints = false
        summaryStackView.orientation = .vertical
        summaryStackView.spacing = 16
        summaryStackView.alignment = .leading
        contentView.addSubview(summaryStackView)
        
        // Create findings stack view
        findingsStackView = NSStackView()
        findingsStackView.translatesAutoresizingMaskIntoConstraints = false
        findingsStackView.orientation = .vertical
        findingsStackView.spacing = 12
        findingsStackView.alignment = .leading
        contentView.addSubview(findingsStackView)
        
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
            
            // Summary stack view constraints
            summaryStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            summaryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Findings stack view constraints
            findingsStackView.topAnchor.constraint(equalTo: summaryStackView.bottomAnchor, constant: 20),
            findingsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            findingsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            findingsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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
    private func setupButtons() {
        let buttonStackView = NSStackView()
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.orientation = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.alignment = .centerY
        view.addSubview(buttonStackView)
        
        // Rescan button
        rescanButton = NSButton()
        rescanButton.translatesAutoresizingMaskIntoConstraints = false
        rescanButton.bezelStyle = .rounded
        rescanButton.title = "Rescan"
        rescanButton.target = self
        rescanButton.action = #selector(rescanButtonTapped(_:))
        buttonStackView.addArrangedSubview(rescanButton)
        
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
    
    // MARK: - Display Methods
    
    /// Purpose: Display the scan results in the UI.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: Scan results are available
    /// Postconditions: Results are displayed in the UI
    /// Throws: Never
    /// Complexity: O(n) where n is the number of findings
    /// Used By: viewDidLoad
    private func displayResults() {
        // Clear existing content
        summaryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        findingsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Display summary
        displaySummary()
        
        // Display findings
        displayFindings()
    }
    
    /// Purpose: Display scan summary information.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Summary is displayed
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: displayResults
    private func displaySummary() {
        // Title
        let titleLabel = NSTextField(labelWithString: "Security Scan Results")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = NSColor.labelColor
        summaryStackView.addArrangedSubview(titleLabel)
        
        // Project path
        let pathLabel = NSTextField(labelWithString: "Project: \(scanResults.projectPath)")
        pathLabel.translatesAutoresizingMaskIntoConstraints = false
        pathLabel.font = NSFont.systemFont(ofSize: 14)
        pathLabel.textColor = NSColor.secondaryLabelColor
        summaryStackView.addArrangedSubview(pathLabel)
        
        // Scan date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateLabel = NSTextField(labelWithString: "Scanned: \(dateFormatter.string(from: scanResults.scanDate))")
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = NSFont.systemFont(ofSize: 14)
        dateLabel.textColor = NSColor.secondaryLabelColor
        summaryStackView.addArrangedSubview(dateLabel)
        
        // Duration
        let durationLabel = NSTextField(labelWithString: "Duration: \(String(format: "%.2f", scanResults.scanDuration))s")
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = NSFont.systemFont(ofSize: 14)
        durationLabel.textColor = NSColor.secondaryLabelColor
        summaryStackView.addArrangedSubview(durationLabel)
        
        // Summary stats
        let statsStackView = NSStackView()
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        statsStackView.orientation = .horizontal
        statsStackView.spacing = 20
        statsStackView.alignment = .centerY
        
        let totalLabel = createStatLabel(title: "Total", count: scanResults.totalFindings, color: .labelColor)
        let criticalLabel = createStatLabel(title: "Critical", count: scanResults.criticalCount, color: .systemRed)
        let highLabel = createStatLabel(title: "High", count: scanResults.highCount, color: .systemOrange)
        let mediumLabel = createStatLabel(title: "Medium", count: scanResults.mediumCount, color: .systemYellow)
        let lowLabel = createStatLabel(title: "Low", count: scanResults.lowCount, color: .systemBlue)
        
        statsStackView.addArrangedSubview(totalLabel)
        statsStackView.addArrangedSubview(criticalLabel)
        statsStackView.addArrangedSubview(highLabel)
        statsStackView.addArrangedSubview(mediumLabel)
        statsStackView.addArrangedSubview(lowLabel)
        
        summaryStackView.addArrangedSubview(statsStackView)
    }
    
    /// Purpose: Create a stat label for the summary.
    /// Parameters:
    ///   - title: The stat title
    ///   - count: The count value
    ///   - color: The text color
    /// Returns: Configured label
    /// Preconditions: None
    /// Postconditions: Label is created and configured
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: displaySummary
    private func createStatLabel(title: String, count: Int, color: NSColor) -> NSTextField {
        let label = NSTextField(labelWithString: "\(title): \(count)")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = color
        return label
    }
    
    /// Purpose: Display all findings in the UI.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Findings are displayed
    /// Throws: Never
    /// Complexity: O(n) where n is the number of findings
    /// Used By: displayResults
    private func displayFindings() {
        if scanResults.findings.isEmpty {
            let noFindingsLabel = NSTextField(labelWithString: "✅ No security issues found!")
            noFindingsLabel.translatesAutoresizingMaskIntoConstraints = false
            noFindingsLabel.font = NSFont.systemFont(ofSize: 18, weight: .medium)
            noFindingsLabel.textColor = NSColor.systemGreen
            findingsStackView.addArrangedSubview(noFindingsLabel)
            return
        }
        
        // Group findings by severity
        let groupedFindings = Dictionary(grouping: scanResults.findings) { $0.severity }
        let sortedSeverities = SemgrepScanner.Finding.Severity.allCases.filter { groupedFindings[$0] != nil }
        
        for severity in sortedSeverities {
            guard let findings = groupedFindings[severity] else { continue }
            
            // Severity header
            let severityHeader = createSeverityHeader(severity: severity, count: findings.count)
            findingsStackView.addArrangedSubview(severityHeader)
            
            // Individual findings
            for finding in findings {
                let findingView = createFindingView(finding: finding)
                findingsStackView.addArrangedSubview(findingView)
            }
        }
    }
    
    /// Purpose: Create a severity header view.
    /// Parameters:
    ///   - severity: The severity level
    ///   - count: Number of findings
    /// Returns: Configured header view
    /// Preconditions: None
    /// Postconditions: Header view is created
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: displayFindings
    private func createSeverityHeader(severity: SemgrepScanner.Finding.Severity, count: Int) -> NSView {
        let headerView = NSView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.wantsLayer = true
        headerView.layer?.backgroundColor = severity.color.withAlphaComponent(0.1).cgColor
        headerView.layer?.cornerRadius = 8
        
        let titleLabel = NSTextField(labelWithString: "\(severity.displayName) (\(count))")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = severity.color
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16)
        ])
        
        return headerView
    }
    
    /// Purpose: Create a finding view for display.
    /// Parameters:
    ///   - finding: The finding to display
    /// Returns: Configured finding view
    /// Preconditions: None
    /// Postconditions: Finding view is created
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: displayFindings
    private func createFindingView(finding: SemgrepScanner.Finding) -> NSView {
        let findingView = NSView()
        findingView.translatesAutoresizingMaskIntoConstraints = false
        findingView.wantsLayer = true
        findingView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        findingView.layer?.cornerRadius = 6
        findingView.layer?.borderWidth = 1
        findingView.layer?.borderColor = finding.severity.color.withAlphaComponent(0.3).cgColor
        
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        findingView.addSubview(stackView)
        
        // Rule ID and message
        let ruleLabel = NSTextField(labelWithString: "\(finding.ruleId): \(finding.message)")
        ruleLabel.translatesAutoresizingMaskIntoConstraints = false
        ruleLabel.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        ruleLabel.textColor = NSColor.labelColor
        ruleLabel.isEditable = false
        ruleLabel.isBordered = false
        ruleLabel.backgroundColor = .clear
        ruleLabel.cell?.wraps = true
        stackView.addArrangedSubview(ruleLabel)
        
        // File path and line number
        let locationLabel = NSTextField(labelWithString: "📁 \(finding.filePath):\(finding.lineNumber):\(finding.columnNumber)")
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        locationLabel.textColor = NSColor.secondaryLabelColor
        locationLabel.isEditable = false
        locationLabel.isBordered = false
        locationLabel.backgroundColor = .clear
        stackView.addArrangedSubview(locationLabel)
        
        // Code snippet
        let codeLabel = NSTextField(labelWithString: finding.codeSnippet)
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        codeLabel.textColor = NSColor.labelColor
        codeLabel.isEditable = false
        codeLabel.isBordered = false
        codeLabel.backgroundColor = NSColor.textBackgroundColor
        codeLabel.cell?.wraps = true
        stackView.addArrangedSubview(codeLabel)
        
        // Fix suggestion (if available)
        if let fix = finding.fix, !fix.isEmpty {
            let fixLabel = NSTextField(labelWithString: "💡 Fix: \(fix)")
            fixLabel.translatesAutoresizingMaskIntoConstraints = false
            fixLabel.font = NSFont.systemFont(ofSize: 12)
            fixLabel.textColor = NSColor.systemGreen
            fixLabel.isEditable = false
            fixLabel.isBordered = false
            fixLabel.backgroundColor = .clear
            fixLabel.cell?.wraps = true
            stackView.addArrangedSubview(fixLabel)
        }
        
        NSLayoutConstraint.activate([
            findingView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            stackView.topAnchor.constraint(equalTo: findingView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: findingView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: findingView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: findingView.bottomAnchor, constant: -12)
        ])
        
        return findingView
    }
    
    // MARK: - Actions
    
    /// Purpose: Handle rescan button tap.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: New scan is initiated
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: rescanButton
    @objc private func rescanButtonTapped(_ sender: NSButton) {
        Logger.shared.methodEntry("SemgrepResultsViewController.rescanButtonTapped")
        
        // Show progress indicator
        let progressIndicator = NSProgressIndicator()
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.style = .spinning
        progressIndicator.startAnimation(nil)
        view.addSubview(progressIndicator)
        
        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Run new scan
        scanner.scanProject(at: scanResults.projectPath) { [weak self] result in
            DispatchQueue.main.async {
                progressIndicator.removeFromSuperview()
                
                switch result {
                case .success(let newResults):
                    self?.scanResults = newResults
                    self?.displayResults()
                    Logger.shared.info("Rescan completed successfully")
                    
                case .failure(let error):
                    let alert = NSAlert()
                    alert.messageText = "Rescan Failed"
                    alert.informativeText = error.localizedDescription
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                    Logger.shared.error("Rescan failed", metadata: ["error": "\(error)"])
                }
            }
        }
        
        Logger.shared.methodExit("SemgrepResultsViewController.rescanButtonTapped")
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
        Logger.shared.methodEntry("SemgrepResultsViewController.closeButtonTapped")
        
        // Properly dismiss the window
        if let window = view.window {
            window.performClose(nil)
        }
        
        Logger.shared.methodExit("SemgrepResultsViewController.closeButtonTapped")
    }
    
}
