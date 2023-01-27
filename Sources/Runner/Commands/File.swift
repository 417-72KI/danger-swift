import Foundation
import Logger
import RunnerLib

func cleanupDanger(logger: Logger) throws {
    let scriptManager = try getScriptManager(logger)
    try scriptManager.cleanup()
}
