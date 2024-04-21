//
//  Product.swift
//
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import Foundation

/// Экземпляр содержит данные о продукте, возвращаемые с сервера.
///
/// Для создания  нового или обновления продукта, нужно использовать тип `NewProduct`
public struct Product: Codable, Equatable {
    public let id: Int
    public let title: String
    public let price: Int
    public let description: String
    public let images: [String]
    public let category: Category
}
