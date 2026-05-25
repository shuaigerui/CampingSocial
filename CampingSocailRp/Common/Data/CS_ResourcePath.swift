//
//  CS_ResourcePath.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

/// `Modules/Resource` 下本地资源（构建后通常在 Bundle 根目录）
enum CS_ResourcePath {

    private static let avatarDir = "Modules/Resource/Avatar"
    private static let postDir = "Modules/Resource/Post"
    private static let videoDir = "Modules/Resource/Video"

    static func avatar(_ name: String) -> String {
        resolvePath(name: name, ext: "jpg", directory: avatarDir)
    }

    static func postImage(_ name: String) -> String {
        resolvePath(name: name, ext: "jpg", directory: postDir)
    }

    static func postVideo(_ name: String) -> String {
        resolvePath(name: name, ext: "mp4", directory: videoDir)
    }

    private static func resolvePath(name: String, ext: String, directory: String) -> String {
        let base = (name as NSString).deletingPathExtension
        let fileExt = (name as NSString).pathExtension.isEmpty ? ext : (name as NSString).pathExtension

        if let path = Bundle.main.path(forResource: base, ofType: fileExt) {
            return path
        }
        if let path = Bundle.main.path(forResource: base, ofType: fileExt, inDirectory: directory) {
            return path
        }
        return base
    }
}

extension String {

    /// 从 Bundle 加载图片：支持绝对路径、文件名、Assets 名
    var resourceFileImage: UIImage? {
        if isEmpty { return nil }

        if self.contains("/"), FileManager.default.fileExists(atPath: self),
           let image = UIImage(contentsOfFile: self) {
            return image
        }

        let fileName = (self as NSString).lastPathComponent
        let base = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension

        if let path = Bundle.main.path(forResource: base, ofType: ext.isEmpty ? nil : ext),
           let image = UIImage(contentsOfFile: path) {
            return image
        }

        if let path = Bundle.main.path(forResource: base, ofType: ext.isEmpty ? "jpg" : ext),
           let image = UIImage(contentsOfFile: path) {
            return image
        }

        return UIImage(named: self) ?? UIImage(named: base)
    }

    var resourceFileURL: URL? {
        guard !isEmpty else { return nil }
        if self.contains("/"), FileManager.default.fileExists(atPath: self) {
            return URL(fileURLWithPath: self)
        }
        let fileName = (self as NSString).lastPathComponent
        let base = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        if let path = Bundle.main.path(forResource: base, ofType: ext.isEmpty ? nil : ext) {
            return URL(fileURLWithPath: path)
        }
        if let path = Bundle.main.path(forResource: base, ofType: ext.isEmpty ? "mp4" : ext) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
}
