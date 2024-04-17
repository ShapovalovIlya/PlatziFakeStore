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
    
    override func setUp() async throws {
        try await super.setUp()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubProtocol.self]
        mockSession = URLSession(configuration: config)
        
        sut = NetworkManager(
            .init(session: mockSession)
        )
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        
        sut = nil
        mockSession = nil
    }
    
    func test_loadDataFromCache() async {
        let data = "baz".data(using: .utf8)!
        
        sut = NetworkManager(
            .init(loadResponse: { _ in (data, URLResponse()) })
        )
        
        let result = await sut.perform(URLRequest(url: URL(string: "baz")!))
        
        switch result {
        case .success(let success):
            XCTAssertEqual(String(data: success.data, encoding: .utf8), "baz")
            
        case .failure:
            XCTFail()
        }
    }
    
}

private final class StubProtocol: URLProtocol {
    static var responseHandler: ((URL) -> Result<NetworkManager.Response, Error>)?
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
        _ result: Result<NetworkManager.Response, Error>,
        _ client: any URLProtocolClient
    ) {
        switch result {
        case let .success(success):
            client.urlProtocol(self, didReceive: success.response, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(self, didLoad: success.data)
            
        case let .failure(error):
            client.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() { }
//    override class func canInit(with task: URLSessionTask) -> Bool { true }
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
}
