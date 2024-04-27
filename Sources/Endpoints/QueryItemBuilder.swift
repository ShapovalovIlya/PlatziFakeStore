//
//  QueryItemBuilder.swift
//  
//
//  Created by Илья Шаповалов on 14.04.2024.
//

import Foundation

@resultBuilder
public enum QueryItemBuilder {
    
    @inlinable
    public static func buildBlock(_ components: URLQueryItem...) -> [URLQueryItem] {
        components
    }
    
    @inlinable
    public static func buildBlock(_ components: [URLQueryItem]...) -> [URLQueryItem] {
        components.flatMap { $0 }
    }
    
    @inlinable
    public static func buildOptional(_ component: [URLQueryItem]?) -> [URLQueryItem] {
        component ?? []
    }
    
    @inlinable
    public static func buildArray(_ components: [[URLQueryItem]]) -> [URLQueryItem] {
        components.flatMap { $0 }
    }
    
    @inlinable
    public static func buildEither(first component: [URLQueryItem]) -> [URLQueryItem] {
        component
    }
    
    @inlinable
    public static func buildEither(second component: [URLQueryItem]) -> [URLQueryItem] {
        component
    }
}
