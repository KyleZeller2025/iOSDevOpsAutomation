import Foundation

protocol PipelineOptimizationViewControllerDelegate: AnyObject {
    func changeProjectRequested()
    func optimizePipelinesRequested(_ pipelines: [String])
}
