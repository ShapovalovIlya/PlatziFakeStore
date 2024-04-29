//
//  Uploaded.swift
//
//
//  Created by Илья Шаповалов on 29.04.2024.
//

import Foundation

public struct Uploaded: Codable, Equatable {
    public let originalname: String
    public let filename: String
    public let location: String
}
