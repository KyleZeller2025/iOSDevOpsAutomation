import Foundation

/// Central catalog for pipeline metadata, file paths, and customization controllers.
struct PipelineCatalog {
    /// Returns a tuple (fileName, directoryPath) for a given pipeline display name.
    static func filePath(for pipelineName: String, projectPath: String) -> (String, String) {
        switch pipelineName {
        case "Jenkins (Jenkinsfile)":
            return ("Jenkinsfile", projectPath)
        case "GitHub Actions (.github/workflows/ci.yml)":
            return ("ci.yml", "\(projectPath)/.github/workflows")
        case "GitLab CI (.gitlab-ci.yml)":
            return (".gitlab-ci.yml", projectPath)
        case "CircleCI (.circleci/config.yml)":
            return ("config.yml", "\(projectPath)/.circleci")
        case "Bitrise (bitrise.yml)":
            return ("bitrise.yml", projectPath)
        case "Azure Pipelines (azure-pipelines.yml)":
            return ("azure-pipelines.yml", projectPath)
        case "Codemagic (codemagic.yaml)":
            return ("codemagic.yaml", projectPath)
        case "Travis CI (.travis.yml)":
            return (".travis.yml", projectPath)
        default:
            return ("pipeline.yml", projectPath)
        }
    }

    /// Factory for the appropriate customization view controller for a given pipeline display name.
    static func makeCustomizationViewController(for pipelineName: String, template: String) -> BaseCustomizationViewController? {
        switch pipelineName {
        case "Jenkins (Jenkinsfile)":
            return JenkinsCustomizationViewController(template: template)
        case "GitHub Actions (.github/workflows/ci.yml)":
            return GitHubActionsCustomizationViewController(template: template)
        case "GitLab CI (.gitlab-ci.yml)":
            return GitLabCICustomizationViewController(template: template)
        case "CircleCI (.circleci/config.yml)":
            return CircleCICustomizationViewController(template: template)
        case "Bitrise (bitrise.yml)":
            return BitriseCustomizationViewController(template: template)
        case "Azure Pipelines (azure-pipelines.yml)":
            return AzurePipelinesCustomizationViewController(template: template)
        case "Codemagic (codemagic.yaml)":
            return CodemagicCustomizationViewController(template: template)
        case "Travis CI (.travis.yml)":
            return TravisCICustomizationViewController(template: template)
        default:
            return nil
        }
    }
}

