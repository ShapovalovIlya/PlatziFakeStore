//
//  AsyncImageView.swift
//
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import UIKit
import SwiftFP

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
    public func setImage(from urlString: String) {
        switch URL(string: urlString) {
        case .none: image = failImage
            
        case .some(let url):
            showLoader()
            startLoadingTask(url)
        }
    }
    
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
        { [self] result in
            switch result
                .map(saveToCacheData(from: url))
                .map(UIImage.init) {
            case .success(let image):
                return image
                
            case .failure:
                return failImage
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
