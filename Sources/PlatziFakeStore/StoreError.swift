//
//  StoreError.swift
//  
//
//  Created by Илья Шаповалов on 21.04.2024.
//

import Foundation

public enum StoreError: Error {
    case unknown
    case unauthorized
    
    init(_ error: Error) { self = .unknown }
}
