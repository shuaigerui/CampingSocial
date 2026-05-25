//
//  PostModel+Feed.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

extension PostModel {

    func toProfilePostItem() -> CS_ProfilePostItem {
        if media.isVideo {
            return CS_ProfilePostItem(kind: .video, imagePost: nil, videoPost: toDiscoverFeedItem())
        }
        return CS_ProfilePostItem(kind: .image, imagePost: toHomePost(), videoPost: nil)
    }

    func toHomePost() -> CS_HomePost {
        CS_HomePost(
            userName: userName,
            time: time,
            content: content,
            likeCount: likeCount,
            commentCount: commentCount,
            isFollowing: isFollowing,
            isLiked: isLiked,
            isCollected: isCollected,
            imageColors: [],
            imagePaths: media.imageURLs,
            avatarPath: avatarURL
        )
    }

    func toDiscoverFeedItem() -> CS_DiscoverFeedItem {
        CS_DiscoverFeedItem(
            coverImageName: "discover",
            content: content,
            userName: userName,
            isFollowing: isFollowing,
            isCollected: isCollected,
            coverImagePath: media.videoCoverURL,
            avatarPath: avatarURL,
            videoPath: media.videoURL
        )
    }

    /// 详情页顶部轮播图
    func galleryImagePaths() -> [String] {
        if media.isVideo, let cover = media.videoCoverURL, !cover.isEmpty {
            return [cover]
        }
        return media.imageURLs
    }

    /// 详情页正文区展示数据
    func toDetailDisplayPost() -> CS_HomePost {
        toHomePost()
    }
}

extension PostCommentModel {

    func toPostComment() -> CS_PostComment {
        CS_PostComment(content: content, avatarImageName: avatarURL)
    }
}
