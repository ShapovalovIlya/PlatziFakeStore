//
//  StoreError.swift
//  
//
//  Created by Илья Шаповалов on 21.04.2024.
//

import Foundation

public enum StoreError: Error, Equatable {
    case unknown
    case badRequest(String)
    case unauthorized
    
    init(_ error: Error) { self = .unknown }
}
