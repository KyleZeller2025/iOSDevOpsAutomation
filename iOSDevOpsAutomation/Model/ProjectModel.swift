import Foundation

/// Purpose: Represents the current view state of the app.
/// Parameters: None (enum)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All cases are properly defined
/// Throws: Never
/// Complexity: O(1)
/// Used By: ProjectModel
public enum AppView {
    case projectSelection
    case pipelineOptimization
}

/// Purpose: Simple model for folder selection in strict MVC pattern.
/// Parameters: None (class)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are properly initialized
/// Throws: Never
/// Complexity: O(1)
/// Used By: ViewController
public class ProjectModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published public var selectedFolderPath: String?
    @Published public var isProcessing: Bool = false
    @Published public var statusMessage: String = "Ready"
    @Published public var currentView: AppView = .projectSelection
    
    // MARK: - Initialization
    
    public init() {
        // Initialize with default values
    }
    
    // MARK: - Public Methods
    
    /// Purpose: Sets the selected folder path and navigates to pipeline optimization.
    /// Parameters:
    ///   - path: The path to the selected folder
    /// Returns: Void
    /// Preconditions:
    /// - path must be a valid file path
    /// Postconditions:
    /// - selectedFolderPath is updated
    /// - statusMessage is updated
    /// - currentView is set to pipelineOptimization
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: ViewController
    public func selectFolder(_ path: String) {
        Logger.shared.methodEntry("ProjectModel.selectFolder", parameters: ["path": path])
        
        let oldPath = selectedFolderPath
        let oldView = currentView
        
        selectedFolderPath = path
        statusMessage = "Folder selected: \(URL(fileURLWithPath: path).lastPathComponent)"
        currentView = .pipelineOptimization
        
        Logger.shared.modelChange(model: "ProjectModel", property: "selectedFolderPath", oldValue: oldPath, newValue: path)
        Logger.shared.modelChange(model: "ProjectModel", property: "currentView", oldValue: oldView, newValue: currentView)
        Logger.shared.fileOperation("selectFolder", path: path)
        Logger.shared.navigation(from: "ProjectSelection", to: "PipelineOptimization")
        
        Logger.shared.methodExit("ProjectModel.selectFolder")
    }
    
    /// Purpose: Navigates back to project selection.
    /// Parameters: None
    /// Returns: Void
    /// Preconditions: None
    /// Postconditions:
    /// - currentView is set to projectSelection
    /// - selectedFolderPath is cleared
    /// Throws: Never
    /// Complexity: O(1)
    /// Used By: PipelineOptimizationViewController
    public func goBackToProjectSelection() {
        Logger.shared.methodEntry("ProjectModel.goBackToProjectSelection")
        
        let oldPath = selectedFolderPath
        let oldView = currentView
        
        selectedFolderPath = nil
        currentView = .projectSelection
        statusMessage = "Ready"
        
        Logger.shared.modelChange(model: "ProjectModel", property: "selectedFolderPath", oldValue: oldPath, newValue: nil)
        Logger.shared.modelChange(model: "ProjectModel", property: "currentView", oldValue: oldView, newValue: currentView)
        Logger.shared.navigation(from: "PipelineOptimization", to: "ProjectSelection")
        
        Logger.shared.methodExit("ProjectModel.goBackToProjectSelection")
    }
    
    
}
