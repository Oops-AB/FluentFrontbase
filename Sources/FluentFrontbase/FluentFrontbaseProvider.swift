/// Registers and boots Frontbase services.
public final class FluentFrontbaseProvider: Provider {
    /// Create a new Frontbase provider.
    public init() { }

    /// See Provider.register
    public func register (_ services: inout Services) throws {
        try services.register (FluentProvider())
        services.register (KeyedCache.self) { container -> FrontbaseCache in
            let pool = try container.connectionPool (to: .frontbase)
            return .init (pool: pool)
        }
    }

    /// See Provider.boot
    public func didBoot (_ container: Container) throws -> Future<Void> {
        return .done (on: container)
    }
}

public typealias FrontbaseCache = DatabaseKeyedCache<ConfiguredDatabase<FrontbaseDatabase>>
extension FrontbaseDatabase: KeyedCacheSupporting { }
extension FrontbaseDatabase: Service { }
