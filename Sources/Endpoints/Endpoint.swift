//
//  Endpoint.swift
//
//
//  Created by Илья Шаповалов on 28.04.2024.
//

import Foundation
import SwiftFP

public typealias Endpoint = Monad<URLComponents>

public extension Endpoint {
    static let new = Self(URLComponents())
    
    @inlinable
    var url: Monad<URL> {
        self.map { components in
            guard let url = components.url else {
                preconditionFailure("Unable to create url from: \(components)")
            }
            return url
        }
    }
    
    @inlinable
    func addPath(_ p: String = .init()) -> Self {
        self.map { old in
            var new = old
            new.path = old.path.appending("/").appending(p)
            return new
        }
    }
    
    @inlinable
    func queryItems(@QueryItemBuilder _ build: () -> [URLQueryItem]) -> Self {
        self.map { old in
            var new = old
            if new.queryItems != nil {
                new.queryItems?.append(contentsOf: build())
            } else {
                new.queryItems = build()
            }
            return new
        }
    }
    
    //MARK: - Pre constructed
    static let platziApi = Self.new.map { old in
        var new = old
        new.scheme = "https"
        new.host = "api.escuelajs.co"
        new.path = "/api/v1"
        return new
    }
    
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
    static let products = Self.platziApi.addPath("products")
    
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
    static let users = Self.platziApi.addPath("users")
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
    private static let auth = Self.platziApi.addPath("auth")
    
    static let login = Self.auth.addPath("login")
    static let profile = Self.auth.addPath("profile")
    static let refreshToken = Self.auth.addPath("refresh-token")
    
    //MARK: - Categories
    static let categories = Self.platziApi.addPath("categories")
    
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
            .addPath("products")
            .limit(limit, offset: offset)
    }
    
    //MARK: - Files
    static let files = Self.platziApi.addPath("files")
    static let upload = Self.files.addPath("upload")
    
    @inlinable
    static func file(named: String) -> Self {
        Endpoint
            .files
            .addPath(named)
    }
    
    //MARK: - Search
    
    @inlinable
    static func searchProducts(_ options: [SearchOption]) -> Self {
        Endpoint
            .products
            .addPath()
            .queryItems {
                ForEachItem(options) { option in
                    switch option {
                    case let .title(title):
                        return URLQueryItem(name: "title", value: title)
                        
                    case let .categoryId(id):
                        return URLQueryItem(name: "categoryId", value: id.description)
                        
                    case let .priceMin(min):
                        return URLQueryItem(name: "price_min", value: min.description)
                        
                    case let .priceMax(max):
                        return URLQueryItem(name: "price_max", value: max.description)
                    }
                }
            }
    }

}

public enum SearchOption {
    case title(String)
    case categoryId(Int)
    case priceMin(Int)
    case priceMax(Int)
}

@usableFromInline
@QueryItemBuilder
func ForEachItem<T>(
    _ data: [T],
    buildQuery: @escaping (T) -> URLQueryItem
) -> [URLQueryItem] {
    for element in data {
        buildQuery(element)
    }
}
