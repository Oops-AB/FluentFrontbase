extension FrontbaseDatabase: TransactionSupporting {
    /// See `TransactionSupporting`.
    public static func transactionExecute<T>(_ transaction: @escaping (FrontbaseConnection) throws -> Future<T>, on conn: FrontbaseConnection) -> Future<T> {
        return conn.withTransaction { connection in
            try transaction (connection)
        }
        .catchFlatMap { error in
            throw error
        }
    }
}
