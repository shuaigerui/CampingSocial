//
//  CS_DiscoverFeedItem.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

struct CS_DiscoverFeedItem {
    /// Assets 图片名（无本地路径时的兜底）
    let coverImageName: String
    let content: String
    let userName: String
    var isFollowing: Bool
    var isCollected: Bool
    /// 封面：Bundle 路径或 Assets 名
    let coverImagePath: String?
    /// 视频本地路径
    let videoPath: String?
}
