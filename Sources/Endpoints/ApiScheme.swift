//
//  ApiScheme.swift
//  
//
//  Created by Илья Шаповалов on 20.04.2024.
//

import Foundation

public protocol ApiScheme {
    static var scheme: String { get }
    static var host: String { get }
    static var basePathComponent: String { get }
}
