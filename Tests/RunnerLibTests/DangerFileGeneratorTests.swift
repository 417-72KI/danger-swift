import Foundation
import Logger
@testable import RunnerLib
import SnapshotTesting
import XCTest

final class DangerFileGeneratorTests: XCTestCase {
    private var logger: Logger {
        Logger(isVerbose: false, isSilent: false, printer: SpyPrinter())
    }

    private var createdFiles: [String]!
    private var generator: DangerFileGenerator!

    private var generatedFilePath: String {
        "GeneratedTestDangerfile.swift"
    }

    private var file1Path: String {
        "GeneratedTestFile1.swift"
    }

    private var file2Path: String {
        "GeneratedTestFile2.swift"
    }

    private var file3Path: String {
        "GeneratedTestFile3.swift"
    }

    override func setUp() {
        super.setUp()
        createdFiles = [generatedFilePath]
        generator = DangerFileGenerator()
//        record = false
    }

    override func tearDown() {
        createdFiles.forEach { try? FileManager.default.removeItem(atPath: $0) }
        createdFiles = nil
        generator = nil
        super.tearDown()
    }

    func testItGeneratesTheCorrectFileWhenThereAreNoImports() throws {
        try generator.generateDangerFile(
            fromContent: headerForContentWithoutImports + contentWithoutImports,
            fileName: generatedFilePath,
            logger: logger
        )

        try assertSnapshot(matching: generatedContent(), as: .lines)
    }

    func testItGeneratesTheCorrectFileWhenThereIsASingleImport() throws {
        try? file1Content.write(toFile: file1Path, atomically: true, encoding: .utf8)

        createdFiles.append(file1Path)

        try generator.generateDangerFile(fromContent: contentWithOneImport, fileName: generatedFilePath, logger: logger)

        try assertSnapshot(matching: generatedContent(), as: .lines)
    }

    func testItGeneratesTheCorrectFileWhenThereIsAreMultipleImports() throws {
        try? file1Content.write(toFile: file1Path, atomically: true, encoding: .utf8)
        try? file2Content.write(toFile: file2Path, atomically: true, encoding: .utf8)
        try? file3Content.write(toFile: file3Path, atomically: true, encoding: .utf8)

        createdFiles.append(file1Path)
        createdFiles.append(file2Path)
        createdFiles.append(file3Path)

        try generator.generateDangerFile(fromContent: contentWithMultipleImports, fileName: generatedFilePath, logger: logger)

        try assertSnapshot(matching: generatedContent(), as: .lines)
    }

    func testItGeneratesTheCorrectFileWhenOneOfTheImportedFilesIsMissing() throws {
        try? file1Content.write(toFile: file1Path, atomically: true, encoding: .utf8)
        try? file2Content.write(toFile: file2Path, atomically: true, encoding: .utf8)

        createdFiles.append(file1Path)
        createdFiles.append(file2Path)

        try generator.generateDangerFile(fromContent: contentWithMultipleImports, fileName: generatedFilePath, logger: logger)

        try assertSnapshot(matching: generatedContent(), as: .lines)
    }

    func testItGeneratesTheCorrectFileWhenThereIsAreImportsWithIndent() throws {
        try? file2Content.write(toFile: file2Path, atomically: true, encoding: .utf8)
        try? file3Content.write(toFile: file3Path, atomically: true, encoding: .utf8)

        createdFiles.append(file2Path)
        createdFiles.append(file3Path)

        try generator.generateDangerFile(fromContent: contentWithImportsWithIndent, fileName: generatedFilePath, logger: logger)

        try assertSnapshot(matching: generatedContent(), as: .lines)
    }
}

extension DangerFileGeneratorTests {
    private var headerForContentWithoutImports: String {
        """
        import Danger

        let danger = Danger()
        """ + "\n\n"
    }

    private var contentWithoutImports: String {
        """
        message("Text")
        message("Another Text")
        """
    }

    private var contentWithOneImport: String {
        headerForContentWithoutImports
            + "// fileImport: " + file1Path + "\n"
            + contentWithoutImports
    }

    private var contentWithMultipleImports: String {
        "// fileImport: " + file2Path + "\n\n"
            + "// fileImport: " + file3Path + "\n"
            + contentWithOneImport
    }

    private var contentWithImportsWithIndent: String {
        headerForContentWithoutImports
            + "if flag {\n"
            + "    // fileImport: " + file2Path + "\n"
            + "} else {\n"
            + "    // fileImport: " + file3Path + "\n"
            + "}\n"
            + contentWithoutImports
    }

    private var file1Content: String {
        """
        file1Content 👍🏻
        secondLine
        """
    }

    private var file2Content: String {
        """
        import Danger
        
        file2Content ⚠️
        """
    }

    private var file3Content: String {
        """
        import Danger
        import Foundation
        
        file3Content 👩‍👩‍👦‍👦
        secondLine
        really really really really really really really really really really really really \
        really really really really really really really really really really long text
        """
    }

    private func generatedContent() throws -> String {
        try String(contentsOfFile: generatedFilePath)
    }
}
