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
    public static func buildBlock(_ components: Header...) -> [String: String] {
        components.reduce(into: [String: String]()) { $0[$1.field] = $1.value }
    }
    
    @inlinable
    public static func buildBlock(_ components: [Header]...) -> [String: String] {
        buildBlock(components.flatMap { $0 })
    }
    
    @inlinable
    public static func buildExpression(_ expression: [Header]) -> [String : String] {
        buildBlock(expression)
    }
    
    @inlinable
    public static func buildExpression(_ expression: Header) -> [String : String] {
        [expression.field: expression.value]
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
