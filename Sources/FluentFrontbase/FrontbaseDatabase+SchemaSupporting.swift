extension FrontbaseDatabase: SQLConstraintIdentifierNormalizer {
    /// See `SQLConstraintIdentifierNormalizer`.
    public static func normalizeSQLConstraintIdentifier(_ identifier: String) -> String {
        return identifier
    }
}

extension FrontbaseDatabase: SchemaSupporting {
    /// See `SchemaSupporting`.
    public typealias Schema = FluentFrontbaseSchema
    
    /// See `SchemaSupporting`.
    public typealias SchemaAction = FluentFrontbaseSchemaStatement
    
    /// See `SchemaSupporting`.
    public typealias SchemaField = FrontbaseColumnDefinition
    
    /// See `SchemaSupporting`.
    public typealias SchemaFieldType = FrontbaseDataType
    
    /// See `SchemaSupporting`.
    public typealias SchemaConstraint = FrontbaseTableConstraint
    
    /// See `SchemaSupporting`.
    public typealias SchemaReferenceAction = FrontbaseForeignKeyAction
    
    /// See `SchemaSupporting`.
    public static func schemaField(for type: Any.Type, isIdentifier: Bool, _ field: QueryField) -> SchemaField {
        var type = type
        var constraints: [FrontbaseColumnConstraint] = []
        
        if let optional = type as? AnyOptionalType.Type {
            type = optional.anyWrappedType
        } else {
            constraints.append(.notNull)
        }

        let typeName: FrontbaseDataType
        var primaryKeyDefault: FrontbasePrimaryKeyDefault = .default
        if let frontbase = type as? FrontbaseDataTypeStaticRepresentable.Type {
            switch frontbase.frontbaseDataType {
            case .bits (let size):
                typeName = .bits (size: size)
                primaryKeyDefault = .uid
            case .blob: typeName = .blob
            case .integer: typeName = .integer
            case .null: typeName = .null
            case .real: typeName = .real
            case .text (let size):
                typeName = .text (size: size)
                primaryKeyDefault = .rowID
            case .timestamp: typeName = .timestamp
            case .varyingbits (let size):
                typeName = .varyingbits (size: size)
                primaryKeyDefault = .uid
            }
        } else {
            typeName = .text (size: Int32.max)
        }

        if isIdentifier {
            constraints.append (.primaryKey (default: primaryKeyDefault, identifier: nil))
        }
        
        return .columnDefinition(field, typeName, constraints)
    }

    /// See `SchemaSupporting`.
    public static func schemaExecute(_ fluent: Schema, on conn: FrontbaseConnection) -> Future<Void> {
        let query: FrontbaseQuery
        switch fluent.statement {
        case ._createTable:
            var createTable: FrontbaseCreateTable = .createTable(fluent.table)
            createTable.columns = fluent.columns
            createTable.tableConstraints = fluent.constraints
            query = ._createTable(createTable)
        case ._alterTable:
            guard fluent.columns.count == 1 && fluent.constraints.count == 0 else {
                fatalError("Frontbase only supports adding one (1) column in an ALTER query.")
            }
            query = .alterTable(.init(
                table: fluent.table,
                value: .addColumn(fluent.columns[0])
            ))
        case ._dropTable:
            let dropTable: FrontbaseDropTable = .dropTable(fluent.table)
            query = ._dropTable(dropTable)
        }
        return conn.query(query).transform(to: ())
    }
    
    /// See `SchemaSupporting`.
    public static func enableReferences(on conn: FrontbaseConnection) -> Future<Void> {
        return conn.future()
    }
    
    /// See `SchemaSupporting`.
    public static func disableReferences(on conn: FrontbaseConnection) -> Future<Void> {
        return conn.future()
    }
}
