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
            videoPath: media.videoURL
        )
    }
}
