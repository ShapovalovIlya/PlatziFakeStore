import Foundation
import NetworkManager
import Endpoints
import SwiftFP
import Request

/// Тип предназанчен для взаимодействия с `Platzi Fake Store API`.
///
/// Для получения данных, обратитесь к экземпляру `PlatziStore.shared`.
/// Он содержит в себе набор методов для взаимодействия.
///
/// Результат работы `PlatziStore` может выполняться на background потоке.
public final class PlatziStore {
    typealias Response = (data: Data, response: URLResponse)
    
    //MARK: - Private properties
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let performRequest: (URLRequest) async -> Result<Response, Error>
    
    //MARK: - init(_:)
    init(
        performRequest: @escaping (URLRequest) async -> Result<Response, Error>
    ) {
        self.performRequest = performRequest
    }
    
    //MARK: - Product
    
    /// Асинхронно возвращает список продуктов.
    /// - Parameters:
    ///   - limit: Максимальное количество продуктов, возвращаемых при вызове `API`
    ///   - offset: Отступ используемый для постраничной загрузки данных
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо массив продуктов, либо ошибку, возникшую в процессе запроса.
    public func productList(
        limit: Int = 20,
        offset: Int = 0,
        completion: @escaping (Result<[Product], StoreError>) -> Void
    ) {
        request(
            for: .productList(offset: offset, limit: limit),
            configure: { $0.method(.GET) },
            completion: completion
        )
    }
    
    /// Асинхронно возвращает продукт по указаному `id`
    /// - Parameters:
    ///   - id: Уникальный идентификатор продукта
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо искомый продукт, либо ошибку, возникшую в процессе запроса.
    public func product(
        withId id: Int,
        completion: @escaping (Result<Product, StoreError>) -> Void
    ) {
        request(
            for: .product(withId: id),
            configure: { $0.method(.GET) },
            completion: completion
        )
    }
    
    /// Запрос на создание нового продукта.
    /// - Parameters:
    ///   - product: экземпляр продукта, который вы хотите создать
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо созданный продукт, либо ошибку, возникшую в процессе запроса.
    public func create(
        product: NewProduct,
        completion: @escaping (Result<Product, StoreError>) -> Void
    ) {
        guard let data = try? encoder.encode(product) else {
            assertionFailure()
            return
        }
        request(
            for: .products,
            configure: { request in
                request
                    .method(.POST)
                    .addPayload(data)
            },
            completion: completion
        )
    }
    
    /// Запрос на обновление существующего продукта
    /// - Parameters:
    ///   - id: Уникальный идентификатор продукта
    ///   - product: Обновленная модель продукта
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо обновленный продукт, либо ошибку, возникшую в процессе запроса.
    public func updateProduct(
        withId id: Int,
        new product: NewProduct,
        completion: @escaping (Result<Product, StoreError>) -> Void
    ) {
        guard let data = try? encoder.encode(product) else {
            assertionFailure()
            return
        }
        request(
            for: .product(withId: id),
            configure: { request in
                request
                    .method(.PUT)
                    .addPayload(data)
            },
            completion: completion
        )
    }
    
    /// Запрос на удаление продукта
    /// - Parameters:
    ///   - id: Уникальный идентификатор продукта
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо ответ на запрос удаления, либо ошибку, возникшую в процессе запроса.
    public func deleteProduct(
        withId id: Int,
        completion: @escaping (Result<Bool, StoreError>) -> Void
    ) {
        request(
            for: .product(withId: id),
            configure: { $0.method(.DELETE) },
            completion: completion
        )
    }
    
    //MARK: - Category
    
    /// Запрос возвращает список категорий
    /// - Parameters:
    ///   - limit: Максимальное кол-во категорий в ответе. Значение `0` в этом поле убирает ограничение.
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо массив категорий, либо ошибку, возникшую в процессе запроса.
    public func categoryList(
        limit: Int = 20,
        completion: @escaping (Result<[Category], StoreError>) -> Void
    ) {
        request(
            for: .categoryList(limit: limit),
            configure: { $0.method(.GET) },
            completion: completion
        )
    }
    
    /// Запрос на содание новой категории
    /// - Parameters:
    ///   - category: Экземпляр категории, которую вы хотите создать
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо новая категория, либо ошибка, возникшая в процессе запроса.
    public func create(
        category: NewCategory,
        completion: @escaping (Result<Category, StoreError>) -> Void
    ) {
        guard let data = try? encoder.encode(category) else {
            assertionFailure()
            return
        }
        request(
            for: .categories,
            configure: { request in
                request
                    .method(.POST)
                    .addPayload(data)
            },
            completion: completion
        )
    }
    
    /// Запрос возвращает категорию с указанным `id`
    /// - Parameters:
    ///   - id: Уникальный идентификатор категории
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо искомая категория, либо ошибка, возникшая в процессе запроса.
    public func category(
        withId id: Int,
        completion: @escaping (Result<Category, StoreError>) -> Void
    ) {
        request(
            for: .category(withId: id),
            configure: { $0.method(.GET) },
            completion: completion
        )
    }
    
    /// Запрос на обновление категории с указанным идентификатором
    /// - Parameters:
    ///   - id: Уникальный иднтификатор категории
    ///   - category: модель, содержащая изменения
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо обновленная категория, либо ошибка, возникшая в процессе запроса.
    public func updateCategory(
        withId id: Int,
        new category: NewCategory,
        completion: @escaping (Result<Category, StoreError>) -> Void
    ) {
        guard let data = try? encoder.encode(category) else {
            assertionFailure()
            return
        }
        request(
            for: .category(withId: id),
            configure: { request in
                request
                    .method(.PUT)
                    .addPayload(data)
            },
            completion: completion
        )
    }
    
    /// Запрос на удаление категории с указанным идентификатором
    /// - Parameters:
    ///   - id: Уникальный идентификатор категории
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо ответ на запрос удаления, либо ошибку, возникшую в процессе запроса.
    public func deleteCategory(
        withId id: Int,
        completion: @escaping (Result<Bool, StoreError>) -> Void
    ) {
        request(
            for: .category(withId: id),
            configure: { $0.method(.DELETE) },
            completion: completion
        )
    }
    
    /// Запрос на получение коллекции продуктов, для указанного идентификатора категории
    /// - Parameters:
    ///   - id: Уникальный идентификатор категории
    ///   - limit: Максимальное кол-во продуктов в ответе
    ///   - offset: Отступ для постраничной загрузки
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо массив продуктов, либо ошибку, возникшую в процессе запроса.
    public func productList(
        categoryId id: Int,
        limit: Int = 20,
        offset: Int = 0,
        completion: @escaping (Result<[Product], StoreError>) -> Void
    ) {
        request(
            for: .productsFor(categoryId: id, limit: limit, offset: offset),
            configure: { $0.method(.GET) },
            completion: completion
        )
    }
    
}

//MARK: - Private methods
private extension PlatziStore {
    typealias PlatziEndpoint = Endpoint<Platzi>
    typealias ProcessRequest = (Request) -> Request
    
    func request<T: Decodable>(
        for endpoint: PlatziEndpoint,
        configure: @escaping ProcessRequest,
        completion: @escaping (Result<T, StoreError>) -> Void
    ) {
        Task { [weak self] in
            guard let self else { return }
            let result = await endpoint
                .flatMap(Request.create)
                .flatMap(configure)
                .asyncFlatMap(performRequest)
                .flatMap(unwrapResponse)
                .decode(T.self, decoder: decoder)
                .mapError(StoreError.init)
            
            completion(result)
        }
    }
    
    func unwrapResponse(_ response: Response) -> Result<Data, Error> {
        Result {
            guard let httpResponse = response.response as? HTTPURLResponse else {
                throw StoreError.unknown
            }
            try checkStatusCode(
                httpResponse.statusCode,
                data: response.data
            )
            return response.data
        }
    }
    
    func checkStatusCode(_ statusCode: Int, data: Data) throws {
        switch StatusCode(rawValue: statusCode) {
        case .OK, .success: return
            
        case .badRequest:
            guard let detail = String(data: data, encoding: .utf8) else {
                assertionFailure()
                return
            }
            throw StoreError.badRequest(detail)
            
        case .unauthorized: throw StoreError.unauthorized
            
        case .none: throw StoreError.unknown
        }
    }
}

private extension PlatziStore {
    enum StatusCode: Int {
        case OK = 200
        case success = 201
        case badRequest = 400
        case unauthorized = 401
    }
}

public extension PlatziStore {
    //MARK: - Shared instance
    static let shared = PlatziStore(
        performRequest: NetworkManager().perform
    )
    
}