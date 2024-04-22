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
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        response = nil
    }
    
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
    
    func test_statusCode_200_success() {
        response = makeRequest(statusCode: 200)
        let data = true.description.data(using: .utf8)!
        let sut = PlatziFakeStore { _ in .success((data, self.response)) }
        
        sut.deleteProduct(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let deleted): XCTAssertTrue(deleted)
            case .failure:  XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_statusCode_201_success() {
        response = makeRequest(statusCode: 201)
        let data = true.description.data(using: .utf8)!
        let sut = PlatziFakeStore { _ in .success((data, self.response)) }
        
        sut.deleteProduct(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let deleted): XCTAssertTrue(deleted)
            case .failure:  XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_badRequestError() {
        response = makeRequest(statusCode: 400)
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
    
    func test_unauthorizedError() {
        response = makeRequest(statusCode: 401)
        let sut = PlatziFakeStore { _ in .success((Data(), self.response)) }
        
        sut.productList { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unauthorized)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
//    func test_
}

private extension StoreErrorTests {
    func makeRequest(statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(
            url: URL(string: "baz")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    }
}
