//
//  RequestTests.swift
//  
//
//  Created by Шаповалов Илья on 19.04.2024.
//

import XCTest
@testable import Request

final class RequestTests: XCTestCase {
    private var mockUrl: URL!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockUrl = URL(string: "baz")!
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        mockUrl = nil
    }
    
    func test_constructedRequest() {
        let sut = Request.new(mockUrl)
            .method(.GET)
            .body("bar".data(using: .utf8)!)
            .headers {
                Header(field: "baz", value: "bar")
            }
            .value
        
        XCTAssertEqual(sut.httpMethod, "GET")
        XCTAssertEqual(sut.url?.absoluteString, "baz")
        XCTAssertEqual(sut.allHTTPHeaderFields?.contains(where: { $0.key == "baz" }), true)
        guard let body = sut.httpBody else {
            XCTFail()
            return
        }
        XCTAssertEqual(String(data: body, encoding: .utf8), "bar")
    }
    
    
}
