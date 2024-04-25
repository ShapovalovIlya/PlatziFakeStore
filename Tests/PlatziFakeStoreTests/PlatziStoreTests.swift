import XCTest
@testable import PlatziFakeStore

final class PlatziStoreTests: XCTestCase {
    private let encoder = JSONEncoder()
    
    private var response: HTTPURLResponse!
    private var expectation: XCTestExpectation!
    private var productData: Data!
    private var categoryData: Data!
    private var userData: Data!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        productData = try encoder.encode(mockProduct)
        categoryData = try encoder.encode(mockCategory)
        userData = try encoder.encode(mockUser)
        
        response = HTTPURLResponse(
            url: URL(string: "baz")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        expectation = XCTestExpectation()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        productData = nil
        categoryData = nil
        userData = nil
        response = nil
        expectation = nil
    }
    
    //MARK: - Product
    func test_getAllProductsSuccess() throws {
        let data = try encoder.encode([mockProduct])
        
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.productList { result in
            self.expectation.fulfill()
            switch result {
            case .success(let products): XCTAssertEqual([mockProduct], products)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_getAllProductsFailed() throws {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.productList { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_getProductWithIdSuccess() throws {
        let sut = PlatziStore { _ in .success((self.productData, self.response)) }
        
        sut.product(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let product): XCTAssertEqual(mockProduct, product)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_postProductSuccess() throws {
        let sut = PlatziStore { _ in .success((self.productData, self.response)) }
        
        sut.create(product: newProduct) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let product): XCTAssertEqual(mockProduct, product)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_postProductFailed() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.create(product: newProduct) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_updateProductWithIdSuccess() {
        let sut = PlatziStore { _ in .success((self.productData, self.response)) }
        
        sut.updateProduct(withId: 0, new: newProduct) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let updated): XCTAssertEqual(mockProduct, updated)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_updateProductWithIdFailed() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.updateProduct(withId: 0, new: newProduct) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_deleteProductWithIdSuccess() throws {
        let data = try JSONEncoder().encode(true)
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.deleteProduct(withId: 0) { result in
            self.expectation.fulfill()
            switch result {
            case let .success(deleted): XCTAssertTrue(deleted)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_deleteProductWithIdFailed() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.deleteProduct(withId: 0) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    //MARK: - Category
    func test_categoryListSuccess() throws {
        let data = try encoder.encode([mockCategory])
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.categoryList(limit: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let categories): XCTAssertEqual(categories, [mockCategory])
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

    func test_categoryListFailure() throws {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.categoryList(limit: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_createNewCategorySuccess() throws {
        let sut = PlatziStore { _ in .success((self.categoryData, self.response)) }
        
        sut.create(category: newCategory) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let category): XCTAssertEqual(mockCategory, category)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_createNewCategoryFailed() throws {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.create(category: newCategory) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_categoryWithIdSuccess() {
        let sut = PlatziStore { _ in .success((self.categoryData, self.response)) }
        
        sut.category(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let category): XCTAssertEqual(category, mockCategory)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_categoryWithIdFailure() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.category(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_updateCategoryWithIdSuccess() {
        let sut = PlatziStore { _ in .success((self.categoryData, self.response)) }
        
        sut.updateCategory(withId: 1, new: newCategory) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let category): XCTAssertEqual(category, mockCategory)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_updateCategoryWithIdFailed() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.updateCategory(withId: 1, new: newCategory) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_deleteCategoryWithIdSuccess() throws {
        let data = try encoder.encode(true)
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.deleteCategory(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let deleted): XCTAssertTrue(deleted)
            case .failure: XCTFail()
            }
        }
    }
    
    func test_deleteCategoryWithIdFailure() throws {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.deleteCategory(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_productListForCategoryIdSuccess() throws {
        let data = try encoder.encode([mockProduct])
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.productList(categoryId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let products): XCTAssertEqual(products, [mockProduct])
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_productListForCategoryIdFailed() throws {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.productList(categoryId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    //MARK: - Users
    func test_userListSuccess() throws {
        let data = try encoder.encode([mockUser])
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.userList(limit: 1) { result in
            self.expectation.fulfill()
            switch result {
            case let .success(users): XCTAssertEqual(users, [mockUser])
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_userListFailed() throws {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.userList(limit: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_createUserSuccess() throws {
        let sut = PlatziStore(
            performRequest: { _ in .success((self.userData, self.response)) },
            isEmailValid: { _ in true }
        )
        
        sut.create(user: newUser) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let user): XCTAssertEqual(user, mockUser)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_createUserFailed() throws {
        let sut = PlatziStore(
            performRequest: { _ in .failure(CocoaError(.featureUnsupported)) },
            isEmailValid: { _ in true }
        )
        
        sut.create(user: newUser) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_userWithIdSuccess() {
        let sut = PlatziStore { _ in .success((self.userData, self.response)) }
        
        sut.user(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let user): XCTAssertEqual(user, mockUser)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_userWithIdFailed() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.user(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_updateUserWithIdSuccess() {
        let sut = PlatziStore { _ in .success((self.userData, self.response)) }
        
        sut.updateUser(withId: 1, new: newUser) { result in
            self.expectation.fulfill()
            switch result {
            case let .success(user): XCTAssertEqual(user, mockUser)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_updateUserWithIdFail() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.updateUser(withId: 1, new: newUser) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

    func test_deleteUserWithIdSuccess() throws {
        let data = try encoder.encode(true)
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.deleteUser(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case let .success(deleted): XCTAssertTrue(deleted)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_deleteUserWithIdFail() throws {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.deleteUser(withId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    //MARK: - Login
    func test_loginSuccess() throws {
        let mockTokens = Tokens(accessToken: "baz", refreshToken: "bar")
        let data = try encoder.encode(mockTokens)
        let sut = PlatziStore(
            performRequest: { _ in .success((data, self.response)) },
            isEmailValid: { _ in true } 
        )
        
        sut.login(email: "baz@bare.foo", password: "bar") { result in
            self.expectation.fulfill()
            switch result {
            case let .success(login): XCTAssertTrue(login)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_loginFail() {
        let sut = PlatziStore(
            performRequest: { _ in .failure(CocoaError(.featureUnsupported)) },
            isEmailValid: { _ in true }
        )
        
        sut.login(email: "baz@bare.foo", password: "bar") { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_profileSuccess() {
        let sut = PlatziStore(
            performRequest: { _ in .success((self.userData, self.response)) },
            isEmailValid: { _ in true },
            loadTokenForEmail: { _ in "" }
        )
        
        sut.profile(withEmail: "baz@bare.foo") { result in
            self.expectation.fulfill()
            switch result {
            case .success(let user): XCTAssertEqual(user, mockUser)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_profileFailure() {
        let sut = PlatziStore(
            performRequest: { _ in .failure(CocoaError(.featureUnsupported)) },
            isEmailValid: { _ in true },
            loadTokenForEmail: { _ in "" }
        )
        
        sut.profile(withEmail: "baz") { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    //MARK: - Search
    
    func test_searchProductByTitleSuccess() throws {
        let data = try encoder.encode([mockProduct])
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.searchProduct(named: "baz") { result in
            self.expectation.fulfill()
            switch result {
            case .success(let products): XCTAssertEqual(products, [mockProduct])
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_searchProductByTitleFail() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.searchProduct(named: "baz") { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_searchProductByCategoryIdSuccess() throws {
        let data = try encoder.encode([mockProduct])
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.searchProduct(categoryId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let products): XCTAssertEqual(products, [mockProduct])
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_searchProductByCategoryIdFail() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.searchProduct(categoryId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_searchProductByNameAndCategoryIdSuccess() throws {
        let data = try encoder.encode([mockProduct])
        let sut = PlatziStore { _ in .success((data, self.response)) }
        
        sut.searchProduct(named: "baz", categoryId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let products): XCTAssertEqual(products, [mockProduct])
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_searchProductByNameAndCategoryIdFail() {
        let sut = PlatziStore { _ in .failure(CocoaError(.featureUnsupported)) }
        
        sut.searchProduct(named: "baz", categoryId: 1) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}

private let mockUser = User(
    id: 1,
    email: "baz@bare.foo",
    password: "bar",
    name: "foo",
    role: .customer,
    avatar: "baz"
)

private let mockProduct = Product(
    id: 1,
    title: "baz",
    price: 1,
    description: "baz",
    images: [],
    category: mockCategory
)

private let newProduct = NewProduct(
    title: "baz",
    price: 1,
    description: "baz",
    categoryId: 1,
    images: []
)

private let newUser = NewUser(
    email: "baz@bare.foo",
    name: "foo",
    password: "bar",
    role: .customer,
    avatar: "baz"
)

private let newCategory = NewCategory(name: "baz", image: "bar")
private let mockCategory = Category(id: 1, name: "baz", image: "baz")
