import XCTest
@testable import PlatziFakeStore

final class PlatziFakeStoreTests: XCTestCase {
    private let encoder = JSONEncoder()
    
    private var response: HTTPURLResponse!
    private var expectation: XCTestExpectation!
    private var productData: Data!
    private var categoryData: Data!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        productData = try encoder.encode(mockProduct)
        categoryData = try encoder.encode(mockCategory)
        
        response = HTTPURLResponse(
            url: URL(string: "baz")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        expectation = XCTestExpectation()
    }
    
    //MARK: - Product
    func test_getAllProductsSuccess() throws {
        let data = try encoder.encode([mockProduct])
        
        let sut = PlatziFakeStore { _ in .success((data, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .failure(URLError(.unknown)) }
        
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
        let sut = PlatziFakeStore { _ in .success((self.productData, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .success((self.productData, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .failure(URLError(.badURL)) }
        
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
        let sut = PlatziFakeStore { _ in .success((self.productData, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .failure(URLError(.badURL)) }
        
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
        let sut = PlatziFakeStore { _ in .success((data, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .failure(URLError(.badURL)) }
        
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
        let sut = PlatziFakeStore { _ in .success((data, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .failure(URLError(.unknown)) }
        
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
        let sut = PlatziFakeStore { _ in .success((self.categoryData, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .failure(URLError(.unknown)) }
        
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
        let sut = PlatziFakeStore { _ in .success((self.categoryData, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .failure(URLError(.unknown)) }
        
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
        let sut = PlatziFakeStore { _ in .success((self.categoryData, self.response)) }
        
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
        let sut = PlatziFakeStore { _ in .failure(URLError(.unknown)) }
        
        sut.updateCategory(withId: 1, new: newCategory) { result in
            self.expectation.fulfill()
            switch result {
            case .success: XCTFail()
            case .failure(let error): XCTAssertEqual(error, .unknown)
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}

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

private let newCategory = NewCategory(name: "baz", image: "bar")
private let mockCategory = Category(id: 1, name: "baz", image: "baz")
