import Foundation

/// File projection of the chart. Atomic replace, schema backup, never read on the main actor.
actor ChartDisk {
    let fileURL: URL
    private var backupURL: URL { URL(fileURLWithPath: fileURL.path + ".backup") }

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func write(_ data: Data) throws {
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if FileManager.default.fileExists(atPath: backupURL.path) {
                try FileManager.default.removeItem(at: backupURL)
            }
            try FileManager.default.copyItem(at: fileURL, to: backupURL)
        }
        try data.write(to: fileURL, options: .atomic)
    }

    func readBackup() -> Data? {
        load(backupURL)
    }

    func readPrimary() -> Data? {
        load(fileURL)
    }

    private func load(_ url: URL) -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            return try Data(contentsOf: url)
        } catch {
            return nil
        }
    }

    func deleteDocument() throws {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        if FileManager.default.fileExists(atPath: backupURL.path) {
            try FileManager.default.removeItem(at: backupURL)
        }
    }
}
