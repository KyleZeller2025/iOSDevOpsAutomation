import Cocoa

/// MainCoordinator manages window and root view controller lifecycle (strict MVC + Coordinator).
final class MainCoordinator: PipelineOptimizationViewControllerDelegate {
    private var window: NSWindow?
    private var rootViewController: ViewController?
    private var mainWindowDelegate: MainWindowDelegate?
    private let model = ProjectModel()
    private let fileWriter = PipelineFileWriter()
    private let scanner = SemgrepScanner()

    func start() {
        let windowRect = NSRect(x: 0, y: 0, width: 800, height: 600)
        let window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "iOS DevOps Automation"
        window.center()
        window.setFrameAutosaveName("MainWindow")
        window.minSize = NSSize(width: 600, height: 400)
        window.isReleasedWhenClosed = false

        let rootVC = ViewController(model: model, fileWriter: fileWriter, scanner: scanner)
        rootVC.coordinator = self
        window.contentViewController = rootVC

        // Set up window delegate for proper cleanup
        mainWindowDelegate = MainWindowDelegate { [weak self] in
            self?.window = nil
            self?.rootViewController = nil
            self?.mainWindowDelegate = nil
        }
        window.delegate = mainWindowDelegate

        self.window = window
        self.rootViewController = rootVC

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - PipelineOptimizationViewControllerDelegate
    func changeProjectRequested() {
        model.goBackToProjectSelection()
    }

    func optimizePipelinesRequested(_ pipelines: [String]) {
        guard let projectPath = model.selectedFolderPath, let rootVC = rootViewController else { return }
        rootVC.startCustomizationFlow(for: pipelines, projectPath: projectPath)
    }
}

// MARK: - Window Delegate

/// Purpose: Handles window lifecycle for main application window.
/// Parameters: None
/// Returns: Void
/// Preconditions: None
/// Postconditions: Window cleanup is handled properly
/// Throws: Never
/// Complexity: O(1)
/// Used By: MainCoordinator
class MainWindowDelegate: NSObject, NSWindowDelegate {
    private let onWindowClose: () -> Void
    
    init(onWindowClose: @escaping () -> Void) {
        self.onWindowClose = onWindowClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onWindowClose()
    }
}
