//
//  CS_VideoThumbnail.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import AVFoundation
import UIKit

/// 本地视频首帧缩略图（带内存缓存）
enum CS_VideoThumbnail {

    private static let cache = NSCache<NSString, UIImage>()

    static func cachedImage(forVideoPath path: String) -> UIImage? {
        guard !path.isEmpty else { return nil }
        return cache.object(forKey: path as NSString)
    }

    static func firstFrameImage(forVideoPath path: String) -> UIImage? {
        if let cached = cachedImage(forVideoPath: path) { return cached }
        guard let image = generateImage(forVideoPath: path) else { return nil }
        cache.setObject(image, forKey: path as NSString)
        return image
    }

    static func loadFirstFrame(
        forVideoPath path: String,
        completion: @escaping (UIImage?) -> Void
    ) {
        if let cached = cachedImage(forVideoPath: path) {
            completion(cached)
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let image = generateImage(forVideoPath: path)
            if let image {
                cache.setObject(image, forKey: path as NSString)
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    private static func generateImage(forVideoPath path: String) -> UIImage? {
        guard let url = path.resourceFileURL else { return nil }
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 720, height: 1280)
        guard let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
