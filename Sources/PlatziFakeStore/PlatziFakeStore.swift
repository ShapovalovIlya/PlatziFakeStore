import Foundation
import NetworkManager
import Endpoints
import SwiftFP
import Request

/// Тип предназанчен для взаимодействия с `Platzi Fake Store API`.
///
/// Для получения данных, обратитесь к экземпляру `PlatziFakeStore.shared`.
/// Он содержит в себе набор методов для взаимодействия.
///
/// Результат работы `PlatziFakeStore` может выполняться на background потоке.
public final class PlatziFakeStore {
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
    
    //MARK: - Public methods
    
    /// Асинхронно возвращает список продуктов.
    /// - Parameters:
    ///   - limit: Максимальное количество продуктов, возвращаемых при вызове `API`
    ///   - offset: Отступ исползуемый для постраничной загрузки данных
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо таблицу продуктов, либо ошибку, возникшую в процессе запроса.
    public func productList(
        limit: Int = 20,
        offset: Int = 0,
        completion: @escaping (Result<[Product], StoreError>) -> Void
    ) {
        request(
            for: .productList(offset: offset, limit: limit), 
            configure: get(request:),
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
            configure: get(request:),
            completion: completion
        )
    }
    
    /// Запрос на создание нового продукта.
    /// - Parameters:
    ///   - product: экземпляр продукта, который вы хотите создать
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо созданный продукт, либо ошибку, возникшую в процессе запроса.
    public func create(
        product: Product,
        completion: @escaping (Result<Product, StoreError>) -> Void
    ) {
        guard let data = try? encoder.encode(product) else {
            assertionFailure()
            return
        }
        request(
            for: .products,
            configure: postRequest(payload: data),
            completion: completion
        )
    }
    
}

private extension PlatziFakeStore {
    typealias PlatziEndpoint = Endpoint<Platzi>
    typealias ProcessRequest = (Request) -> Request
    
    func get(request: Request) -> Request {
        request
            .method(.GET)
    }
    
    func postRequest(payload: Data) -> ProcessRequest {
        { request in
            request
                .method(.POST)
                .body(payload)
                .headers {
                    Header(field: "Content-Type", value: "application/json")
                }
        }
    }
    
    func request<T: Decodable>(
        for endpoint: PlatziEndpoint,
        configure: @escaping ProcessRequest,
        completion: @escaping (Result<T, StoreError>) -> Void
    ) {
        Task { [weak self] in
            guard let self else { return }
            let request = endpoint.flatMap(Request.create)
            let result = await configure(request)
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

private extension PlatziFakeStore {
    enum StatusCode: Int {
        case OK = 200
        case success = 201
        case badRequest = 400
        case unauthorized = 401
    }
}

public extension PlatziFakeStore {
    //MARK: - Shared instance
    static let shared = PlatziFakeStore(
        performRequest: NetworkManager().perform
    )
    
}
