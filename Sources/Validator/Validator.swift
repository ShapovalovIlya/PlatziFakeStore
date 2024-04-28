//
//  Validator.swift
//
//
//  Created by Илья Шаповалов on 23.04.2024.
//

import Foundation
import SwiftFP

public enum Validator {
    
    /// Проверяет валидность  указанного почтового адреса
    /// - Parameter email: адрес для проверки
    /// - Returns: результат, удовлетворяет ли почтовый адрес требованиям
    ///
    /// Требования к корректному почтовому адресу:
    ///  - наличие `@`
    ///  - адрес не должен начинаться или заканчиваться на `@`
    ///  - после символа `@`, адрес должен содержать знак `.`
    ///  - между `@` и знаком `.` должно быть не меньше 4 символов
    public static func isValid(email: String) -> Bool {
        email
            .lastIndex(of: "@")
            .flatMap { $0 != email.startIndex ? $0 : nil }
            .flatMap { $0 != email.indices.last ? $0 : nil }
            .flatMap { "." != email.last ? $0 : nil }
            .merge(email.lastIndex(of: "."))
            .flatMap { $1 > $0  ? ($0, $1) : nil }
            .map(email.distance)
            .flatMap { $0 > 3 ? true : nil }
            .map { _ in true } ?? false
    }
}
