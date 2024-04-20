//
//  NetworkManagerTests.swift
//
//
//  Created by Илья Шаповалов on 17.04.2024.
//

import XCTest
@testable import NetworkManager

final class NetworkManagerTests: XCTestCase {
    private var sut: NetworkManager!
    private var mockSession: URLSession!
    private var mockRequest: URLRequest!
    
    override func setUp() async throws {
        try await super.setUp()
        
        URLProtocol.registerClass(StubProtocol.self)
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubProtocol.self]
        
        mockSession = URLSession(configuration: config)
        mockRequest = URLRequest(url: URL(string: "baz")!)
        sut = NetworkManager(
            .init(session: mockSession)
        )
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        
        URLProtocol.unregisterClass(StubProtocol.self)
        
        sut = nil
        mockSession = nil
    }
    
    func test_loadDataFromCache() async {
        let data = "baz".data(using: .utf8)!
        
        sut = NetworkManager(
            .init(loadResponse: { _ in (data, URLResponse()) })
        )
        
        let result = await sut.perform(mockRequest)
        
        switch result {
        case .success(let success):
            XCTAssertEqual(String(data: success.data, encoding: .utf8), "baz")
            
        case .failure:
            XCTFail()
        }
    }
    
    func test_managerStartLoading() async {
        _ = await sut.perform(mockRequest)
        
        XCTAssertTrue(StubProtocol.didStartLoading)
    }
    
    func test_managerRequestEndWithSuccess() async {
        StubProtocol.responseHandler = { _ in .success("baz".data(using: .utf8)!) }
        
        let result = await sut.perform(mockRequest)
        
        switch result {
        case .success(let success):
            XCTAssertEqual(String(data: success.data, encoding: .utf8), "baz")
            
        case .failure:
            XCTFail()
        }
    }
    
    func test_managerRequestEndWithError() async {
        StubProtocol.responseHandler = { _ in .failure(URLError(.badURL)) }
        
        let result = await sut.perform(mockRequest)
        
        switch result {
        case .success:
            XCTFail()
            
        case .failure(let error):
            XCTAssertTrue(error is URLError)
        }
    }
    
    func test_managerSaveSuccessResponse() async {
        StubProtocol.responseHandler = { _ in .success("baz".data(using: .utf8)!) }
        var isSaved = false
        sut = .init(
            .init(
                session: mockSession,
                saveResponse: { _,_ in isSaved = true }
            )
        )
        
        _ = await sut.perform(mockRequest)
        
        XCTAssertTrue(isSaved)
    }
    
}

private final class StubProtocol: URLProtocol {
    static var responseHandler: ((URL) -> Result<Data, Error>) = { _ in .failure(URLError(.unknown)) }
    static var didStartLoading = false
    
    override func startLoading() {
        Self.didStartLoading = true
        request.url
            .apply(Self.responseHandler)
            .merge(client)
            .map(redirectResult)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    private func redirectResult(
        _ result: Result<Data, Error>,
        _ client: any URLProtocolClient
    ) {
        client.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .notAllowed)
        
        switch result {
        case let .success(data):
            client.urlProtocol(self, didLoad: data)
            
        case let .failure(error):
            client.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() { }
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
}
