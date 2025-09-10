import Foundation

/// Service responsible for generating and writing pipeline configuration files.
final class PipelineFileWriter {
    func generatePipelineFiles(from results: [String: String], projectPath: String) -> (generated: [String], errors: [String]) {
        var generatedFiles: [String] = []
        var errors: [String] = []

        for (pipelineName, content) in results {
            do {
                let filePath = try savePipelineFile(pipelineName: pipelineName, content: content, projectPath: projectPath)
                generatedFiles.append(filePath)
                Logger.shared.info("Generated file: \(filePath)")
            } catch {
                let errorMessage = "Failed to generate \(pipelineName): \(error.localizedDescription)"
                errors.append(errorMessage)
                Logger.shared.error(errorMessage)
            }
        }

        return (generatedFiles, errors)
    }

    private func savePipelineFile(pipelineName: String, content: String, projectPath: String) throws -> String {
        let (fileName, directoryPath) = PipelineCatalog.filePath(for: pipelineName, projectPath: projectPath)

        // Create directory if it doesn't exist
        try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)

        let fullPath = "\(directoryPath)/\(fileName)"
        try content.write(toFile: fullPath, atomically: true, encoding: .utf8)
        return fullPath
    }
}

