import Foundation

/// Application Support folder for gap JPEGs. Writes are atomic and stay off the caller.
actor GapPhotoStore {
    let root: URL

    init(root: URL) {
        self.root = root
    }

    func writeJPEG(_ data: Data, fileName: String) throws -> String {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let url = root.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return fileName
    }

    func deleteAll() throws {
        if FileManager.default.fileExists(atPath: root.path) {
            try FileManager.default.removeItem(at: root)
        }
    }
}
