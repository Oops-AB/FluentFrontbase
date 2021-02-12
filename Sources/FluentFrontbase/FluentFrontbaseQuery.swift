public enum FluentFrontbaseQueryStatement: FluentSQLQueryStatement {
    public static var insert: FluentFrontbaseQueryStatement { return ._insert }
    public static var select: FluentFrontbaseQueryStatement { return ._select }
    public static var update: FluentFrontbaseQueryStatement { return ._update }
    public static var delete: FluentFrontbaseQueryStatement { return ._delete }
    
    public var isInsert: Bool {
        switch self {
        case ._insert: return true
        default: return false
        }
    }
    
    case _insert
    case _select
    case _update
    case _delete
}

public struct FluentFrontbaseQuery: FluentSQLQuery {
    public typealias Statement = FluentFrontbaseQueryStatement
    public typealias TableIdentifier = FrontbaseTableIdentifier
    public typealias Expression = FrontbaseExpression
    public typealias SelectExpression = FrontbaseSelectExpression
    public typealias Join = FrontbaseJoin
    public typealias OrderBy = FrontbaseOrderBy
    public typealias GroupBy = FrontbaseGroupBy
    public typealias RowDecoder = FrontbaseRowDecoder
    
    public var statement: Statement
    public var table: TableIdentifier
    public var keys: [SelectExpression]
    public var values: [String : Expression]
    public var joins: [Join]
    public var predicate: Expression?
    public var orderBy: [OrderBy]
    public var groupBy: [GroupBy]
    public var limit: Int?
    public var offset: Int?
    public var defaultBinaryOperator: GenericSQLBinaryOperator

    public static func query(_ statement: Statement, _ table: TableIdentifier) -> FluentFrontbaseQuery {
        return .init(
            statement: statement,
            table: table,
            keys: [],
            values: [:],
            joins: [],
            predicate: nil,
            orderBy: [],
            groupBy: [],
            limit: nil,
            offset: nil,
            defaultBinaryOperator: .and
        )
    }
}
