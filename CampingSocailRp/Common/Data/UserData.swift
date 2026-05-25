//
//  UserData.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import Foundation

/// 本地用户与动态数据源
enum UserData {

    // MARK: - Users

    /// 当前登录测试账号（头像走 Assets `info_avatar`，与 5 个本地用户区分）
    static let testUser = UserModel(
        userId: "90000001",
        userName: "Boluo",
        avatarURL: CS_ResourcePath.avatar("avatar_06"),
        signature: "Personal signature~",
        followingCount: 128,
        followersCount: 256,
        friendsCount: 64,
        gemsCount: 9999,
        postCount: 4,
        email: "test@gmail.com",
        password: "123456",
        isBlock: false
    )

    /// 5 个本地用户（头像 avatar_01 ~ avatar_05）
    static let localUsers: [UserModel] = [
        UserModel(
            userId: "100001",
            userName: "Mia",
            avatarURL: CS_ResourcePath.avatar("avatar_01"),
            signature: "Love camping and stargazing.",
            followingCount: 320,
            followersCount: 890,
            friendsCount: 45,
            gemsCount: 1200,
            postCount: 2,
            email: "mia@camping.com",
            password: "123456",
            isBlock: false
        ),
        UserModel(
            userId: "100002",
            userName: "Ethan",
            avatarURL: CS_ResourcePath.avatar("avatar_02"),
            signature: "Mountain trails every weekend.",
            followingCount: 210,
            followersCount: 540,
            friendsCount: 38,
            gemsCount: 860,
            postCount: 2,
            email: "ethan@camping.com",
            password: "123456",
            isBlock: false
        ),
        UserModel(
            userId: "100003",
            userName: "Luna",
            avatarURL: CS_ResourcePath.avatar("avatar_03"),
            signature: "Coffee, tent, and good vibes.",
            followingCount: 450,
            followersCount: 1200,
            friendsCount: 72,
            gemsCount: 2400,
            postCount: 2,
            email: "luna@camping.com",
            password: "123456",
            isBlock: false
        ),
        UserModel(
            userId: "100004",
            userName: "Noah",
            avatarURL: CS_ResourcePath.avatar("avatar_04"),
            signature: "RV life on the open road.",
            followingCount: 180,
            followersCount: 410,
            friendsCount: 29,
            gemsCount: 520,
            postCount: 2,
            email: "noah@camping.com",
            password: "123456",
            isBlock: false
        ),
        UserModel(
            userId: "100005",
            userName: "Zoe",
            avatarURL: CS_ResourcePath.avatar("avatar_05"),
            signature: "Sunset chaser & photo lover.",
            followingCount: 390,
            followersCount: 760,
            friendsCount: 51,
            gemsCount: 1580,
            postCount: 2,
            email: "zoe@camping.com",
            password: "123456",
            isBlock: false
        )
    ]

    /// 全部用户（5 本地 + 1 测试）
    static let allUsers: [UserModel] = localUsers + [testUser]

    // MARK: - Posts

    static let allPosts: [PostModel] = imagePosts + videoPosts

    /// 图片动态（多图）
    static let imagePosts: [PostModel] = [
        makeImagePost(
            postId: "img_001",
            user: localUsers[0],
            time: "08:12am",
            content: "Morning mist over the lake — best wake-up view.",
            images: ["post_01", "post_02", "post_03"],
            likeCount: 125,
            commentCount: 39
        ),
        makeImagePost(
            postId: "img_002",
            user: localUsers[1],
            time: "09:08am",
            content: "Hiking through the clouds and mist is like stepping into another world.",
            images: ["post_04", "post_05"],
            likeCount: 88,
            commentCount: 21
        ),
        makeImagePost(
            postId: "img_003",
            user: localUsers[2],
            time: "10:15am",
            content: "Camp setup done. Grill is on, stories incoming.",
            images: ["post_06", "post_07", "post_08"],
            likeCount: 203,
            commentCount: 56
        ),
        makeImagePost(
            postId: "img_004",
            user: testUser,
            time: "11:20am",
            content: "Our little corner of the forest tonight.",
            images: ["post_09", "post_10", "post_11"],
            likeCount: 67,
            commentCount: 14
        ),
        makeImagePost(
            postId: "img_005",
            user: localUsers[3],
            time: "02:45pm",
            content: "Found the perfect spot by the river.",
            images: ["post_12", "post_13"],
            likeCount: 142,
            commentCount: 33
        ),
        makeImagePost(
            postId: "img_006",
            user: localUsers[4],
            time: "04:30pm",
            content: "Golden hour never disappoints out here.",
            images: ["post_14", "post_15", "post_16"],
            likeCount: 310,
            commentCount: 72
        )
    ]

    /// 视频动态（单视频，封面用 post 图）
    static let videoPosts: [PostModel] = [
        makeVideoPost(
            postId: "vid_001",
            user: localUsers[0],
            time: "07:40am",
            content: "First light timelapse from our ridge camp.",
            cover: "post_01",
            video: "video_01",
            likeCount: 96,
            commentCount: 18
        ),
        makeVideoPost(
            postId: "vid_002",
            user: localUsers[1],
            time: "12:05pm",
            content: "Quick tip: how we pack light for a two-day trek.",
            cover: "post_05",
            video: "video_02",
            likeCount: 54,
            commentCount: 9
        ),
        makeVideoPost(
            postId: "vid_003",
            user: localUsers[2],
            time: "01:18pm",
            content: "Rain on the tarp — cozy ASMR vibes.",
            cover: "post_08",
            video: "video_03",
            likeCount: 178,
            commentCount: 41
        ),
        makeVideoPost(
            postId: "vid_004",
            user: testUser,
            time: "03:22pm",
            content: "Checking the trail before sunset hike.",
            cover: "post_10",
            video: "video_04",
            likeCount: 41,
            commentCount: 7
        ),
        makeVideoPost(
            postId: "vid_005",
            user: localUsers[3],
            time: "05:50pm",
            content: "RV parking with a million-dollar view.",
            cover: "post_12",
            video: "video_05",
            likeCount: 112,
            commentCount: 25
        ),
        makeVideoPost(
            postId: "vid_006",
            user: localUsers[4],
            time: "07:10pm",
            content: "Campfire jam session last night.",
            cover: "post_14",
            video: "video_06",
            likeCount: 265,
            commentCount: 58
        )
    ]

    // MARK: - Query

    static func user(userId: String) -> UserModel? {
        allUsers.first { $0.userId == userId }
    }

    static func posts(forUserId userId: String) -> [PostModel] {
        allPosts.filter { $0.userId == userId }
    }

    static func post(postId: String) -> PostModel? {
        allPosts.first { $0.postId == postId }
    }

    /// 测试账号发布的动态
    static var testUserPosts: [PostModel] {
        posts(forUserId: testUser.userId)
    }

    // MARK: - Builders

    private static func makeImagePost(
        postId: String,
        user: UserModel,
        time: String,
        content: String,
        images: [String],
        likeCount: Int,
        commentCount: Int
    ) -> PostModel {
        PostModel(
            postId: postId,
            userId: user.userId,
            userName: user.userName,
            avatarURL: user.avatarURL,
            time: time,
            content: content,
            media: .images(images.map { CS_ResourcePath.postImage($0) }),
            likeCount: likeCount,
            commentCount: commentCount,
            comments: sampleComments(for: postId),
            isFollowing: false,
            isLiked: false,
            isCollected: false,
            isReport: false
        )
    }

    private static func makeVideoPost(
        postId: String,
        user: UserModel,
        time: String,
        content: String,
        cover: String,
        video: String,
        likeCount: Int,
        commentCount: Int
    ) -> PostModel {
        PostModel(
            postId: postId,
            userId: user.userId,
            userName: user.userName,
            avatarURL: user.avatarURL,
            time: time,
            content: content,
            media: .video(
                coverURL: CS_ResourcePath.postImage(cover),
                videoURL: CS_ResourcePath.postVideo(video)
            ),
            likeCount: likeCount,
            commentCount: commentCount,
            comments: sampleComments(for: postId),
            isFollowing: false,
            isLiked: false,
            isCollected: false,
            isReport: false
        )
    }

    private static func sampleComments(for postId: String) -> [PostCommentModel] {
        [
            PostCommentModel(
                commentId: "\(postId)_c1",
                userId: localUsers[1].userId,
                userName: localUsers[1].userName,
                avatarURL: localUsers[1].avatarURL,
                content: "You sang so beautifully. I'll learn from you.",
                time: "09:20am"
            ),
            PostCommentModel(
                commentId: "\(postId)_c2",
                userId: localUsers[2].userId,
                userName: localUsers[2].userName,
                avatarURL: localUsers[2].avatarURL,
                content: "This place looks amazing!",
                time: "09:35am"
            )
        ]
    }
}
