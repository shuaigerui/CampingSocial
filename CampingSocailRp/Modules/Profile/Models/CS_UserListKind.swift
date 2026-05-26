//
//  CS_UserListKind.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import UIKit

enum CS_UserListKind {
    case friendRequest
    case following
    case friends
    case followers
    case blockList

    var title: String {
        switch self {
        case .friendRequest: return "Friend request"
        case .following: return "Following"
        case .friends: return "Friends"
        case .followers: return "Followers"
        case .blockList: return "Blacklist"
        }
    }

    /// 右侧操作按钮样式（随列表类型变化）
    var actionStyle: CS_UserListActionStyle {
        switch self {
        case .friendRequest:
            return .image("user_accept")
        case .following:
            return .image("home_following")
        case .friends:
            return .image("user_chat")
        case .followers:
            return .image("home_follow")
        case .blockList:
            return .image("user_remove")
        }
    }
}

enum CS_UserListActionStyle {
    case image(String)
    case text(title: String, backgroundColor: UIColor)
}
