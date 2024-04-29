//
//  Uploaded.swift
//
//
//  Created by Илья Шаповалов on 29.04.2024.
//

import Foundation

/// Структура описывает результат сохранения файла в хранилище апи.
///
/// Содержит в себе деталищацию:
///  - оригинальное название
///  - название файла
///  - URL адрес файла
public struct Uploaded: Codable, Equatable {
    public let originalname: String
    public let filename: String
    public let location: String
}
