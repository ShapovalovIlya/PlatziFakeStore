//
//  NewCategory.swift
//
//
//  Created by Илья Шаповалов on 21.04.2024.
//

import Foundation

/// Экземпляр предоставляет необходимую информацию для создания или обновления категории
/// в базе данных `Platzi Fake Store`
public struct NewCategory: Encodable {
    public let name: String
    public let image: String
    
    public init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
