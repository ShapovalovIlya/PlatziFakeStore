//
//  EndpointTests.swift
//
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import XCTest
@testable import Endpoints

final class EndpointTests: XCTestCase {
    //MARK: - Products
    func test_productEndpoint() {
        let sut = Endpoint.products
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/products"
        )
    }
    
    func test_productListEndpointDefaultOffset() {
        let sut = Endpoint.productList()
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/products?limit=20&offset=0"
        )
    }
    
    func test_productListEndpointCustomOffset() {
        let sut = Endpoint.productList(offset: 1, limit: 10)
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/products?limit=10&offset=1"
        )
    }
    
    func test_productWithId() {
        let sut = Endpoint.product(withId: 1)
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/products/1"
        )
    }
    
    //MARK: - Users
    func test_usersEndpoint() {
        let sut = Endpoint.users
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/users"
        )
    }
    
    func test_userListDefaultLimit() {
        let sut = Endpoint.userList()
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/users?limit=20"
        )
    }
    
    func test_userListCustomLimit() {
        let sut = Endpoint.userList(limit: 1)
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/users?limit=1"
        )
    }
    
    func test_userWithId() {
        let sut = Endpoint.user(withId: 1)
        
        XCTAssertEqual(sut.url.absoluteString, "https://api.escuelajs.co/api/v1/users/1")
    }
    
    func test_userIsAvailable() {
        let sut = Endpoint.userIsAvailable
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/users/is-available"
        )
    }
    
    //MARK: - Auth
    
    func test_login() {
        let sut = Endpoint.login
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/auth/login"
        )
    }
    
    func test_profile() {
        let sut = Endpoint.profile
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/auth/profile"
        )
    }
    
    func test_refreshToken() {
        let sut = Endpoint.refreshToken
        
        XCTAssertEqual(
            sut.url.absoluteString,
            "https://api.escuelajs.co/api/v1/auth/refresh-token"
        )
    }
    
    //MARK: - Categories
    func test_categories() {
        let sut = Endpoint.categories
        
        XCTAssertEqual(
            "https://api.escuelajs.co/api/v1/categories",
            sut.url.absoluteString
        )
    }
    
    func test_categoryListDefaultLimit() {
        let sut = Endpoint.categoryList()
        
        XCTAssertEqual(
            "https://api.escuelajs.co/api/v1/categories?limit=20",
            sut.url.absoluteString
        )
    }
    
    func test_categoryListCustomLimit() {
        let sut = Endpoint.categoryList(limit: 1)
        
        XCTAssertEqual(
            "https://api.escuelajs.co/api/v1/categories?limit=1",
            sut.url.absoluteString
        )
    }
    
    func test_categoryWithId() {
        let sut = Endpoint.category(withId: 1)
        
        XCTAssertEqual(
            "https://api.escuelajs.co/api/v1/categories/1",
            sut.url.absoluteString
        )
    }
    
    func test_productsForCategoryIdDefaultOffset() {
        let sut = Endpoint.productsFor(categoryId: 1)
        
        XCTAssertEqual(
            "https://api.escuelajs.co/api/v1/categories/1/products?limit=20&offset=0",
            sut.url.absoluteString
        )
    }
    
    func test_productsForCategoryIdCustomOffset() {
        let sut = Endpoint.productsFor(categoryId: 1, limit: 1, offset: 1)
        
        XCTAssertEqual(
            "https://api.escuelajs.co/api/v1/categories/1/products?limit=1&offset=1",
            sut.url.absoluteString
        )
    }
    
    //MARK: - Files
    
    func test_upload() {
        let sut = Endpoint.upload
        
        XCTAssertEqual(
            "https://api.escuelajs.co/api/v1/files/upload",
            sut.url.absoluteString
        )
    }
    
    func test_fileNamed() {
        let sut = Endpoint.file(named: "baz")
        
        XCTAssertEqual(
            "https://api.escuelajs.co/api/v1/files/baz",
            sut.url.absoluteString
        )
    }
}
