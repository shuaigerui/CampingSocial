//
//  CS_DiscoverFeedItem.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

struct CS_DiscoverFeedItem {
    let postId: String
    /// Assets 图片名（无本地路径时的兜底）
    let coverImageName: String
    let content: String
    let userName: String
    var likeCount: Int
    var isLiked: Bool
    var isFollowing: Bool
    var isCollected: Bool
    /// 封面：Bundle 路径或 Assets 名
    let coverImagePath: String?
    /// 头像：Bundle 路径或 Assets 名
    let avatarPath: String?
    /// 视频本地路径
    let videoPath: String?
}
