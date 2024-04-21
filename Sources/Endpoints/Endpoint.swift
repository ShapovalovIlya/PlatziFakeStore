//
//  Endpoint.swift
//
//
//  Created by Илья Шаповалов on 21.03.2024.
//

import Foundation

public struct Endpoint<API: ApiScheme> {
    //MARK: - Internal properties
    public let path: String
    public let queryItems: [URLQueryItem]
    
    //MARK: - init(_:)
    @inlinable
    public init(
        path: String = .init(),
        queryItems: [URLQueryItem] = .init()
    ) {
        self.path = path
        self.queryItems = queryItems
    }
    
    @usableFromInline
    init(
        path: String = .init(),
        @QueryItemBuilder builder: () -> [URLQueryItem]
    ) {
        self.path = path
        self.queryItems = builder()
    }
    
    //MARK: - Public methods
    public var url: URL {
        var components = URLComponents()
        components.scheme = API.scheme
        components.host = API.host
        components.path = API.basePathComponent.appending(path)
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            preconditionFailure("Unable to create url from: \(components)")
        }
        return url
    }
}

public extension Endpoint {
    @inlinable
    func path(_ p: String) -> Self {
        Endpoint(path: p, queryItems: queryItems)
    }
    
    @inlinable
    func addPath(_ p: String) -> Self {
        Endpoint(
            path: path.appending("/").appending(p),
            queryItems: queryItems
        )
    }
    
    @inlinable
    func queryItems(@QueryItemBuilder _ builder: () -> [URLQueryItem]) -> Self {
        Endpoint(path: path) {
            queryItems
            builder()
        }
    }
    
    @inlinable
    func flatMap<T>(_ transform: (URL) throws -> T) rethrows -> T {
        try transform(url)
    }
    
    @inlinable
    func flatMap(_ transform: (Endpoint) throws -> Endpoint) rethrows -> Endpoint {
        try transform(self)
    }
}

