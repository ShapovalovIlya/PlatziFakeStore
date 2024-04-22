//
//  StoreErrorTests.swift
//
//
//  Created by Илья Шаповалов on 22.04.2024.
//

import XCTest
@testable import PlatziFakeStore

final class StoreErrorTests: XCTestCase {
    private var response: HTTPURLResponse!
    private let expectation = XCTestExpectation()
    
    func test_unknownError() {
        let sut = PlatziFakeStore { _ in .failure(URLError(.unknown)) }
        
        sut.productList { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
                
            case .failure(let error):
                XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_badRequestError() {
        response = HTTPURLResponse(
            url: URL(string: "baz")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        let sut = PlatziFakeStore { _ in .success((Data(), self.response)) }
        
        sut.productList { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .badRequest(""))
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}
