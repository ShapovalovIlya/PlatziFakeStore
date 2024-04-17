//
//  NetworkCache.swift
//
//
//  Created by Илья Шаповалов on 17.04.2024.
//

import Foundation

public final class NetworkCache {
    public typealias Response = (data: Data, response: URLResponse)
    public static let shared = NetworkCache()
    
    private let cache: NSCache<NSURLRequest, AnyObject> = .init()
    
    public func save(_ response: Response, for request: URLRequest) {
        cache.setObject(ResponseReference(response), forKey: request as NSURLRequest)
    }
    
    public func loadResponse(for request: URLRequest) -> Response? {
        cache.object(forKey: request as NSURLRequest)
            .flatMap { $0 as? Response }
    }
    
    private init() {}
}

private extension NetworkCache {
    final class ResponseReference {
        let response: Response
        
        init(_ response: Response) {
            self.response = response
        }
    }
}
