import Async
import Fluent
import FluentBenchmark
import FluentFrontbase
import Frontbase
import XCTest
import FluentSQL

final class FrontbaseBenchmarkTests: XCTestCase {
    var benchmarker: Benchmarker<FrontbaseDatabase>!
    var database: FrontbaseDatabase!

    override func setUp() {
        database = try! FrontbaseConnection.makeNetworkedDatabase()
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        benchmarker = try! Benchmarker (database, on: group, onFail: XCTFail)
    }

    func testBenchmark() throws {
        try benchmarker.runAll()
    }
    
    func testMinimumViableModelDeclaration() throws {
        /// NOTE: these must never fail to build
        struct Foo: FrontbaseModel {
            var id: Int?
            var name: String
        }
        final class Bar: FrontbaseModel {
            var id: Int?
            var name: String
        }
        struct Baz: FrontbaseUUIDModel {
            var id: UUID?
            var name: String
        }
        final class Qux: FrontbaseUUIDModel {
            var id: UUID?
            var name: String
        }
        final class Uh: FrontbaseStringModel {
            var id: String?
            var name: String
        }
    }

    func testContains() throws {
        struct User: FrontbaseModel, FrontbaseMigration {
            var id: Int?
            var name: String
            var age: Int
        }
        let conn = try benchmarker.pool.requestConnection().wait()
        defer { benchmarker.pool.releaseConnection(conn) }
        
        try User.prepare(on: conn).wait()
        defer { try! User.revert(on: conn).wait() }
        
        // create
        let tanner1 = User(id: nil, name: "tanner", age: 23)
        _ = try tanner1.save(on: conn).wait()
        let tanner2 = User(id: nil, name: "ner", age: 23)
        _ = try tanner2.save(on: conn).wait()
        let tanner3 = User(id: nil, name: "tan", age: 23)
        _ = try tanner3.save(on: conn).wait()
        
        let tas = try User.query(on: conn).filter(\.name =~ "ta").count().wait()
        if tas != 2 {
            XCTFail("tas == \(tas)")
        }
        //        let ers = try User.query(on: conn).filter(\.name ~= "er").count().wait()
        //        if ers != 2 {
        //            XCTFail("ers == \(tas)")
        //        }
        let annes = try User.query(on: conn).filter(\.name ~~ "anne").count().wait()
        if annes != 1 {
            XCTFail("annes == \(tas)")
        }
        let ns = try User.query(on: conn).filter(\.name ~~ "n").count().wait()
        if ns != 3 {
            XCTFail("ns == \(tas)")
        }
        
        let nertan = try User.query(on: conn).filter(\.name ~~ ["ner", "tan"]).count().wait()
        if nertan != 2 {
            XCTFail("nertan == \(tas)")
        }
        
        let notner = try User.query(on: conn).filter(\.name !~ ["ner"]).count().wait()
        if notner != 2 {
            XCTFail("nertan == \(tas)")
        }
    }
    
    func testFrontbaseEnums() throws {
        enum PetType: Int, Codable, CaseIterable {
            static let allCases: [PetType] = [.cat, .dog]
            case cat, dog
        }

        enum NumLegs: Int, FrontbaseEnumType {
            case four = 4
            case two = 2

            static func reflectDecoded() -> (NumLegs, NumLegs) {
                return (.four, .two)
            }
        }

        enum FavoriteTreat: String, FrontbaseEnumType {
            case bone = "b"
            case tuna = "t"

            static func reflectDecoded() -> (FavoriteTreat, FavoriteTreat) {
                return (.bone, .tuna)
            }
        }

        struct Pet: FrontbaseModel, Migration {
            var id: Int?
            var name: String
            var type: PetType
            var numLegs: NumLegs
            var treat: FavoriteTreat
        }

        let conn = try benchmarker.pool.requestConnection().wait()
        defer { benchmarker.pool.releaseConnection(conn) }

        defer { try? Pet.revert(on: conn).wait() }
        try Pet.prepare(on: conn).wait()

        let cat = try Pet(id: nil, name: "Ziz", type: .cat, numLegs: .two, treat: .tuna).save(on: conn).wait()
        let dog = try Pet(id: nil, name: "Spud", type: .dog, numLegs: .four, treat: .bone).save(on: conn).wait()
        let fetchedCat = try Pet.find(cat.requireID(), on: conn).wait()
        XCTAssertEqual(dog.type, .dog)
        XCTAssertEqual(cat.id, fetchedCat?.id)
    }

    func testFrontbaseJSON() throws {
        enum PetType: Int, Codable {
            case cat, dog
        }

        struct Pet: FrontbaseJSONType {
            var name: String
            var type: PetType
        }

        struct User: FrontbaseModel, Migration {
            var id: Int?
            var pet: Pet
        }

        let conn = try benchmarker.pool.requestConnection().wait()
        defer { benchmarker.pool.releaseConnection(conn) }

        defer { try? User.revert(on: conn).wait() }
        try User.prepare(on: conn).wait()

        let cat = Pet(name: "Ziz", type: .cat)
        let tanner = try User(id: nil, pet: cat).save(on: conn).wait()
        let fetched = try User.find(tanner.requireID(), on: conn).wait()
        XCTAssertEqual(tanner.id, fetched?.id)
        XCTAssertEqual(fetched?.pet.name, "Ziz")
    }

    func testUUIDPivot() throws {
        struct A: FrontbaseUUIDModel, Migration {
            var id: UUID?
        }
        struct B: FrontbaseUUIDModel, Migration {
            var id: UUID?
        }
        struct C: FrontbaseUUIDPivot, Migration {
            static var leftIDKey = \C.aID
            static var rightIDKey = \C.bID

            typealias Left = A
            typealias Right = B
            var id: UUID?
            var aID: UUID
            var bID: UUID
        }

        let conn = try benchmarker.pool.requestConnection().wait()
        defer { benchmarker.pool.releaseConnection(conn) }

        defer {
            try? C.prepare(on: conn).wait()
            try? B.prepare(on: conn).wait()
            try? A.prepare(on: conn).wait()
        }
        try A.prepare(on: conn).wait()
        try B.prepare(on: conn).wait()
        try C.prepare(on: conn).wait()

        let a = try A(id: nil).save(on: conn).wait()
        let b = try B(id: nil).save(on: conn).wait()
        let c = try C(id: nil, aID: a.requireID(), bID: b.requireID()).save(on: conn).wait()

        let fetched = try C.find(c.requireID(), on: conn).wait()
        XCTAssertEqual(fetched?.id, c.id)
    }

    func testBit96Pivot() throws {
        struct K: FrontbaseBit96Model, Migration {
            var id: Bit96?
        }
        struct L: FrontbaseBit96Model, Migration {
            var id: Bit96?
        }
        struct M: FrontbaseBit96Pivot, Migration {
            static var leftIDKey = \M.kID
            static var rightIDKey = \M.lID

            typealias Left = K
            typealias Right = L
            var id: Bit96?
            var kID: Bit96
            var lID: Bit96
        }

        let conn = try benchmarker.pool.requestConnection().wait()
        defer { benchmarker.pool.releaseConnection(conn) }

        defer {
            try? M.prepare(on: conn).wait()
            try? L.prepare(on: conn).wait()
            try? K.prepare(on: conn).wait()
        }
        try K.prepare(on: conn).wait()
        try L.prepare(on: conn).wait()
        try M.prepare(on: conn).wait()

        let k = try K(id: nil).save(on: conn).wait()
        let l = try L(id: nil).save(on: conn).wait()
        let m = try M(id: nil, kID: k.requireID(), lID: l.requireID()).save(on: conn).wait()

        let fetched = try M.find(m.requireID(), on: conn).wait()
        XCTAssertEqual(fetched?.id, m.id)
    }

    static let allTests = [
        ("testBenchmark", testBenchmark),
        ("testMinimumViableModelDeclaration", testMinimumViableModelDeclaration),
        ("testContains", testContains),
        ("testFrontbaseEnums", testFrontbaseEnums),
        ("testFrontbaseJSON", testFrontbaseJSON),
        ("testUUIDPivot", testUUIDPivot),
        ("testBit96Pivot", testBit96Pivot),
    ]
}
