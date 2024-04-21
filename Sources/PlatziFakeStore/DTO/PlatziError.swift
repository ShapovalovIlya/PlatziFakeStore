//
//  PlatziError.swift
//
//
//  Created by Илья Шаповалов on 21.04.2024.
//

import Foundation

struct PlatziError: Decodable {
    let message: [String]
    let error: String
    let statusCode: Int
}
