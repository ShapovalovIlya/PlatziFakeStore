//
//  AsyncImageView.swift
//
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import UIKit
import SwiftFP

/// Элемент интерфейса, для загрузки, кэширования и отображения изображений из интернета. Наследник `UIImageView`.
///
/// Экземпляр можно создавать и настраивать как обычный `UIImageView`.
/// Для установки изображения, нужно вызвать функцию `setImage(from urlString: String)` и передать подходящую строку в качестве аргумента.
///
/// При использовании в коллекциях и таблицах, для корректной работы, нужно очищать содержимое объекта `AsyncImageView`.
/// Для этого в методе жизненного цикла `func prepareForReuse()` на `UITableViewCell` или `UICollectionViewCell`,
/// вызовите метод `.prepareForReuse()` у самого экземпляра `AsyncImageView`.
public final class AsyncImageView: UIImageView {
    //MARK: - Private properties
    private let imageCache = ImageCache.shared
    private let session = URLSession.shared
    private lazy var loader = UIActivityIndicatorView(style: .medium)
    private var task: Task<Void, Never>?
    
    private var failImage: UIImage? {
        UIImage(systemName: "exclamationmark.triangle")?
            .withTintColor(.systemRed)
    }
    
    //MARK: - init(_:)
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(loader)
        loader.alpha = 0
    }
        
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        task?.cancel()
        task = nil
    }
    
    //MARK: - Life cycle
    public override func layoutSubviews() {
        loader.frame = bounds
        super.layoutSubviews()
    }
    
    //MARK: - Public methods
    
    /// Запускает процесс загрузки изображения из сети.
    /// - Parameter urlString: строка, содержащая подходящий URL-адрес
    ///
    /// Во время загрузи изображения `AsyncImageView` показывает индикатор загрузки.
    /// При неудачном запросе, отобразится характерное изображение об ошибке.
    ///
    /// Если изображение по данной ссылке было загружено ранее, `AsyncImageView` загрузит его из локального кэша.
    public func setImage(from urlString: String) {
        switch Box(urlString)
            .map(prepareUrl)
            .map(URL.init(string:))
            .value {
        case .none: image = failImage
            
        case .some(let url):
            showLoader()
            startLoadingTask(url)
        }
    }
    
    /// Очищает содержимое `AsyncImageView` и прекращает загрузку текущего изображения.
    /// При работе с коллекциями и таблицами, необходимо вовремя очищать `AsyncImageView` что бы не провоцировать непредсказуемое поведение объекта.
    public func prepareForReuse() {
        self.image = nil
        task?.cancel()
        task = nil
        
        guard subviews.contains(loader) else { return }
        loader.stopAnimating()
        loader.removeFromSuperview()
        loader.alpha = 0
    }
}

private extension AsyncImageView {
    //MARK: - Private methods
    func prepareUrl(_ urlString: String) -> String {
        urlString
            .data(using: .utf8)
            .flatMap { try? JSONSerialization.jsonObject(with: $0) }
            .flatMap { $0 as? [String] }
            .flatMap(\.first)
        ?? urlString
    }
    
    func showLoader() {
        loader.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.loader.alpha = 1
        }
    }
    
    func hideLoader() {
        UIView.animate(withDuration: 0.3) {
            self.loader.alpha = 0
        }
        loader.stopAnimating()
    }
    
    func startLoadingTask(_ url: URL) {
        task = Task(priority: .high) { [weak self] in
            guard let self else { return }
            await loadFromCacheIfAvailable(url)
                .mapRight(UIImage.init)
                .asyncMap(load(from:))
                .map(processTaskResult(url))
                .unwrap
                .asyncMap(setupLoaded(image:))
        }
    }
    
    func setupLoaded(image: UIImage) async {
        await MainActor.run {
            self.image = image
            hideLoader()
        }
    }
    
    func processTaskResult(_ url: URL) -> (Result<Data, Error>) -> UIImage? {
        { result in
            switch result
                .map(self.saveToCacheData(from: url))
                .map(UIImage.init) {
            case .success(let image):
                return image
                
            case .failure:
                return self.failImage
            }
        }
    }
    
    func saveToCacheData(from url: URL) -> (Data) -> Data {
        { data in
            self.imageCache.save(data, from: url)
            return data
        }
    }
    
    func loadFromCacheIfAvailable(_ url: URL) -> Either<URL, Data> {
        imageCache.data(from: url).map(Either.right) ?? Either.left(url)
    }
    
    func load(from url: URL) async -> Result<Data, Error> {
        await Result
            .success(url)
            .asyncMap(session.data)
            .map(\.0)
    }
    
}
