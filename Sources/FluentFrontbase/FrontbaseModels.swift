/// A Frontbase database model.
/// See `Fluent.Model`.
public protocol FrontbaseModel: _FrontbaseModel where Self.ID == Int {
    /// This Frontbase Model's unique identifier.
    var id: ID? { get set }
}

/// Base Frontbase model protocol.
public protocol _FrontbaseModel: FrontbaseTable, Model where Self.Database == FrontbaseDatabase { }

extension FrontbaseModel {
    /// See `Model`
    public static var idKey: IDKey { return \.id }
}

/// A Frontbase database pivot.
/// See `Fluent.Pivot`.
public protocol FrontbasePivot: Pivot, FrontbaseModel { }

/// A Frontbase database model.
/// See `Fluent.Model`.
public protocol FrontbaseUUIDModel: _FrontbaseModel where Self.ID == UUID {
    /// This Frontbase Model's unique identifier.
    var id: UUID? { get set }
}

extension FrontbaseUUIDModel {
    /// See `Model`
    public static var idKey: IDKey { return \.id }
}

/// A Frontbase database pivot.
/// See `Fluent.Pivot`.
public protocol FrontbaseUUIDPivot: Pivot, FrontbaseUUIDModel { }

/// A Frontbase database model.
/// See `Fluent.Model`.
public protocol FrontbaseStringModel: _FrontbaseModel where Self.ID == String {
    /// This Frontbase Model's unique identifier.
    var id: String? { get set }
}

extension FrontbaseStringModel {
    /// See `Model`
    public static var idKey: IDKey { return \.id }
}

/// A Frontbase database pivot.
/// See `Fluent.Pivot`.
public protocol FrontbaseStringPivot: Pivot, FrontbaseStringModel { }

/// A Frontbase database model.
/// See `Fluent.Model`.
public protocol FrontbaseBit96Model: _FrontbaseModel where Self.ID == Bit96 {
    /// This Frontbase Model's unique identifier.
    var id: Bit96? { get set }
}

extension FrontbaseBit96Model {
    /// See `Model`
    public static var idKey: IDKey { return \.id }
}

extension Bit96: ID { }

/// A Frontbase database pivot.
/// See `Fluent.Pivot`.
public protocol FrontbaseBit96Pivot: Pivot, FrontbaseBit96Model { }

/// A Frontbase database migration.
/// See `Fluent.Migration`.
public protocol FrontbaseMigration: Migration where Self.Database == FrontbaseDatabase { }

/// See `SQLTable`.
public protocol FrontbaseTable: SQLTable { }
