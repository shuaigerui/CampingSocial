//
//  CS_HomePost.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

struct CS_HomePost {
    let postId: String
    let userName: String
    let time: String
    let content: String
    var likeCount: Int
    var commentCount: Int
    var isFollowing: Bool
    var isLiked: Bool
    var isCollected: Bool
    /// 占位色块（无本地图时使用）
    let imageColors: [UIColor]
    /// 本地图片路径或 Assets 名
    let imagePaths: [String]
    /// 头像：Bundle 路径或 Assets 名
    let avatarPath: String?
}
