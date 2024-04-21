//
//  Category.swift
//  
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import Foundation

/// Экземпляр содержит данные о категории, возвращаемые с сервера.
///
/// Для создания или обновления категории, используйте тип `NewCategory`
public struct Category: Codable, Equatable {
    public let id: Int
    public let name: String
    public let image: String
}
