import Foundation
import NetworkManager
import Endpoints
import SwiftFP
import Request
import Validator

@_exported import enum Endpoints.SearchOption

/// Тип предназаначен для взаимодействия с `Platzi Fake Store API`.
///
/// Для получения данных, обратитесь к экземпляру `PlatziStore.shared`.
/// Он содержит в себе набор методов для взаимодействия.
///
/// Результат работы `PlatziStore` может выполняться на background потоке.
public final class PlatziStore {
    typealias Response = (data: Data, response: URLResponse)
    
    //MARK: - Private properties
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private let performRequest: (URLRequest) async -> Result<Response, Error>
    private let isEmailValid: (String) -> Bool
    private let loadTokenForEmail: (String) -> String?
    
    //MARK: - init(_:)
    init(
        decoder: JSONDecoder = .platziDecoder,
        encoder: JSONEncoder = JSONEncoder(),
        performRequest: @escaping (URLRequest) async -> Result<Response, Error>,
        isEmailValid: @escaping (String) -> Bool = { _ in preconditionFailure() },
        loadTokenForEmail: @escaping (String) -> String? = { _ in preconditionFailure() }
    ) {
        self.decoder = decoder
        self.encoder = encoder
        self.performRequest = performRequest
        self.isEmailValid = isEmailValid
        self.loadTokenForEmail = loadTokenForEmail
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
        request(
            for: .products,
            configure: { request in
                let data = try self.encoder.encode(product)
                return request
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
        request(
            for: .product(withId: id),
            configure: { request in
                let data = try self.encoder.encode(product)
                return request
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
        request(
            for: .categories,
            configure: { request in
                let data = try self.encoder.encode(category)
                return request
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
        request(
            for: .category(withId: id),
            configure: { request in
                let data = try self.encoder.encode(category)
                return request
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
    
    //MARK: - Users
    
    /// Запрос на получение коллекции пользователей
    /// - Parameters:
    ///   - limit: Максимальное кол-во пользователей в ответе
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо массив пользователей, либо ошибку, возникшую в процессе запроса.
    public func userList(
        limit: Int = 20,
        completion: @escaping (Result<[User], StoreError>) -> Void
    ) {
        request(
            for: .users,
            configure: { $0.method(.GET) },
            completion: completion
        )
    }
    
    /// Запрос на создание нового пользователя
    /// - Parameters:
    ///   - user: экземпляр пользователя, которого вы хотите добавить в базу
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо созданного пользователя, либо ошибку, возникшую в процессе запроса.
    public func create(
        user: NewUser,
        completion: @escaping (Result<User, StoreError>) -> Void
    ) {
        request(
            for: .users,
            configure: { [self] request in
                guard isEmailValid(user.email) else {
                    throw StoreError.invalidEmail
                }
                let data = try self.encoder.encode(user)
                return request
                    .method(.POST)
                    .addPayload(data)
            },
            completion: completion
        )
    }
    
    /// Запрос на поиск пользователя по указанному идентификатору
    /// - Parameters:
    ///   - id: Уникальный идентификатор пользователя
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо искомый пользователь, либо ошибка, возникшую в процессе запроса.
    public func user(
        withId id: Int,
        completion: @escaping (Result<User, StoreError>) -> Void
    ) {
        request(
            for: .user(withId: id),
            configure: { $0.method(.GET) },
            completion: completion
        )
    }
    
    /// Запрос на обновление данных пользователя с указанным идентификатором
    /// - Parameters:
    ///   - id: уникальный идентификатор пользователя
    ///   - new: модель, содержащая изменения
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо обновленный пользователь, либо ошибка, возникшая в процессе запроса.
    public func updateUser(
        withId id: Int,
        new: NewUser,
        completion: @escaping (Result<User, StoreError>) -> Void
    ) {
        request(
            for: .user(withId: id),
            configure: { request in
                let data = try self.encoder.encode(new)
                return request
                    .method(.PUT)
                    .addPayload(data)
            },
            completion: completion
        )
    }
    
    /// Запрос на удаление пользователя с указанным идентификатором
    /// - Parameters:
    ///   - id: уникальный идентификатор пользователя
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Либо результат запроса на удаление, либо ошибка, возникшая в процессе запроса.
    public func deleteUser(
        withId id: Int,
        completion: @escaping (Result<Bool, StoreError>) -> Void
    ) {
        request(
            for: .user(withId: id),
            configure: { $0.method(.DELETE) },
            completion: completion
        )
    }
    
    //MARK: - Login
    
    /// Запрос на авторизацию по email и паролю
    /// - Parameters:
    ///   - email: почтовый адрес пользователя
    ///   - password: пароль пользователя
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   `true` если авторизация прошла успешно, либо ошибка, возникшая в процессе запроса.
    ///
    ///   `PlatziStore` валидирует почтовый адрес перед запросом.
    public func login(
        email: String,
        password: String,
        completion: @escaping (Result<Bool, StoreError>) -> Void
    ) {
        request(
            for: .login,
            configure: loginRequest(email: email, password: password),
            completion: saveToken(completion)
        )
    }
    
    /// Запрос возвращает профиль пользователя с активной сессией, по указанному `email`
    /// - Parameters:
    ///   - email: `email` пользователя, активный профиль которого нужно запросить
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Профиль пользователя, либо ошибка, возникшая в процессе запроса.
    ///
    ///   `PlatziStore` валидирует почтовый адрес перед запросом.
    public func profile(
        withEmail email: String,
        completion: @escaping (Result<User, StoreError>) -> Void
    ) {
        request(
            for: .profile,
            configure: profileRequest(email),
            completion: completion
        )
    }
    
    //MARK: - Search
    
    /// Запрос на поиск продуктов. Поддерживает фильтры.
    /// - Parameters:
    ///   - options: параметры поиска продуктов. Для запроса нужна хотя бы 1 опция.
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Коллекция продуктов, удовлетворяющая условиям поиска, либо ошибка, возникшая в процессе запроса.
    public func searchProduct(
        _ options: SearchOption...,
        completion: @escaping (Result<[Product], StoreError>) -> Void
    ) {
        request(
            for: .searchProducts(options),
            configure: { $0.method(.GET) },
            completion: completion
        )
    }
    
    //MARK: - Files
    
    /// Запрос на загрузку файла в хранилище `API`
    /// - Parameters:
    ///   - data: Данные для сохранения
    ///   - completion: Функция асинхронно возвращает результат запроса.
    ///   Модель с информацией о сохраненном файле или ошибка, возникшая в процессе запроса.
    public func upload(
        _ data: Data,
        completion: @escaping (Result<Uploaded, StoreError>) -> Void
    ) {
        request(
            for: .upload,
            configure: { [encoder] request in
                let payload = try encoder.encode(Upload(file: data))
                return request
                    .method(.POST)
                    .uploadFile(payload)
            },
            completion: completion
        )
    }
}

//MARK: - Private methods
private extension PlatziStore {
    typealias ProcessRequest = (Request) throws -> Request
    typealias TokenResponse = (Result<Tokens, StoreError>) -> Void
    
    func profileRequest(_ email: String) -> ProcessRequest {
        { [self] request in
            guard isEmailValid(email) else {
                throw StoreError.invalidEmail
            }
            guard let token = loadTokenForEmail(email) else {
                throw StoreError.unknown
            }
            return request
                .method(.GET)
                .addBearer(token)
        }
    }
    
    func loginRequest(
        email: String,
        password: String
    ) -> ProcessRequest {
        { [self] request in
            guard isEmailValid(email) else {
                throw StoreError.invalidEmail
            }
            let data = try encoder.encode(Credentials(email: email, password: password))
            return request
                .method(.POST)
                .addPayload(data)
        }
    }
    
    func saveToken(
        _ completion: @escaping (Result<Bool, StoreError>) -> Void
    ) -> (TokenResponse) {
        { result in
            completion(
                result
                    .map { _ in true }
            )
        }
    }
    
    func request<T: Decodable>(
        for endpoint: Endpoint,
        configure: @escaping ProcessRequest,
        completion: @escaping (Result<T, StoreError>) -> Void
    ) {
        Task { [weak self] in
            guard let self else { return }
            let result = await endpoint
                .url
                .flatMap(Request.new)
                .tryMap(configure)
                .map(\.value)
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
            try checkStatusCode(httpResponse.statusCode, data: response.data)
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
        performRequest: NetworkManager().perform,
        isEmailValid: Validator.isValid
    )
    
}
