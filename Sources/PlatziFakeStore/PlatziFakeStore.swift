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
    
    private let decoder = JSONDecoder()
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
    ///   Либо запрашиваемые данные, либо ошибку, возникшую в процессе запроса.
    public func productList(
        limit: Int = 20,
        offset: Int = 0,
        completion: @escaping (Result<[Product], StoreError>) -> Void
    ) {
        request(
            for: .productList(offset: offset, limit: limit),
            completion: completion
        )
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - id: <#id description#>
    ///   - completion: <#completion description#>
    public func product(
        withId id: Int,
        completion: @escaping (Result<Product, StoreError>) -> Void
    ) {
        request(for: .product(withId: id), completion: completion)
    }
}

private extension PlatziFakeStore {
    typealias PlatziEndpoint = Endpoint<Platzi>
    
    func request<T: Decodable>(
        for endpoint: PlatziEndpoint,
        completion: @escaping (Result<T, StoreError>) -> Void
    ) {
        Task { [weak self] in
            guard let self else { return }
            let result = await endpoint
                .flatMap(Request.create)
                .method(.GET)
                .asyncFlatMap(performRequest)
                .flatMap(unwrapResponse)
                .decode(T.self, decoder: decoder)
                .mapError(StoreError.init)
            
            completion(result)
        }
    }
    
    func unwrapResponse(_ response: Response) -> Result<Data, Error> {
        
        return .success(response.data)
    }
}

private extension PlatziFakeStore {
    enum StatusCode: Int {
        case success = 200
    }
}

public extension PlatziFakeStore {
    //MARK: - Shared instance
    static let shared = PlatziFakeStore(
        performRequest: NetworkManager().perform
    )
    
}
