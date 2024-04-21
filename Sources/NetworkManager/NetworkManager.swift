//
//  NetworkManager.swift
//  
//
//  Created by Илья Шаповалов on 14.04.2024.
//

import Foundation
import SwiftFP

public struct NetworkManager {
    public typealias Response = (data: Data, response: URLResponse)
    
    private let session: URLSession
    private let saveResponse: (Response, URLRequest) -> Void
    private let loadResponse: (URLRequest) -> Response?

    
    public init(_ dependencies: Dependencies = .configured) {
        self.session = dependencies.session
        self.saveResponse = dependencies.saveResponse
        self.loadResponse = dependencies.loadResponse
    }
    
    public func perform(_ request: URLRequest) async -> Result<Response, Error> {
        await loadCacheIfAvailable(request)
            .mapRight(Result.success)
            .asyncMap(loadData(for:))
            .unwrap
    }
}

private extension NetworkManager {
    func loadCacheIfAvailable(_ request: URLRequest) -> Either<URLRequest, Response> {
        loadResponse(request).map(Either.right) ?? Either.left(request)
    }
    
    func loadData(for request: URLRequest) async -> Result<Response, Error> {
        await Result
            .success(request)
            .asyncMap(session.data)
            .map(saveDataToCache(for: request))
    }
    
    func saveDataToCache(for request: URLRequest) -> (Response) -> Response {
        { response in
            if request.httpMethod == "GET" {
                self.saveResponse(response, request)
            }
            return response
        }
    }
}

public extension NetworkManager {
    struct Dependencies {
        public var session: URLSession = .shared
        public var saveResponse: (Response, URLRequest) -> Void = { _,_ in }
        public var loadResponse: (URLRequest) -> Response? = { _ in nil }
        
        public static let configured = Self(
            session: .shared,
            saveResponse: NetworkCache.shared.save(_:for:),
            loadResponse: NetworkCache.shared.loadResponse(for:)
        )
    }
}
