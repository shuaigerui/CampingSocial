//
//  CS_DiscoverLiveItem.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

struct CS_DiscoverLiveItem {
    /// 话术主题 key，对应 `CS_LiveRoomScripts`
    let themeKey: String
    /// 本地 Live 视频路径（用于提取首帧封面）
    let videoPath: String
    let viewerCount: Int
    let title: String
}
