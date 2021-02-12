import Async
import CFrontbaseSupport
import Dispatch
@testable import Frontbase
import XCTest

enum UtilitiesError: Error {
    case noTemporaryDirectory
}

extension FrontbaseConnection {
    static func makeFilebasedTest() throws -> FrontbaseConnection {
        let group = MultiThreadedEventLoopGroup (numberOfThreads: 1)
        let frontbase = try makeFilebasedDatabase()
        let conn = try frontbase.newConnection (on: group).wait()
        conn.logger = DatabaseLogger (database: .frontbase, handler: PrintLogHandler.init())
        return conn
    }

    static func makeFilebasedDatabase() throws -> FrontbaseDatabase {
        return try FrontbaseDatabase (name: "FrontbaseTests", pathName: temporaryDirectory (template: "/tmp/FrontbaseTests-XXXXXXXXXX") + "/database.fb", username: "_system", password: "")
    }

    static func temporaryDirectory (template: String) throws -> String {
        if let templatePointer = template.cString (using: .utf8) {
            let buffer = UnsafeMutablePointer<Int8>.allocate (capacity: templatePointer.count)

            buffer.assign (from: templatePointer, count: templatePointer.count)
            if let result = mkdtemp (buffer) {
                return String (cString: result)
            }
        }

        throw UtilitiesError.noTemporaryDirectory
    }

    func destroyFilebasedTest() {
        let fullPath = self.database.filePath
        close()
        if let fullPath = fullPath,
            let endIndex = fullPath.lastIndex (of: "/")
        {
            let path = String (fullPath[fullPath.startIndex ..< endIndex])
            do {
                try FileManager.default.removeItem (atPath: path)
            } catch {
                print ("Unable to delete directory at \(path): \(error)")
            }
        }
    }

    static func makeNetworkedDatabase() throws -> FrontbaseDatabase {
        let name = try temporaryDatabaseName (template: "FrontbaseTests-XXXXXXXXXX")
        fbsCreateDatabaseWithUrl ("frontbase://localhost/\(name)")
        fbsStartDatabaseWithUrl ("frontbase://localhost/\(name)")
        return FrontbaseDatabase (name: name, onHost: "localhost", username: "_system", password: "")
    }

    static func temporaryDatabaseName (template: String) throws -> String {
        return template
    }

    static func destroyNetworkedTest (database: FrontbaseDatabase) {
        let databaseName = database.databaseName
        fbsDeleteDatabaseWithUrl ("frontbase://localhost/\(databaseName)")
    }

	func getDatabase() -> FrontbaseDatabase {
		return database
	}
}

extension FrontbaseData {
    var blobData: Data? {
        switch (self) {
            case .blob (let blob):
                return blob.data()

            default:
                return nil
        }
    }

    var timestampDate: Date? {
        switch (self) {
            case .timestamp (let timestamp):
                return timestamp

            default:
                return nil
        }
    }
}
