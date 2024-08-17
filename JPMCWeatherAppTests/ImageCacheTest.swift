//
//  ImageCacheTest.swift
//  JPMCWeatherAppTests
//
//  Created by Neha Dhawal on 8/16/24.
//

import XCTest
@testable import JPMCWeatherApp

final class ImageCacheTest: XCTestCase {
    var imageCache: ImageCache!

    override func setUpWithError() throws {
        super.setUp()
        imageCache = ImageCache.shared
        imageCache.clearDiskCache() // Clear the cache before each test to ensure a clean state
    }

    override func tearDownWithError() throws {
        imageCache.clearDiskCache() // Clear the cache after each test to clean up
        imageCache = nil
        super.tearDown()
    }

    func testCacheDirectoryInitialization() {
        // Ensure the cache directory is correctly initialized
        XCTAssertNotNil(imageCache.cacheDirectory)
        XCTAssertTrue(FileManager.default.fileExists(atPath: imageCache.cacheDirectory!.path))
    }

    func testSaveImageToDisk() {
        let testData = UIImage(systemName: "star")!.pngData()!
        let testFileName = "testImage.png"
        
        // Save image to disk
        imageCache.saveImageToDisk(testData, with: testFileName)
        
        // Verify that the image exists in the cache directory
        let fileURL = imageCache.cacheDirectory!.appendingPathComponent(testFileName)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func testLoadImageFromDisk() {
        let testData = UIImage(systemName: "star")!.pngData()!
        let testFileName = "testImage.png"
        
        // Save image to disk first
        imageCache.saveImageToDisk(testData, with: testFileName)
        
        // Load image from disk
        imageCache.loadImage(from: testFileName) { loadedData in
            XCTAssertNotNil(loadedData, "Image data should not be nil")
        }
    }


    func testLoadImageFromDiskNotFound() {
        let testFileName = "nonExistentImage.png"
        
        // Attempt to load an image that does not exist
        imageCache.loadImage(from: testFileName) { loadedData in
            XCTAssertNil(loadedData)
        }
    }

    func testDeleteImageFromDisk() {
        let testData = UIImage(systemName: "star")!.pngData()!
        let testFileName = "testImage.png"
        
        // Save image to disk first
        imageCache.saveImageToDisk(testData, with: testFileName)
        
        // Delete the image from disk
        imageCache.deleteImageFromDisk(with: testFileName)
        
        // Verify that the image no longer exists
        let fileURL = imageCache.cacheDirectory!.appendingPathComponent(testFileName)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func testClearDiskCache() {
        let testData = UIImage(systemName: "star")!.pngData()!
        let testFileName1 = "testImage1.png"
        let testFileName2 = "testImage2.png"
        
        // Save two images to disk
        imageCache.saveImageToDisk(testData, with: testFileName1)
        imageCache.saveImageToDisk(testData, with: testFileName2)
        
        // Clear the disk cache
        imageCache.clearDiskCache()
        
        // Verify that the cache directory is empty
        let fileURLs = try? FileManager.default.contentsOfDirectory(at: imageCache.cacheDirectory!, includingPropertiesForKeys: nil)
        XCTAssertEqual(fileURLs?.count, 0)
    }
}
