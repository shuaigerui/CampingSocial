//
//  PostLikeState.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import Foundation

/// 动态点赞状态（按 postId 本地持久化）
struct PostLikeState: Codable, Equatable {
    var isLiked: Bool
    var likeCount: Int
}
