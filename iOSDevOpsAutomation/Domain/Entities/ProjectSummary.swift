import Foundation

/// Purpose: Represents a comprehensive summary of an iOS project for DevOps analysis.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: InspectProject use case, report generation
public struct ProjectSummary: Sendable, Codable, Equatable {
    public let name: String
    public let bundleIdentifier: String
    public let version: String
    public let buildNumber: String
    public let targetPlatforms: [String]
    public let dependencies: [DependencyInfo]
    public let buildSettings: [String: String]
    public let sourceFiles: [SourceFileInfo]
    public let testTargets: [TestTargetInfo]
    public let schemes: [SchemeInfo]
    public let certificates: [CertificateInfo]
    public let provisioningProfiles: [ProvisioningProfileInfo]
    public let lastModified: Date
    public let projectPath: URL
    
    public init(
        name: String,
        bundleIdentifier: String,
        version: String,
        buildNumber: String,
        targetPlatforms: [String],
        dependencies: [DependencyInfo],
        buildSettings: [String: String],
        sourceFiles: [SourceFileInfo],
        testTargets: [TestTargetInfo],
        schemes: [SchemeInfo],
        certificates: [CertificateInfo],
        provisioningProfiles: [ProvisioningProfileInfo],
        lastModified: Date,
        projectPath: URL
    ) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.version = version
        self.buildNumber = buildNumber
        self.targetPlatforms = targetPlatforms
        self.dependencies = dependencies
        self.buildSettings = buildSettings
        self.sourceFiles = sourceFiles
        self.testTargets = testTargets
        self.schemes = schemes
        self.certificates = certificates
        self.provisioningProfiles = provisioningProfiles
        self.lastModified = lastModified
        self.projectPath = projectPath
    }
}

/// Purpose: Represents information about a project dependency.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: ProjectSummary
public struct DependencyInfo: Sendable, Codable, Equatable {
    public let name: String
    public let version: String
    public let type: DependencyType
    public let source: String?
    
    public init(name: String, version: String, type: DependencyType, source: String?) {
        self.name = name
        self.version = version
        self.type = type
        self.source = source
    }
}

/// Purpose: Represents the type of dependency in an iOS project.
/// Parameters: None (enum)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All cases are valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: DependencyInfo
public enum DependencyType: String, Sendable, Codable, CaseIterable {
    case swiftPackage = "swift_package"
    case cocoapods = "cocoapods"
    case carthage = "carthage"
    case git = "git"
    case local = "local"
}

/// Purpose: Represents information about a source file in the project.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: ProjectSummary
public struct SourceFileInfo: Sendable, Codable, Equatable {
    public let path: String
    public let type: SourceFileType
    public let size: Int64
    public let lastModified: Date
    public let linesOfCode: Int?
    
    public init(path: String, type: SourceFileType, size: Int64, lastModified: Date, linesOfCode: Int?) {
        self.path = path
        self.type = type
        self.size = size
        self.lastModified = lastModified
        self.linesOfCode = linesOfCode
    }
}

/// Purpose: Represents the type of source file in an iOS project.
/// Parameters: None (enum)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All cases are valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: SourceFileInfo
public enum SourceFileType: String, Sendable, Codable, CaseIterable {
    case swift = "swift"
    case objectiveC = "m"
    case objectiveCPlusPlus = "mm"
    case c = "c"
    case cPlusPlus = "cpp"
    case storyboard = "storyboard"
    case xib = "xib"
    case plist = "plist"
    case json = "json"
    case yaml = "yaml"
    case markdown = "md"
    case other = "other"
}

/// Purpose: Represents information about a test target in the project.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: ProjectSummary
public struct TestTargetInfo: Sendable, Codable, Equatable {
    public let name: String
    public let type: TestTargetType
    public let testCount: Int
    public let coverage: Double?
    
    public init(name: String, type: TestTargetType, testCount: Int, coverage: Double?) {
        self.name = name
        self.type = type
        self.testCount = testCount
        self.coverage = coverage
    }
}

/// Purpose: Represents the type of test target in an iOS project.
/// Parameters: None (enum)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All cases are valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: TestTargetInfo
public enum TestTargetType: String, Sendable, Codable, CaseIterable {
    case unit = "unit"
    case ui = "ui"
    case integration = "integration"
    case performance = "performance"
}

/// Purpose: Represents information about a build scheme in the project.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: ProjectSummary
public struct SchemeInfo: Sendable, Codable, Equatable {
    public let name: String
    public let configuration: String
    public let targets: [String]
    public let buildAction: BuildAction
    public let testAction: TestAction?
    public let archiveAction: ArchiveAction?
    
    public init(
        name: String,
        configuration: String,
        targets: [String],
        buildAction: BuildAction,
        testAction: TestAction?,
        archiveAction: ArchiveAction?
    ) {
        self.name = name
        self.configuration = configuration
        self.targets = targets
        self.buildAction = buildAction
        self.testAction = testAction
        self.archiveAction = archiveAction
    }
}

/// Purpose: Represents build action configuration for a scheme.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: SchemeInfo
public struct BuildAction: Sendable, Codable, Equatable {
    public let parallelizeBuild: Bool
    public let buildImplicitDependencies: Bool
    public let runPostActionsOnFailure: Bool
    
    public init(parallelizeBuild: Bool, buildImplicitDependencies: Bool, runPostActionsOnFailure: Bool) {
        self.parallelizeBuild = parallelizeBuild
        self.buildImplicitDependencies = buildImplicitDependencies
        self.runPostActionsOnFailure = runPostActionsOnFailure
    }
}

/// Purpose: Represents test action configuration for a scheme.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: SchemeInfo
public struct TestAction: Sendable, Codable, Equatable {
    public let buildConfiguration: String
    public let testPlans: [String]
    public let testables: [String]
    public let shouldUseLaunchSchemeArgsEnv: Bool
    
    public init(
        buildConfiguration: String,
        testPlans: [String],
        testables: [String],
        shouldUseLaunchSchemeArgsEnv: Bool
    ) {
        self.buildConfiguration = buildConfiguration
        self.testPlans = testPlans
        self.testables = testables
        self.shouldUseLaunchSchemeArgsEnv = shouldUseLaunchSchemeArgsEnv
    }
}

/// Purpose: Represents archive action configuration for a scheme.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: SchemeInfo
public struct ArchiveAction: Sendable, Codable, Equatable {
    public let buildConfiguration: String
    public let revealArchiveInOrganizer: Bool
    public let customArchiveName: String?
    
    public init(buildConfiguration: String, revealArchiveInOrganizer: Bool, customArchiveName: String?) {
        self.buildConfiguration = buildConfiguration
        self.revealArchiveInOrganizer = revealArchiveInOrganizer
        self.customArchiveName = customArchiveName
    }
}

/// Purpose: Represents information about a code signing certificate.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: ProjectSummary
public struct CertificateInfo: Sendable, Codable, Equatable {
    public let name: String
    public let type: CertificateType
    public let teamId: String
    public let expirationDate: Date
    public let isValid: Bool
    
    public init(name: String, type: CertificateType, teamId: String, expirationDate: Date, isValid: Bool) {
        self.name = name
        self.type = type
        self.teamId = teamId
        self.expirationDate = expirationDate
        self.isValid = isValid
    }
}

/// Purpose: Represents the type of code signing certificate.
/// Parameters: None (enum)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All cases are valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: CertificateInfo
public enum CertificateType: String, Sendable, Codable, CaseIterable {
    case development = "development"
    case distribution = "distribution"
    case push = "push"
    case applePay = "apple_pay"
    case passbook = "passbook"
    case macAppStore = "mac_app_store"
    case developerId = "developer_id"
}

/// Purpose: Represents information about a provisioning profile.
/// Parameters: None (value object)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All properties are immutable and valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: ProjectSummary
public struct ProvisioningProfileInfo: Sendable, Codable, Equatable {
    public let name: String
    public let uuid: String
    public let type: ProvisioningProfileType
    public let teamId: String
    public let appId: String
    public let expirationDate: Date
    public let isValid: Bool
    
    public init(
        name: String,
        uuid: String,
        type: ProvisioningProfileType,
        teamId: String,
        appId: String,
        expirationDate: Date,
        isValid: Bool
    ) {
        self.name = name
        self.uuid = uuid
        self.type = type
        self.teamId = teamId
        self.appId = appId
        self.expirationDate = expirationDate
        self.isValid = isValid
    }
}

/// Purpose: Represents the type of provisioning profile.
/// Parameters: None (enum)
/// Returns: Self
/// Preconditions: None
/// Postconditions: All cases are valid
/// Throws: Never
/// Complexity: O(1)
/// Used By: ProvisioningProfileInfo
public enum ProvisioningProfileType: String, Sendable, Codable, CaseIterable {
    case development = "development"
    case adHoc = "ad_hoc"
    case appStore = "app_store"
    case enterprise = "enterprise"
    case macAppStore = "mac_app_store"
    case macAppStoreDirect = "mac_app_store_direct"
    case developerId = "developer_id"
}
