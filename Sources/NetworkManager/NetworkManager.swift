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
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    public init() {
        let config = URLSessionConfiguration.default
        self.init(session: URLSession(configuration: config))
    }
    
    @discardableResult
    public func request(_ request: URLRequest, completion: @escaping (Result<Response, Error>) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            error
                .map(Result.failure)
                .map(completion)
            
            data.merge(response)
                .map(Result.success)
                .map(completion)
        }
        task.resume()
        return task
    }
}
