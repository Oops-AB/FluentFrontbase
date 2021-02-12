public enum FluentFrontbaseSchemaStatement: FluentSQLSchemaStatement {
    public static var createTable: FluentFrontbaseSchemaStatement { return ._createTable }
    public static var alterTable: FluentFrontbaseSchemaStatement { return ._alterTable }
    public static var dropTable: FluentFrontbaseSchemaStatement { return ._dropTable }
    
    case _createTable
    case _alterTable
    case _dropTable
}

public struct FluentFrontbaseSchema: FluentSQLSchema {
    public typealias Statement = FluentFrontbaseSchemaStatement
    public typealias TableIdentifier = FrontbaseTableIdentifier
    public typealias ColumnDefinition = FrontbaseColumnDefinition
    public typealias TableConstraint = FrontbaseTableConstraint

    public var statement: Statement
    public var table: TableIdentifier
    public var columns: [FrontbaseColumnDefinition]
    public var deleteColumns: [FrontbaseColumnIdentifier]
    public var constraints: [FrontbaseTableConstraint]
    public var deleteConstraints: [FrontbaseTableConstraint]
    
    public static func schema(_ statement: Statement, _ table: TableIdentifier) -> FluentFrontbaseSchema {
        return .init(
            statement: statement,
            table: table,
            columns: [],
            deleteColumns: [],
            constraints: [],
            deleteConstraints: []
        )
    }
}
