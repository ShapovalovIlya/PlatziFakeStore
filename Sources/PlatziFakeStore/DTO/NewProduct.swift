//
//  NewProduct.swift
//  
//
//  Created by Илья Шаповалов on 21.04.2024.
//

import Foundation

/// Экземпляр предоставляет необходимую информацию для создания или обновления продукта
/// в `API`
public struct NewProduct: Encodable {
    public let title: String
    public let price: Int
    public let description: String
    public let categoryId: Int
    
    /// images must contain at least 1 elements,
    /// images should not be empty,
    /// each value in images must be a URL address,
    public let images: [String]
    
    public init(
        title: String,
        price: Int,
        description: String,
        categoryId: Int,
        images: [String]
    ) {
        self.title = title
        self.price = price
        self.description = description
        self.categoryId = categoryId
        self.images = images
    }
}
