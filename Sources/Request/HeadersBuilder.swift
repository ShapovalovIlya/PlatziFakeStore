//
//  HeadersBuilder.swift
//
//
//  Created by Илья Шаповалов on 19.04.2024.
//

import Foundation

@resultBuilder
public enum HeadersBuilder {
    
    @inlinable
    public static func buildBlock(_ components: Request.Header...) -> [String: String] {
        components.reduce(into: [String: String]()) { $0[$1.field] = $1.value }
    }
    
    @inlinable
    public static func buildBlock(_ components: [Request.Header]...) -> [String: String] {
        components
            .flatMap { $0 }
            .reduce(into: [String: String]()) { $0[$1.field] = $1.value }
    }
    
    @inlinable
    public static func buildExpression(_ expression: [Request.Header]) -> [String : String] {
        expression.reduce(into: [String: String]()) { $0[$1.field] = $1.value }
    }
    
    @inlinable
    public static func buildExpression(_ expression: [String : String]) -> [String : String] {
        expression
    }
    
    @inlinable
    public static func buildBlock(_ components: [String : String]...) -> [String : String] {
        components.reduce(into: [String : String]()) { partialResult, component in
            partialResult.merge(component) { $1 }
        }
    }
}
