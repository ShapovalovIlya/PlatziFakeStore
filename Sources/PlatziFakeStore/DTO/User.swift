//
//  User.swift
//
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import Foundation

public struct User: Decodable {
    public let id: Int
    public let email: String
    public let password: String
    public let name: String
    public let role: Role
    public let avatar: String
}

extension User {
    public enum Role: String, Decodable {
        case customer
        case admin
    }
}
