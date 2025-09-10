import Foundation
import os

/// Purpose: Production-grade logging system using os.Logger for structured logging.
/// Parameters: None (class)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All logging methods are available for use
/// Throws: Never
/// Complexity: O(1)
/// Used By: All application components
public class Logger {
    
    // MARK: - Singleton
    
    public static let shared = Logger()
    
    // MARK: - Properties
    
    private let logger: os.Logger
    private let subsystem = Bundle.main.bundleIdentifier ?? "com.KyleZeller.iOSDevOpsAutomation"
    
    // MARK: - Log Categories
    
    public enum Category: String, CaseIterable {
        case app = "App"
        case navigation = "Navigation"
        case model = "Model"
        case ui = "UI"
        case pipeline = "Pipeline"
        case fileSystem = "FileSystem"
        case network = "Network"
        case error = "Error"
        case debug = "Debug"
    }
    
    // MARK: - Log Levels
    
    public enum Level: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case notice = "NOTICE"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
    }
    
    // MARK: - Initialization
    
    /// Purpose: Initializes the logger with default configuration.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Logger is configured and ready for use
    /// - All categories are available
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: Logger.shared
    private init() {
        self.logger = os.Logger(subsystem: subsystem, category: "General")
    }
    
    // MARK: - Public Logging Methods
    
    /// Purpose: Logs a debug message with optional metadata.
    /// Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Debug message is logged to console
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: All application components
    public func debug(_ message: String, category: Category = .debug, metadata: [String: Any]? = nil) {
        log(level: .debug, message: message, category: category, metadata: metadata)
    }
    
    /// Purpose: Logs an info message with optional metadata.
    /// Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Info message is logged to console
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: All application components
    public func info(_ message: String, category: Category = .app, metadata: [String: Any]? = nil) {
        log(level: .info, message: message, category: category, metadata: metadata)
    }
    
    /// Purpose: Logs a notice message with optional metadata.
    /// Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Notice message is logged to console
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: All application components
    public func notice(_ message: String, category: Category = .app, metadata: [String: Any]? = nil) {
        log(level: .notice, message: message, category: category, metadata: metadata)
    }
    
    /// Purpose: Logs a warning message with optional metadata.
    /// Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Warning message is logged to console
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: All application components
    public func warning(_ message: String, category: Category = .app, metadata: [String: Any]? = nil) {
        log(level: .warning, message: message, category: category, metadata: metadata)
    }
    
    /// Purpose: Logs an error message with optional metadata.
    /// Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Error message is logged to console
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: All application components
    public func error(_ message: String, category: Category = .error, metadata: [String: Any]? = nil) {
        log(level: .error, message: message, category: category, metadata: metadata)
    }
    
    /// Purpose: Logs a critical message with optional metadata.
    /// Parameters:
    ///   - message: The message to log
    ///   - category: The log category
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Critical message is logged to console
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: All application components
    public func critical(_ message: String, category: Category = .error, metadata: [String: Any]? = nil) {
        log(level: .critical, message: message, category: category, metadata: metadata)
    }
    
    // MARK: - Convenience Methods
    
    /// Purpose: Logs application lifecycle events.
    /// Parameters:
    ///   - event: The lifecycle event
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Lifecycle event is logged
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: AppDelegate, ViewControllers
    public func appLifecycle(_ event: String, metadata: [String: Any]? = nil) {
        info("App Lifecycle: \(event)", category: .app, metadata: metadata)
    }
    
    /// Purpose: Logs navigation events between views.
    /// Parameters:
    ///   - from: Source view
    ///   - to: Destination view
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Navigation event is logged
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: ViewControllers, Navigation logic
    public func navigation(from: String, to: String, metadata: [String: Any]? = nil) {
        var navMetadata = metadata ?? [:]
        navMetadata["from"] = from
        navMetadata["to"] = to
        info("Navigation: \(from) → \(to)", category: .navigation, metadata: navMetadata)
    }
    
    /// Purpose: Logs model state changes.
    /// Parameters:
    ///   - model: Model name
    ///   - property: Property name
    ///   - oldValue: Previous value
    ///   - newValue: New value
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Model change is logged
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: ProjectModel, ObservableObject updates
    public func modelChange(model: String, property: String, oldValue: Any?, newValue: Any?) {
        let metadata: [String: Any] = [
            "model": model,
            "property": property,
            "oldValue": String(describing: oldValue ?? "nil"),
            "newValue": String(describing: newValue ?? "nil")
        ]
        debug("Model Change: \(model).\(property)", category: .model, metadata: metadata)
    }
    
    /// Purpose: Logs UI events and interactions.
    /// Parameters:
    ///   - action: UI action performed
    ///   - component: UI component name
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - UI event is logged
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: ViewControllers, UI components
    public func uiEvent(_ action: String, component: String, metadata: [String: Any]? = nil) {
        var uiMetadata = metadata ?? [:]
        uiMetadata["component"] = component
        debug("UI Event: \(action) on \(component)", category: .ui, metadata: uiMetadata)
    }
    
    /// Purpose: Logs pipeline-related events.
    /// Parameters:
    ///   - event: Pipeline event
    ///   - pipeline: Pipeline name
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Pipeline event is logged
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: PipelineOptimizationViewController, Pipeline logic
    public func pipelineEvent(_ event: String, pipeline: String? = nil, metadata: [String: Any]? = nil) {
        var pipeMetadata = metadata ?? [:]
        if let pipeline = pipeline {
            pipeMetadata["pipeline"] = pipeline
        }
        info("Pipeline: \(event)", category: .pipeline, metadata: pipeMetadata)
    }
    
    /// Purpose: Logs file system operations.
    /// Parameters:
    ///   - operation: File operation performed
    ///   - path: File path
    ///   - metadata: Optional metadata dictionary
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - File operation is logged
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: File operations, Project selection
    public func fileOperation(_ operation: String, path: String, metadata: [String: Any]? = nil) {
        var fileMetadata = metadata ?? [:]
        fileMetadata["path"] = path
        info("File Operation: \(operation)", category: .fileSystem, metadata: fileMetadata)
    }
    
    // MARK: - Private Methods
    
    /// Purpose: Internal logging method that formats and outputs messages.
    /// Parameters:
    ///   - level: Log level
    ///   - message: Message to log
    ///   - category: Log category
    ///   - metadata: Optional metadata
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Formatted message is logged to console
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: All public logging methods
    private func log(level: Level, message: String, category: Category, metadata: [String: Any]?) {
        let timestamp = DateFormatter.logTimestamp.string(from: Date())
        let categoryLogger = os.Logger(subsystem: subsystem, category: category.rawValue)
        
        // Format metadata if present
        let metadataString = formatMetadata(metadata)
        let fullMessage = metadataString.isEmpty ? message : "\(message) \(metadataString)"
        
        // Log based on level
        switch level {
        case .debug:
            categoryLogger.debug("\(fullMessage)")
        case .info:
            categoryLogger.info("\(fullMessage)")
        case .notice:
            categoryLogger.notice("\(fullMessage)")
        case .warning:
            categoryLogger.warning("\(fullMessage)")
        case .error:
            categoryLogger.error("\(fullMessage)")
        case .critical:
            categoryLogger.critical("\(fullMessage)")
        }
        
        // Also print to console for immediate visibility in debug builds
        #if DEBUG
        print("[\(timestamp)] [\(level.rawValue)] [\(category.rawValue)] \(fullMessage)")
        #endif
    }
    
    /// Purpose: Formats metadata dictionary into a readable string.
    /// Parameters:
    ///   - metadata: Metadata dictionary
    /// Returns: Formatted metadata string
    /// Preconditions: None
    /// Postconditions:
    /// - Metadata is formatted as key=value pairs
    /// Throws: Never
    /// Complexity: O(n) where n is the number of metadata items
    /// Used By: log method
    private func formatMetadata(_ metadata: [String: Any]?) -> String {
        guard let metadata = metadata, !metadata.isEmpty else { return "" }
        
        let formattedPairs = metadata.map { key, value in
            "\(key)=\(value)"
        }
        
        return "[\(formattedPairs.joined(separator: ", "))]"
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

// MARK: - Convenience Extensions

extension Logger {
    /// Purpose: Logs method entry with parameters.
    /// Parameters:
    ///   - function: Function name
    ///   - parameters: Function parameters
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Method entry is logged
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: Method tracing
    public func methodEntry(_ function: String, parameters: [String: Any]? = nil) {
        debug("→ \(function)", category: .debug, metadata: parameters)
    }
    
    /// Purpose: Logs method exit with return value.
    /// Parameters:
    ///   - function: Function name
    ///   - returnValue: Return value
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - Method exit is logged
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: Method tracing
    public func methodExit(_ function: String, returnValue: Any? = nil) {
        let metadata = returnValue != nil ? ["returnValue": String(describing: returnValue!)] : nil
        debug("← \(function)", category: .debug, metadata: metadata)
    }
}
