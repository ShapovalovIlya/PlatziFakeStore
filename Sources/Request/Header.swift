//
//  Header.swift
//  
//
//  Created by Илья Шаповалов on 20.04.2024.
//

import Foundation

public struct Header {
    public let field: String
    public let value: String
    
    public init(field: String, value: String) {
        self.field = field
        self.value = value
    }
}
