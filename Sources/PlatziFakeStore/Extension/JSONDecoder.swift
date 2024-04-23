//
//  
// JSONDecoder.swift
//
//
//  Created by Илья Шаповалов on 23.04.2024.
//

import Foundation

extension JSONDecoder {
    static let platziDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
