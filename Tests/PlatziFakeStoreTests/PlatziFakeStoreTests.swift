import XCTest
@testable import PlatziFakeStore

final class PlatziFakeStoreTests: XCTestCase {
    private var response: URLResponse!
    private var expectation: XCTestExpectation!
    private var productData: Data!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        productData = try JSONEncoder().encode(mockProduct)
        response = HTTPURLResponse(
            url: URL(string: "baz")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        expectation = XCTestExpectation()
    }
    
    func test_getAllProductsSuccess() throws {
        let data = try JSONEncoder().encode([mockProduct])
        
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
        
        sut.create(product: mockProduct) { result in
            self.expectation.fulfill()
            switch result {
            case .success(let product): XCTAssertEqual(mockProduct, product)
            case .failure: XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_postProductFailed() throws {
        let sut = PlatziFakeStore { _ in .failure(URLError(.badURL)) }
        
        sut.create(product: mockProduct) { result in
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

private let mockCategory = Category(id: 1, name: "baz", image: "baz")
