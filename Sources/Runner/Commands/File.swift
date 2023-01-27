import Foundation
import Logger
import RunnerLib

func cleanupDanger(logger: Logger, dryRun: Bool) throws {
    let scriptManager = try getScriptManager(logger)
    try scriptManager.cleanup(dryRun: dryRun)
}
