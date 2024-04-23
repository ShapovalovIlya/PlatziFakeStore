//
//  Endpoint.swift
//
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import Foundation
import Endpoints

@usableFromInline
struct Platzi: ApiScheme {
    @usableFromInline static let scheme: String = "https"
    @usableFromInline static var host: String = "api.escuelajs.co"
    @usableFromInline static var basePathComponent: String = "/api/v1/"
}

extension Endpoint where API == Platzi {
    //MARK: - Pre constructed
    @inlinable func limit(_ l: Int) -> Self {
        self.queryItems {
            URLQueryItem(name: "limit", value: l.description)
        }
    }
    
    @inlinable func limit(_ l: Int, offset: Int) -> Self {
        self.limit(l)
            .queryItems {
                URLQueryItem(name: "offset", value: offset.description)
            }
    }
    
    //MARK: - Products
    @usableFromInline
    static let products = Self(path: "products")
    
    @inlinable
    static func productList(offset: Int = 0, limit: Int = 20) -> Self {
        Endpoint
            .products
            .limit(limit, offset: offset)
    }
    
    @inlinable
    static func product(withId id: Int) -> Self {
        Endpoint
            .products
            .addPath(id.description)
    }
    
    //MARK: - Users
    @usableFromInline
    static let users = Self(path: "users")
    static let userIsAvailable = Self.users.addPath("is-available")
    
    @inlinable
    static func userList(limit: Int = 20) -> Self {
        Endpoint
            .users
            .limit(limit)
    }
    
    @inlinable
    static func user(withId id: Int) -> Self {
        Endpoint
            .users
            .addPath(id.description)
    }
    
    //MARK: - Auth
    private static let auth = Self(path: "auth")
    
    static let login = Self.auth.addPath("login")
    static let profile = Self.auth.addPath("profile")
    static let refreshToken = Self.auth.addPath("refresh-token")
    
    //MARK: - Categories
    @usableFromInline
    static let categories = Self(path: "categories")
    
    @inlinable
    static func categoryList(limit: Int = 20) -> Self {
        Endpoint
            .categories
            .limit(limit)
    }
    
    @inlinable
    static func category(withId id: Int) -> Self {
        Endpoint
            .categories
            .addPath(id.description)
    }
    
    @inlinable
    static func productsFor(
        categoryId id: Int,
        limit: Int = 20,
        offset: Int = 0
    ) -> Self {
        Endpoint
            .category(withId: id)
            .addPath(Self.products.path)
            .limit(limit, offset: offset)
    }
    
    //MARK: - Files
    @usableFromInline
    static let files = Self(path: "files")
    
    static let upload = Self.files.addPath("upload")
    
    @inlinable
    static func file(named: String) -> Self {
        Endpoint
            .files
            .addPath(named)
    }
}
