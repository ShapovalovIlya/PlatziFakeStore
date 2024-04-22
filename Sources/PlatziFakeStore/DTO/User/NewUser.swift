//
//  NewUser.swift
//
//
//  Created by Илья Шаповалов on 22.04.2024.
//

import Foundation

public struct NewUser: Encodable {
    public let email: String
    public let name: String
    public let password: String
    public let role: UserRole
    public let avatar: String
    
    public init(
        email: String,
        name: String,
        password: String,
        role: UserRole,
        avatar: String
    ) {
        self.email = email
        self.name = name
        self.password = password
        self.role = role
        self.avatar = avatar
    }
}
