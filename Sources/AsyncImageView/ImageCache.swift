//
//  ImageCache.swift
//  
//
//  Created by Илья Шаповалов on 18.04.2024.
//

import Foundation

final class ImageCache {
    static let shared = ImageCache()
    
    private let cache: NSCache<NSURL, NSData> = .init()
    
    func save(_ data: Data, from url: URL) {
        cache.setObject(data as NSData, forKey: url as NSURL)
    }
    
    func data(from url: URL) -> Data? {
        cache.object(forKey: url as NSURL).flatMap { $0 as Data }
    }
}
