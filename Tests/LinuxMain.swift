#if os(Linux)

import XCTest
@testable import FluentFrontbaseTests

XCTMain([
    testCase(FrontbaseBenchmarkTests.allTests),
])

#endif
