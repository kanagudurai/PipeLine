//
//  iOSHelloWorldTests.swift
//  iOSHelloWorldTests
//
//  Created by Madhuri Gummalla on 9/12/17.
//
//

@testable import iOSHelloWorld
import XCTest

class IOSHelloWorldTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        XCTAssertTrue(true)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
