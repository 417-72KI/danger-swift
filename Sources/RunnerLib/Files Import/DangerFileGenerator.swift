import Foundation
import Logger

public final class DangerFileGenerator {
    public init() {}

    public func generateDangerFile(fromContent content: String, fileName: String, logger: Logger) throws {
        var dangerContent = content
        let importsRegex = NSRegularExpression.filesImportRegex
        let range = NSRange(location: 0, length: content.count)

        importsRegex.enumerateMatches(in: content, options: [], range: range, using: { result, _, _ in
            // Adjust the result to have the correct range also after dangerContent is modified
            guard let result = result?.adjustingRanges(offset:
                dangerContent.utf16.count - content.utf16.count) else { return }
            let url = importsRegex.replacementString(for: result, in: dangerContent, offset: 0, template: "$1")

            guard let fileContent = try? String(contentsOfFile: url),
                  let replacementRange = Range<String.Index>(result.range, in: dangerContent)
            else {
                logger.logWarning("File not found at \(url)")
                return
            }

            dangerContent.replaceSubrange(replacementRange, with: fileContent)
        })

        mergeImports(in: &dangerContent)

        try dangerContent.write(toFile: fileName, atomically: false, encoding: .utf8)
    }
}

private extension DangerFileGenerator {
    func mergeImports(in content: inout String) {
        var lines = content
            .split(separator: "\n",
                   omittingEmptySubsequences: false)
            .map(String.init)

        let imports = Set(
            lines.map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0.hasPrefix("import ") }
        )
        lines.removeAll { imports.contains($0.trimmingCharacters(in: .whitespaces)) }
        lines.insert(contentsOf: imports.sorted(), at: 0)
        content = lines.joined(separator: "\n")
    }
}
