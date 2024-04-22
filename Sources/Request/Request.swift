//
//  Request.swift
//  
//
//  Created by Илья Шаповалов on 19.04.2024.
//

import Foundation

public struct Request {
    @usableFromInline let method: HTTPMethod
    @usableFromInline let url: URL
    @usableFromInline let headers: [String: String]
    @usableFromInline let body: Data?
    
    public var constructed: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
    
    //MARK: - init(_:)
    @inlinable
    init(
        method: HTTPMethod = .GET,
        url: URL,
        body: Data? = nil,
        headers: [String : String] = .init()
    ) {
        self.method = method
        self.url = url
        self.body = body
        self.headers = headers
    }
    
    @inlinable
    init(
        method: HTTPMethod = .GET,
        url: URL,
        body: Data? = nil,
        @HeadersBuilder build: () -> [String : String]
    ) {
        self.method = method
        self.url = url
        self.body = body
        self.headers = build()
    }
}

public extension Request {
    @inlinable
    static func create(_ url: URL) -> Self {
        Request(url: url)
    }
    
    @inlinable
    func method(_ m: HTTPMethod) -> Self {
        Request(method: m, url: url, body: body, headers: headers)
    }
    
    @inlinable
    func body(_ d: Data) -> Self {
        Request(method: method, url: url, body: d, headers: headers)
    }
    
    @inlinable
    func headers(@HeadersBuilder build: () -> [String : String]) -> Self {
        Request(method: method, url: url, body: body) {
            headers
            build()
        }
    }
    
    @inlinable
    func tryMap(_ transform: (Request) throws -> Request) -> Result<Request, Error> {
        Result { try transform(self) }
    }
}

public extension Request {
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
}
