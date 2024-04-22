//
//  StoreError.swift
//  
//
//  Created by Илья Шаповалов on 21.04.2024.
//

import Foundation

/// Возможные ошибки, которые могу возникнут в ходе запроса.
public enum StoreError: Error, Equatable {
    
    /// Любой сценарий, не вписывающийся в остальные ошибки попадает сюда.
    case unknown
    
    /// Ошибка указывает на некорректно сформированный запрос.
    ///
    /// Ошибка `StoreError.badRequest` возникает по следующим причинам:
    /// - В запросах на поиск, добавление, обновление и удаление.
    /// Если сущность с указанным идентификатором не найдена в базе.
    /// - В запросе на создание или обновлении сущности,  неправильно заполнены поля модели.
    case badRequest(String)
    
    /// Возникает в запросах, связанных с сессией пользователя
    case unauthorized
    
    init(_ error: Error) {
        switch error {
        case let storeError as Self:
            self = storeError
            
        default: self = .unknown
        }
    }
}
