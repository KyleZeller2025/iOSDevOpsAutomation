import XCTest
@testable import iOSDevOpsAutomation

final class PipelineCatalogTests: XCTestCase {
    func testFilePathMappings() throws {
        let project = "/tmp/Example"

        var result = PipelineCatalog.filePath(for: "Jenkins (Jenkinsfile)", projectPath: project)
        XCTAssertEqual(result.0, "Jenkinsfile")
        XCTAssertEqual(result.1, project)

        result = PipelineCatalog.filePath(for: "GitHub Actions (.github/workflows/ci.yml)", projectPath: project)
        XCTAssertEqual(result.0, "ci.yml")
        XCTAssertEqual(result.1, "\(project)/.github/workflows")

        result = PipelineCatalog.filePath(for: "CircleCI (.circleci/config.yml)", projectPath: project)
        XCTAssertEqual(result.0, "config.yml")
        XCTAssertEqual(result.1, "\(project)/.circleci")

        result = PipelineCatalog.filePath(for: "Unknown", projectPath: project)
        XCTAssertEqual(result.0, "pipeline.yml")
        XCTAssertEqual(result.1, project)
    }
}
