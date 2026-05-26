//
//  AuthorProfileOverride.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import Foundation

/// 用户修改资料后，用于覆盖动态列表中的作者昵称与头像
struct AuthorProfileOverride: Codable, Equatable {
    var userName: String
    var avatarURL: String?
}
