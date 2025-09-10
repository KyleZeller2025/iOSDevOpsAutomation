import Foundation
import os
import Cocoa

/// Purpose: Manages Semgrep security scanning for iOS projects.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions:
/// - Security vulnerabilities are identified and reported
/// - Scan results are formatted for display
/// Throws: Never
/// Complexity: O(1)
/// Used By: PipelineOptimizationViewController
class SemgrepScanner {
    
    // MARK: - Properties
    
    private let logger = os.Logger(subsystem: "com.KyleZeller.iOSDevOpsAutomation", category: "SemgrepScanner")
    
    // MARK: - Scan Result Models
    
    /// Purpose: Represents a single Semgrep finding.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Finding data is structured
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: SemgrepScanner
    struct Finding {
        let ruleId: String
        let message: String
        let severity: Severity
        let filePath: String
        let lineNumber: Int
        let columnNumber: Int
        let codeSnippet: String
        let fix: String?
        let confidence: String
        let impact: String
        let likelihood: String
        
        enum Severity: String, CaseIterable {
            case critical = "ERROR"
            case high = "WARNING"
            case medium = "INFO"
            case low = "LOW"
            
            var displayName: String {
                switch self {
                case .critical: return "Critical"
                case .high: return "High"
                case .medium: return "Medium"
                case .low: return "Low"
                }
            }
            
            var color: NSColor {
                switch self {
                case .critical: return .systemRed
                case .high: return .systemOrange
                case .medium: return .systemYellow
                case .low: return .systemBlue
                }
            }
        }
    }
    
    /// Purpose: Represents the complete scan results.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Scan results are organized
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: SemgrepScanner
    struct ScanResults {
        let findings: [Finding]
        let totalFindings: Int
        let criticalCount: Int
        let highCount: Int
        let mediumCount: Int
        let lowCount: Int
        let scanDuration: TimeInterval
        let projectPath: String
        let scanDate: Date
        
        var hasFindings: Bool {
            return totalFindings > 0
        }
        
        var criticalFindings: [Finding] {
            return findings.filter { $0.severity == .critical }
        }
        
        var highFindings: [Finding] {
            return findings.filter { $0.severity == .high }
        }
        
        var mediumFindings: [Finding] {
            return findings.filter { $0.severity == .medium }
        }
        
        var lowFindings: [Finding] {
            return findings.filter { $0.severity == .low }
        }
    }
    
    // MARK: - Public Methods
    
    /// Purpose: Scans an iOS project for security vulnerabilities using Semgrep.
    /// Parameters:
    ///   - projectPath: Path to the iOS project directory
    ///   - completion: Completion handler with scan results
    /// Returns: Void
    /// Preconditions: Project path exists and is valid
    /// Postconditions: Scan is executed and results are returned
    /// Throws: Never
    /// Complexity: O(n) where n is the number of files scanned
    /// Used By: PipelineOptimizationViewController
    func scanProject(at projectPath: String, completion: @escaping (Result<ScanResults, Error>) -> Void) {
        logger.info("Starting Semgrep scan for project: \(projectPath)")
        
        let startTime = Date()
        
        // Check if Semgrep is available
        guard isSemgrepAvailable() else {
            logger.error("Semgrep is not available")
            completion(.failure(SemgrepError.notInstalled))
            return
        }
        
        // Run Semgrep scan
        runSemgrepScan(projectPath: projectPath) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let rawOutput):
                DispatchQueue.global(qos: .userInitiated).async {
                    let scanDuration = Date().timeIntervalSince(startTime)
                    let findings = self.parseSemgrepOutput(rawOutput, projectPath: projectPath)
                    let scanResults = ScanResults(
                        findings: findings,
                        totalFindings: findings.count,
                        criticalCount: findings.filter { $0.severity == .critical }.count,
                        highCount: findings.filter { $0.severity == .high }.count,
                        mediumCount: findings.filter { $0.severity == .medium }.count,
                        lowCount: findings.filter { $0.severity == .low }.count,
                        scanDuration: scanDuration,
                        projectPath: projectPath,
                        scanDate: Date()
                    )

                    self.logger.info("Semgrep scan completed - Total: \(scanResults.totalFindings), Critical: \(scanResults.criticalCount), High: \(scanResults.highCount), Duration: \(String(format: "%.2f", scanDuration))s")

                    DispatchQueue.main.async {
                        completion(.success(scanResults))
                    }
                }

            case .failure(let error):
                self.logger.error("Semgrep scan failed: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Purpose: Checks if Semgrep is available (bundled or system).
    /// Parameters: None
    /// Returns: True if Semgrep is available, false otherwise
    /// Preconditions: None
    /// Postconditions: Semgrep availability is determined
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: scanProject
    private func isSemgrepAvailable() -> Bool {
        // Prefer bundled wrapper
        if getBundledSemgrepPath() != nil {
            logger.info("Bundled Semgrep wrapper available")
            return true
        }
        // Fall back to system semgrep
        if getSystemSemgrepPath() != nil {
            logger.info("System Semgrep available")
            return true
        }
        return false
    }
    
    /// Purpose: Gets the path to the bundled Semgrep executable.
    /// Parameters: None
    /// Returns: Path to bundled Semgrep if available, nil otherwise
    /// Preconditions: None
    /// Postconditions: Bundled Semgrep path is determined
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: isSemgrepAvailable, runSemgrepScan
    private func getBundledSemgrepPath() -> String? {
        guard let bundlePath = Bundle.main.resourcePath else {
            logger.warning("Could not get bundle resource path")
            return nil
        }
        
        let semgrepPath = "\(bundlePath)/semgrep"
        
        // Check if the bundled semgrep wrapper exists (execution through bash avoids exec-bit dependence)
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: semgrepPath, isDirectory: &isDirectory), !isDirectory.boolValue {
            logger.info("Found bundled Semgrep wrapper at: \(semgrepPath)")
            return semgrepPath
        }
        logger.warning("Bundled Semgrep wrapper not found at: \(semgrepPath)")
        return nil
    }

    /// Purpose: Finds an available system `semgrep` binary path.
    private func getSystemSemgrepPath() -> String? {
        let commonPaths = [
            "/opt/homebrew/bin/semgrep", // Apple Silicon Homebrew
            "/usr/local/bin/semgrep",    // Intel Homebrew
            "/usr/bin/semgrep"
        ]
        for path in commonPaths where FileManager.default.isExecutableFile(atPath: path) {
            return path
        }
        // Try `which` as a fallback
        let which = Process()
        which.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        which.arguments = ["semgrep"]
        let pipe = Pipe()
        which.standardOutput = pipe
        do {
            try which.run()
            which.waitUntilExit()
            if which.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !path.isEmpty, FileManager.default.isExecutableFile(atPath: path) {
                    return path
                }
            }
        } catch {
            logger.error("Failed to locate system semgrep: \(error)")
        }
        return nil
    }
    
    /// Purpose: Runs the actual Semgrep scan command.
    /// Parameters:
    ///   - projectPath: Path to scan
    ///   - completion: Completion handler with raw output
    /// Returns: Void
    /// Preconditions: Semgrep is available
    /// Postconditions: Scan is executed, output is returned, and results are automatically saved to file
    /// Throws: Never
    /// Complexity: O(n) where n is the number of files
    /// Used By: scanProject
    private func runSemgrepScan(projectPath: String, completion: @escaping (Result<String, Error>) -> Void) {
        let process = Process()

        var executedCommand: [String] = []
        if let bundledPath = getBundledSemgrepPath() {
            // Execute bundled wrapper via bash to avoid exec-bit dependency
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [bundledPath, projectPath]
            executedCommand = ["/bin/bash", bundledPath, projectPath]
            logger.info("Using bundled Semgrep wrapper")
        } else if let systemPath = getSystemSemgrepPath() {
            // Run system semgrep directly with standard configs
            process.executableURL = URL(fileURLWithPath: systemPath)
            let args = [
                "scan",
                "--config=p/swift",
                "--config=p/owasp-top-ten",
                "--config=p/secrets",
                "--json",
                "--verbose",
                projectPath
            ]
            process.arguments = args
            executedCommand = [systemPath] + args
            logger.info("Using system Semgrep at: \(systemPath)")
        } else {
            completion(.failure(SemgrepError.notInstalled))
            return
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Drain pipes asynchronously to avoid deadlocks
        var stdoutData = Data()
        var stderrData = Data()
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.count > 0 { stdoutData.append(data) }
        }
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.count > 0 { stderrData.append(data) }
        }

        do {
            try process.run()
            DispatchQueue.global(qos: .userInitiated).async {
                process.waitUntilExit()
                // Stop handlers
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil

                let output = String(data: stdoutData, encoding: .utf8) ?? ""
                let error = String(data: stderrData, encoding: .utf8) ?? ""

                // Save results off the main thread
                self.logger.info("About to call saveScanResultsToFile - projectPath: \(projectPath), outputLength: \(output.count), errorLength: \(error.count)")
                self.saveScanResultsToFile(projectPath: projectPath, command: executedCommand, output: output, error: error, success: process.terminationStatus == 0)

                // Complete on main for UI safety
                DispatchQueue.main.async {
                    if process.terminationStatus == 0 {
                        completion(.success(output))
                    } else {
                        let errorMessage = error.isEmpty ? output : error
                        if errorMessage.contains("Semgrep is not available") ||
                           errorMessage.contains("not installed") ||
                           errorMessage.contains("pip install semgrep") ||
                           errorMessage.contains("🔍 Semgrep Security Scanner") ||
                           errorMessage.contains("To use Semgrep security scanning") ||
                           errorMessage.contains("Option 1 - Using pip") ||
                           errorMessage.contains("brew install semgrep") ||
                           errorMessage.contains("conda install -c conda-forge semgrep") {
                            completion(.failure(SemgrepError.semgrepNotAvailable(errorMessage)))
                        } else {
                            completion(.failure(SemgrepError.scanFailed(errorMessage)))
                        }
                    }
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Purpose: Parses Semgrep JSON output into Finding objects.
    /// Parameters:
    ///   - output: Raw JSON output from Semgrep
    ///   - projectPath: Base project path for relative file paths
    /// Returns: Array of parsed findings
    /// Preconditions: Output is valid JSON
    /// Postconditions: Findings are parsed and structured
    /// Throws: Never
    /// Complexity: O(n) where n is the number of findings
    /// Used By: scanProject
    private func parseSemgrepOutput(_ output: String, projectPath: String) -> [Finding] {
        guard let data = output.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else {
            logger.warning("Failed to parse Semgrep JSON output")
            return []
        }
        
        return results.compactMap { result in
            parseFinding(from: result, projectPath: projectPath)
        }
    }
    
    /// Purpose: Parses a single finding from Semgrep JSON result.
    /// Parameters:
    ///   - result: Single result dictionary from Semgrep
    ///   - projectPath: Base project path for relative file paths
    /// Returns: Parsed Finding object or nil if parsing fails
    /// Preconditions: Result is valid Semgrep result dictionary
    /// Postconditions: Finding is parsed and structured
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: parseSemgrepOutput
    private func parseFinding(from result: [String: Any], projectPath: String) -> Finding? {
        guard let ruleId = result["check_id"] as? String,
              let message = result["message"] as? String,
              let severityString = result["extra"] as? [String: Any],
              let severity = severityString["severity"] as? String,
              let path = result["path"] as? String,
              let start = result["start"] as? [String: Any],
              let line = start["line"] as? Int,
              let col = start["col"] as? Int,
              let code = result["extra"] as? [String: Any],
              let lines = code["lines"] as? String else {
            return nil
        }
        
        let severityEnum = Finding.Severity(rawValue: severity) ?? .medium
        let relativePath = path.replacingOccurrences(of: projectPath + "/", with: "")
        
        return Finding(
            ruleId: ruleId,
            message: message,
            severity: severityEnum,
            filePath: relativePath,
            lineNumber: line,
            columnNumber: col,
            codeSnippet: lines,
            fix: (code["fix"] as? String) ?? nil,
            confidence: (code["confidence"] as? String) ?? "medium",
            impact: (code["impact"] as? String) ?? "unknown",
            likelihood: (code["likelihood"] as? String) ?? "unknown"
        )
    }
    
    /// Purpose: Automatically save scan results to a text file in the project root.
    /// Parameters:
    ///   - projectPath: Path to the iOS project
    ///   - command: The command that was executed
    ///   - output: Standard output from the command
    ///   - error: Standard error from the command
    ///   - success: Whether the command succeeded
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions: Scan results are saved to a text file in the project root
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: runSemgrepScan
    private func saveScanResultsToFile(projectPath: String, command: [String], output: String, error: String, success: Bool) {
        logger.info("Starting to save scan results to file - projectPath: \(projectPath), success: \(success)")
        
        let timestamp = DateFormatter().apply {
            $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }.string(from: Date())
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "semgrep_scan_results_\(dateFormatter.string(from: Date())).txt"
        
        let filePath = URL(fileURLWithPath: projectPath).appendingPathComponent(fileName)
        logger.info("File path created: \(filePath.path)")
        
        var content = ""
        content += "🔍 Semgrep Security Scan Results\n"
        content += "==================================\n\n"
        content += "Generated: \(timestamp)\n"
        content += "Project: \(projectPath)\n"
        content += "Status: \(success ? "SUCCESS" : "FAILED")\n\n"
        
        // Command that was executed
        content += "📋 Command Executed:\n"
        content += "-------------------\n"
        content += command.joined(separator: " ") + "\n\n"
        
        // Standard output
        if !output.isEmpty {
            content += "📤 Standard Output:\n"
            content += "------------------\n"
            content += output + "\n\n"
        }
        
        // Standard error (if any)
        if !error.isEmpty {
            content += "❌ Standard Error:\n"
            content += "-----------------\n"
            content += error + "\n\n"
        }
        
        // Summary
        content += "📊 Summary:\n"
        content += "----------\n"
        if success {
            content += "✅ Scan completed successfully\n"
            if output.contains("findings") {
                content += "📄 Check the output above for detailed findings\n"
            } else {
                content += "🎉 No security issues found!\n"
            }
        } else {
            content += "❌ Scan failed - see error details above\n"
            if error.contains("Semgrep is not available") || error.contains("not installed") {
                content += "💡 Install Semgrep using: pip install semgrep\n"
            }
        }
        
        content += "\n" + String(repeating: "=", count: 50) + "\n"
        content += "End of Semgrep Scan Report\n"
        content += String(repeating: "=", count: 50) + "\n"
        
        do {
            try content.write(to: filePath, atomically: true, encoding: .utf8)
            logger.info("Scan results saved to: \(filePath.path)")
        } catch {
            logger.error("Failed to save scan results to file: \(error) at path: \(filePath.path)")
        }
    }
}

// MARK: - Error Types

/// Purpose: Defines Semgrep-specific errors.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions: Error types are defined
/// Throws: Never
/// Complexity: O(1)
/// Used By: SemgrepScanner
enum SemgrepError: LocalizedError {
    case notInstalled
    case semgrepNotAvailable(String)
    case scanFailed(String)
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .notInstalled:
            return "Semgrep is not available. The bundled Semgrep binary is missing or corrupted. Please reinstall the app or install Semgrep manually using: pip install semgrep"
        case .semgrepNotAvailable(let message):
            return message
        case .scanFailed(let message):
            return "Semgrep scan failed: \(message)"
        case .parsingFailed:
            return "Failed to parse Semgrep results"
        }
    }
}

// MARK: - Extensions

/// Purpose: Extension to make DateFormatter initialization cleaner.
/// Parameters: None
/// Returns: Self
/// Preconditions: None
/// Postconditions: DateFormatter is configured
/// Throws: Never
/// Complexity: O(1)
/// Used By: saveScanResultsToFile
extension DateFormatter {
    func apply(_ closure: (DateFormatter) -> Void) -> DateFormatter {
        closure(self)
        return self
    }
}
