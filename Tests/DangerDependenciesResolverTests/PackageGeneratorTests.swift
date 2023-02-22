@testable import DangerDependenciesResolver
import SnapshotTesting
import XCTest

final class PackageGeneratorTests: XCTestCase {
    override func setUp() {
        super.setUp()

        // isRecording = true
    }

    func testGeneratedPackageWhenThereAreNoDependencies() throws {
        let packageListMaker = StubbedPackageListMaker(packages: [])
        let spyFileCreator = SpyFileCreator()
        let generator = PackageGenerator(folder: "folder",
                                         generatedFolder: "generatedFolder",
                                         packageListMaker: packageListMaker,
                                         fileCreator: spyFileCreator)

        try generator.generateMasterPackageDescription(forSwiftToolsVersion: .init(5, 5, 0), macOSVersion: .init(12, 0, 0))

        assertSnapshot(matching: String(data: spyFileCreator.receivedContents!, encoding: .utf8)!, as: .lines)
    }

    func testGeneratedPackageWhenThereAreDependenciesAndSwiftVersionIs5_5() throws {
        let packageListMaker = StubbedPackageListMaker(packages: [
            Package(name: "Dependency1", url: URL(string: "https://github.com/danger/dependency1")!, majorVersion: 1),
            Package(name: "Dependency2", url: URL(string: "https://github.com/danger/dependency2")!, majorVersion: 2),
            Package(name: "Dependency3", url: URL(string: "https://github.com/danger/dependency3")!, majorVersion: 3),
        ])
        let spyFileCreator = SpyFileCreator()
        let generator = PackageGenerator(folder: "folder",
                                         generatedFolder: "generatedFolder",
                                         packageListMaker: packageListMaker,
                                         fileCreator: spyFileCreator)

        try generator.generateMasterPackageDescription(forSwiftToolsVersion: .init(5, 5, 0), macOSVersion: .init(12, 0, 0))

        assertSnapshot(matching: String(data: spyFileCreator.receivedContents!, encoding: .utf8)!, as: .lines)
    }

    func testGeneratedPackageWhenThereAreDependenciesAndSwiftVersionIsOver5_6() throws {
        let packageListMaker = StubbedPackageListMaker(packages: [
            Package(name: "Dependency1", url: URL(string: "https://github.com/danger/dependency1")!, majorVersion: 1),
            Package(name: "Dependency2", url: URL(string: "https://github.com/danger/dependency2")!, majorVersion: 2),
            Package(name: "Dependency3", url: URL(string: "https://github.com/danger/dependency3")!, majorVersion: 3),
        ])
        let spyFileCreator = SpyFileCreator()
        let generator = PackageGenerator(folder: "folder",
                                         generatedFolder: "generatedFolder",
                                         packageListMaker: packageListMaker,
                                         fileCreator: spyFileCreator)

        try generator.generateMasterPackageDescription(forSwiftToolsVersion: .init(5, 6, 0), macOSVersion: .init(12, 0, 0))

        assertSnapshot(matching: String(data: spyFileCreator.receivedContents!, encoding: .utf8)!, as: .lines)
    }

    func testGeneratedDescriptionHeader() throws {
        let packageListMaker = StubbedPackageListMaker(packages: [])
        let spyFileCreator = SpyFileCreator()
        let generator = PackageGenerator(folder: "folder",
                                         generatedFolder: "generatedFolder",
                                         packageListMaker: packageListMaker,
                                         fileCreator: spyFileCreator)

        assertSnapshot(matching: generator.makePackageDescriptionHeader(forSwiftToolsVersion: .init(5, 5, 0)), as: .lines)
    }
}

private struct StubbedPackageListMaker: PackageListMaking {
    let packages: [Package]

    func makePackageList() -> [Package] {
        packages
    }
}

private final class SpyFileCreator: FileCreating {
    var receivedPath: String?
    var receivedContents: Data?

    func createFile(atPath path: String, contents: Data) {
        receivedPath = path
        receivedContents = contents
    }
}
