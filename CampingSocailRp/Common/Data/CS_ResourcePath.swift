//
//  CS_ResourcePath.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

/// `Modules/Resource` 下本地资源路径
enum CS_ResourcePath {

    private static let avatarDir = "Modules/Resource/Avatar"
    private static let postDir = "Modules/Resource/Post"
    private static let videoDir = "Modules/Resource/Video"

    static func avatar(_ name: String) -> String {
        bundlePath(name: name, ext: "jpg", directory: avatarDir)
    }

    static func postImage(_ name: String) -> String {
        bundlePath(name: name, ext: "jpg", directory: postDir)
    }

    static func postVideo(_ name: String) -> String {
        bundlePath(name: name, ext: "mp4", directory: videoDir)
    }

    private static func bundlePath(name: String, ext: String, directory: String) -> String {
        let base = (name as NSString).deletingPathExtension
        if let path = Bundle.main.path(forResource: base, ofType: ext, inDirectory: directory) {
            return path
        }
        return "\(directory)/\(base).\(ext)"
    }
}

extension String {

    /// 从 Bundle 本地文件路径加载图片（用于 `CS_ResourcePath` 返回的路径）
    var resourceFileImage: UIImage? {
        if isEmpty { return nil }
        if let image = UIImage(contentsOfFile: self) {
            return image
        }
        return UIImage(named: self)
    }

    var resourceFileURL: URL? {
        guard !isEmpty else { return nil }
        if FileManager.default.fileExists(atPath: self) {
            return URL(fileURLWithPath: self)
        }
        return nil
    }
}
