//
//  CS_ResourcePath.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

/// 用户头像（存 Documents/Avatars，持久化仅存相对路径）
enum CS_AvatarStorage {

    static let folderName = "Avatars"

    static var directoryURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func fileName(userId: String) -> String {
        "avatar_\(userId).jpg"
    }

    static func relativePath(userId: String) -> String {
        "\(folderName)/\(fileName(userId: userId))"
    }

    /// 解析 `Avatars/...`、历史绝对路径或 Documents 根目录下的 `avatar_*.jpg`
    static func resolvePath(_ stored: String) -> String? {
        let trimmed = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var candidates: [String] = []
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        if trimmed.hasPrefix("file://"), let url = URL(string: trimmed) {
            candidates.append(url.path)
        } else if trimmed.hasPrefix("\(folderName)/") {
            candidates.append(documents.appendingPathComponent(trimmed).path)
        } else if trimmed.hasPrefix("/") {
            candidates.append(trimmed)
        } else if trimmed.hasPrefix("avatar_") {
            candidates.append(directoryURL.appendingPathComponent(trimmed).path)
            candidates.append(documents.appendingPathComponent(trimmed).path)
        }

        let fileName = (trimmed as NSString).lastPathComponent
        if fileName.hasPrefix("avatar_") {
            candidates.append(directoryURL.appendingPathComponent(fileName).path)
            candidates.append(documents.appendingPathComponent(fileName).path)
        }

        for path in candidates where FileManager.default.fileExists(atPath: path) {
            return path
        }
        return nil
    }
}

/// 用户发布的图片/视频（存 Documents，持久化仅存相对路径）
enum CS_PostMediaStorage {

    static let folderName = "UserPosts"

    static var directoryURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func relativePath(fileName: String) -> String {
        "\(folderName)/\(fileName)"
    }

    static func fileURL(fileName: String) -> URL {
        directoryURL.appendingPathComponent(fileName)
    }

    /// 将持久化路径规范为 `UserPosts/文件名`（避免绝对路径在重启后失效）
    static func normalizeStoredPath(_ stored: String) -> String {
        let trimmed = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return stored }
        if trimmed.hasPrefix("file://"), let url = URL(string: trimmed) {
            return relativePath(fileName: url.lastPathComponent)
        }
        if !trimmed.hasPrefix("/") {
            return trimmed.hasPrefix("\(folderName)/")
                ? trimmed
                : relativePath(fileName: (trimmed as NSString).lastPathComponent)
        }
        return relativePath(fileName: (trimmed as NSString).lastPathComponent)
    }

    /// 解析相对或历史绝对路径为当前沙盒内可读绝对路径
    static func resolvePath(_ stored: String) -> String? {
        let trimmed = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var candidates: [String] = []

        if trimmed.hasPrefix("file://"), let url = URL(string: trimmed) {
            candidates.append(url.path)
        } else if trimmed.hasPrefix("/") {
            candidates.append(trimmed)
            candidates.append(fileURL(fileName: (trimmed as NSString).lastPathComponent).path)
        } else if trimmed.hasPrefix("\(folderName)/") {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            candidates.append(documents.appendingPathComponent(trimmed).path)
        } else {
            candidates.append(fileURL(fileName: trimmed).path)
            candidates.append(fileURL(fileName: (trimmed as NSString).lastPathComponent).path)
        }

        for path in candidates where FileManager.default.fileExists(atPath: path) {
            return path
        }
        return nil
    }
}

/// `Modules/Resource` 下本地资源（构建后通常在 Bundle 根目录）
enum CS_ResourcePath {

    private static let avatarDir = "Modules/Resource/Avatar"
    private static let postDir = "Modules/Resource/Post"
    private static let videoDir = "Modules/Resource/Video"
    private static let liveVideoDir = "Modules/Resource/Video/Live"

    static func avatar(_ name: String) -> String {
        resolvePath(name: name, ext: "jpg", directory: avatarDir)
    }

    static func postImage(_ name: String) -> String {
        resolvePath(name: name, ext: "jpg", directory: postDir)
    }

    static func postVideo(_ name: String) -> String {
        resolvePath(name: name, ext: "mp4", directory: videoDir)
    }

    static func liveVideo(_ name: String) -> String {
        resolvePath(name: name, ext: "mp4", directory: liveVideoDir)
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

    /// 本地 Documents 媒体或历史绝对路径
    var localFilePath: String? {
        guard !isEmpty else { return nil }
        if let resolved = CS_AvatarStorage.resolvePath(self) {
            return resolved
        }
        if let resolved = CS_PostMediaStorage.resolvePath(self) {
            return resolved
        }
        if hasPrefix("file://"), let url = URL(string: self) {
            return url.path
        }
        if hasPrefix("/") {
            return self
        }
        return nil
    }

    /// 从本地文件、Bundle 或 Assets 加载图片
    var resourceFileImage: UIImage? {
        if let path = localFilePath,
           let image = UIImage(contentsOfFile: path) {
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
        if let path = localFilePath {
            return URL(fileURLWithPath: path)
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
