//
//  Product.swift
//
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import Foundation

public struct Product: Codable, Equatable {
    public let id: Int
    public let title: String
    public let price: Int
    public let description: String
    
    /// images must contain at least 1 elements,
    /// images should not be empty,
    /// each value in images must be a URL address,
    public let images: [String]
    public let category: Category
}
