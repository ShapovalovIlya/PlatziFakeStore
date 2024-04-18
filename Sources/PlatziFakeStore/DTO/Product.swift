//
//  Product.swift
//
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import Foundation

public struct Product: Decodable {
    public let id: Int
    public let title: String
    public let price: Int
    public let description: String
    public let images: [String]
    public let category: Category
}
