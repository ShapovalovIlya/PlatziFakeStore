//
//  Request.swift
//  
//
//  Created by Илья Шаповалов on 19.04.2024.
//

import Foundation
import SwiftFP

public typealias Request = Box<URLRequest>

public extension Request {
    
    @inlinable static func new(_ url: URL) -> Self {
        Self(URLRequest(url: url))
    }
    
    @inlinable func method(_ m: HTTPMethod) -> Self {
        self.map { old in
            var new = old
            new.httpMethod = m.rawValue
            return new
        }
    }
    
    @inlinable func body(_ d: Data) -> Self {
        self.map { old in
            var new = old
            new.httpBody = d
            return new
        }
    }
    
    @inlinable
    func headers(@HeadersBuilder build: () -> [String : String]) -> Self {
        self.map { old in
            var new = old
            build().forEach { new.addValue($1, forHTTPHeaderField: $0) }
            return new
        }
    }
    
    @inlinable
    func tryMap(_ transform: (Request) throws -> Request) -> Result<Request, Error> {
        Result { try transform(self) }
    }
    
    @inlinable func contentHeader() -> Self {
        self.headers {
            Header(field: "Content-Type", value: "application/json")
            Header(field: "accept:", value: "*/*")
        }
    }
    
    @inlinable func addPayload(_ data: Data) -> Self {
        self.body(data)
            .contentHeader()
    }
    
    @inlinable func addBearer(_ token: String) -> Self {
        self.headers {
            Header(field: "Authorization", value: "Bearer ".appending(token))
        }
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
