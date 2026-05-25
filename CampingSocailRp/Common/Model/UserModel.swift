//
//  UserModel.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import Foundation

/// 个人主页用户信息（含登录与黑名单等扩展字段）
struct UserModel: Codable, Equatable {

    // MARK: - Profile（个人主页展示）

    /// 用户 ID，展示为 `ID:24367278`
    var userId: String
    /// 昵称，如 Boluo
    var userName: String
    /// 头像地址（网络 URL 或本地资源名）
    var avatarURL: String?
    /// 个性签名
    var signature: String
    var followingCount: Int
    var followersCount: Int
    var friendsCount: Int
    /// 宝石数量
    var gemsCount: Int
    /// 帖子数量，用于 `My posts(67)`
    var postCount: Int

    // MARK: - Account

    var email: String
    var password: String
    /// 是否已拉黑 / 在黑名单中
    var isBlock: Bool

    // MARK: - Display

    var displayID: String {
        "ID:\(userId)"
    }

    var postsTitle: String {
        "My posts(\(postCount))"
    }
}

// MARK: - Mock

extension UserModel {

    /// 与当前个人主页 UI 一致的默认用户
    static let current = UserModel(
        userId: "24367278",
        userName: "Boluo",
        avatarURL: "info_avatar",
        signature: "Personal signature~",
        followingCount: 999,
        followersCount: 999,
        friendsCount: 999,
        gemsCount: 9999,
        postCount: 67,
        email: "",
        password: "",
        isBlock: false
    )
}
