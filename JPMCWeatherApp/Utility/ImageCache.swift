//
//  ImageCache.swift
//  JPMCWeatherApp
//
//  Created by Neha Dhawal on 8/16/24.
//

import UIKit

/// ImageCache class is a singleton that manages image caching by storing and retrieving images Data from the device's local storage.
/// Useful where images need to be cached for offline use or to reduce the need for repeated network requests
/// Improves performance and user experience.
/// This class can be enhanced further to store data in memory in cache for quick access when app is being used 
class ImageCache {
    static let shared = ImageCache()
    
    private let fileManager = FileManager.default
    
    lazy var cacheDirectory: URL? = {
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return directory.appendingPathComponent("ImageCache", isDirectory: true)
    }()
    
    init() {
        if let cacheDirectory = cacheDirectory {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    /// fetch image data from disk
    /// - Parameter fileName: iconCode from Weather response
    /// - Returns: returns image in Data in completion
    func loadImage(from iconCode: String, completion: @escaping (Data?) -> Void) {
        if let diskImage = loadImageFromDisk(with: iconCode) {
            completion(diskImage)
        } else {
            completion(nil)
        }
    }
    
    /// fetch image data from disk
    /// - Parameter fileName: iconName
    /// - Returns: returns image in Data form
    private func loadImageFromDisk(with fileName: String) -> Data? {
        guard let cacheDirectory = cacheDirectory else { return nil }
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        guard let imageData = try? Data(contentsOf: fileURL) else { return nil }
        return imageData
    }
    
    
    /// Add the ImageData to disk
    /// - Parameters:
    ///   - data: image from Url in Data form
    ///   - fileName: name of image iconName
    func saveImageToDisk(_ data: Data, with fileName: String) {
        guard let image = UIImage(data: data) else { return }
        guard let cacheDirectory = cacheDirectory else { return }
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        guard let imageData = image.pngData() else { return }
        try? imageData.write(to: fileURL)
    }
    
    /// Added only for Testing purpose but can be used further when the data gets heavy on the disk
    /// - Parameter fileName:iconCode  used as name of file
    func deleteImageFromDisk(with fileName: String) {
        guard let cacheDirectory = cacheDirectory else { return }
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Can be used to clean up the disk space as an emhancement
    func clearDiskCache() {
        guard let cacheDirectory = cacheDirectory else { return }
        if let fileURLs = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
            for fileURL in fileURLs {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
}
