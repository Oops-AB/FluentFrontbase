/// Types conforming to the `FrontbaseType` protocols can be used as properties on `FrontbaseModel`s.
///
/// This protocol defines which `FrontbaseFieldType` (TEXT, BLOB, etc) a type uses and how it converts to/from `FrontbaseData`.
///
/// See `FrontbaseEnumType` and `FrontbaseJSONType` for more specialized use-cases.
public typealias FrontbaseType = Codable & FrontbaseDataTypeStaticRepresentable & FrontbaseDataConvertible

// MARK: JSON

/// This protocol makes it easy to declare nested structs on `FrontbaseModel`'s that will be stored as JSON-encoded data.
///
///     struct Pet: FrontbaseJSONType {
///         var name: String
///     }
///
///     struct User: FrontbaseModel, Migration {
///         var id: Int?
///         var pet: Pet
///     }
///
/// The above models will result in the following schema:
///
///     CREATE TABLE `users` (`id` INTEGER PRIMARY KEY, `pet` BLOB NOT NULL)
///
public protocol FrontbaseJSONType: FrontbaseType { }

/// Default implementations for `FrontbaseJSONType`
extension FrontbaseJSONType {
    /// Use the `Data`'s `FrontbaseFieldType` to store the JSON-encoded data.
    ///
    /// See `FrontbaseFieldTypeStaticRepresentable.FrontbaseFieldType` for more information.
    public static var frontbaseDataType: FrontbaseDataType { return Data.frontbaseDataType }

    /// JSON-encode `Self` to `Data`.
    ///
    /// See `FrontbaseDataConvertible.convertToFrontbaseData()`
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return try JSONEncoder().encode(self).convertToFrontbaseData()
    }

    /// JSON-decode `Data` to `Self`.
    ///
    /// See `FrontbaseDataConvertible.convertFromFrontbaseData(_:)`
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: Data.convertFromFrontbaseData(data))
    }
}

// MARK: Enum

/// This type-alias makes it easy to declare nested enum types for your `FrontbaseModel`.
///
///     enum PetType: Int, FrontbaseEnumType {
///         case cat, dog
///     }
///
/// `FrontbaseEnumType` can be used easily with any enum that has a `FrontbaseType` conforming `RawValue`.
///
/// You will need to implement custom `ReflectionDecodable` conformance for enums that have non-standard integer
/// values or enums whose `RawValue` is not an integer.
///
///     enum FavoriteTreat: String, FrontbaseEnumType {
///         case bone = "b"
///         case tuna = "t"
///         static func reflectDecoded() -> (FavoriteTreat, FavoriteTreat) {
///             return (.bone, .tuna)
///         }
///     }
///
public typealias FrontbaseEnumType = FrontbaseType & ReflectionDecodable & RawRepresentable

/// Provides a default `FrontbaseFieldTypeStaticRepresentable` implementation where the type is also
/// `RawRepresentable` by a `FrontbaseFieldTypeStaticRepresentable` type.
extension FrontbaseDataTypeStaticRepresentable
    where Self: RawRepresentable, Self.RawValue: FrontbaseDataTypeStaticRepresentable
{
    /// Use the `RawValue`'s `FrontbaseFieldType`.
    ///
    /// See `FrontbaseFieldTypeStaticRepresentable.FrontbaseFieldType` for more information.
    public static var frontbaseDataType: FrontbaseDataType { return RawValue.frontbaseDataType }
}

/// Provides a default `FrontbaseDataConvertible` implementation where the type is also
/// `RawRepresentable` by a `FrontbaseDataConvertible` type.
extension FrontbaseDataConvertible
    where Self: RawRepresentable, Self.RawValue: FrontbaseDataConvertible
{
    /// See `FrontbaseDataConvertible`.
    public func convertToFrontbaseData() throws -> FrontbaseData {
        return try rawValue.convertToFrontbaseData()
    }

    /// See `FrontbaseDataConvertible`.
    public static func convertFromFrontbaseData(_ data: FrontbaseData) throws -> Self {
        guard let e = try self.init(rawValue: .convertFromFrontbaseData(data)) else {
            throw FluentFrontbaseError(
                identifier: "rawValue",
                reason: "Could not create `\(Self.self)` from: \(data)",
                source: .capture()
            )
        }
        return e
    }
}
