//
//  PostModel.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import Foundation

// MARK: - Media

/// 动态媒体类型：多图 或 单视频
enum PostMediaType: String, Codable {
    case images
    case video
}

struct PostMedia: Codable, Equatable {

    var type: PostMediaType
    /// 多图 URL / 本地资源名（`type == .images` 时有效）
    var imageURLs: [String]
    /// 视频封面（`type == .video` 时有效）
    var videoCoverURL: String?
    /// 视频地址（`type == .video` 时有效）
    var videoURL: String?

    var isVideo: Bool { type == .video }

    var isImages: Bool { type == .images }

    /// 多图创建
    static func images(_ urls: [String]) -> PostMedia {
        PostMedia(type: .images, imageURLs: urls, videoCoverURL: nil, videoURL: nil)
    }

    /// 单视频创建
    static func video(coverURL: String, videoURL: String) -> PostMedia {
        PostMedia(type: .video, imageURLs: [], videoCoverURL: coverURL, videoURL: videoURL)
    }
}

// MARK: - Comment

struct PostCommentModel: Codable, Equatable {
    var commentId: String
    var userId: String
    var userName: String
    var avatarURL: String?
    var content: String
    var time: String?
}

// MARK: - Post

/// 动态详情 / 列表通用模型
struct PostModel: Codable, Equatable {

    var postId: String

    // MARK: Author

    var userId: String
    var userName: String
    var avatarURL: String?
    /// 展示用时间，如 09:08am
    var time: String

    // MARK: Content

    var content: String
    var media: PostMedia

    // MARK: Stats

    var likeCount: Int
    var commentCount: Int
    var comments: [PostCommentModel]

    // MARK: Interaction State

    var isFollowing: Bool
    var isLiked: Bool
    var isCollected: Bool
    /// 是否已举报
    var isReport: Bool
}

// MARK: - Mock

extension PostModel {

    static let defaultComments: [PostCommentModel] = [
        PostCommentModel(
            commentId: "1",
            userId: "10001",
            userName: "Guest",
            avatarURL: "info_avatar",
            content: "You sang so beautifully. I'll learn from you.",
            time: nil
        ),
        PostCommentModel(
            commentId: "2",
            userId: "10002",
            userName: "Guest",
            avatarURL: "info_avatar",
            content: "You sang so beautifully. I'll learn from you.",
            time: nil
        ),
        PostCommentModel(
            commentId: "3",
            userId: "10003",
            userName: "Guest",
            avatarURL: "info_avatar",
            content: "You sang so beautifully. I'll learn from you.",
            time: nil
        )
    ]

    /// 多图动态（动态详情 mock）
    static let imageDetailMock = PostModel(
        postId: "post_image_001",
        userId: "24367278",
        userName: "Luoluo",
        avatarURL: "info_avatar",
        time: "09:08am",
        content: "Hiking through the clouds and mist is like stepping into another world",
        media: .images(["post_img_1", "post_img_2", "post_img_3"]),
        likeCount: 125,
        commentCount: 39,
        comments: defaultComments,
        isFollowing: false,
        isLiked: false,
        isCollected: false,
        isReport: false
    )

    /// 单视频动态（Discover 风格 mock）
    static let videoDetailMock = PostModel(
        postId: "post_video_001",
        userId: "24367279",
        userName: "Luoluo",
        avatarURL: "info_avatar",
        time: "09:08am",
        content: "Like bitternessLike bitternessLike bitternessLike bitternessLike bitterness",
        media: .video(coverURL: "discover", videoURL: ""),
        likeCount: 88,
        commentCount: 12,
        comments: defaultComments,
        isFollowing: false,
        isLiked: false,
        isCollected: false,
        isReport: false
    )
}
