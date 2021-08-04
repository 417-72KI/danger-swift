            return .created(addedLines: hunks.flatMap { hunk in hunk.lines.map(\.text) })
            return .deleted(deletedLines: hunks.flatMap { hunk in hunk.lines.map(\.text) })
        hunks.map(\.description).joined(separator: "\n")
public extension FileDiff {
    enum Changes: Equatable {
    struct Hunk: Equatable, CustomStringConvertible {
                lines.map(\.description).joined(separator: "\n")
    struct Line: Equatable, CustomStringConvertible {
                  !header.isEmpty
           dividedSpan[0].count == 2,
           dividedSpan[1].count == 2,
           let oldLineStart = Int(dividedSpan[0][0]),
           let oldLineSpan = Int(dividedSpan[0][1]),
           let newLineStart = Int(dividedSpan[1][0]),
           let newLineSpan = Int(dividedSpan[1][1]) {