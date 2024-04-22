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
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
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
        response = makeResponse(statusCode: 200)
        let data = true.description.data(using: .utf8)!
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
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
        response = makeResponse(statusCode: 201)
        let data = true.description.data(using: .utf8)!
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
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
        response = makeResponse(statusCode: 400)
        let sut = PlatziStore { _ in .success((Data(), self.response)) }
        
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
        response = makeResponse(statusCode: 401)
        let sut = PlatziStore { _ in .success((Data(), self.response)) }
        
        sut.productList { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unauthorized)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_badUrl() {
        let sut = PlatziStore { _ in .failure(URLError(.badURL)) }
        
        sut.productList { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .badURL(.none))
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_decodingError() {
        response = makeResponse(statusCode: 200)
        let sut = PlatziStore { _ in .success((Data(), self.response)) }
        
        sut.productList { result in
            self.expectation.fulfill()
            switch result {
            case .failure(.decodeFail): XCTAssertTrue(true)
            default: XCTFail()
             }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}

private extension StoreErrorTests {
    func makeResponse(statusCode: Int) -> HTTPURLResponse? {
        HTTPURLResponse(
            url: URL(string: "baz")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    }
}
