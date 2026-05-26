//
//  UserData.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import Foundation
import UIKit

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
        isBlock: false,
        isFollow: false
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
            isBlock: false,
            isFollow: false
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
            isBlock: false,
            isFollow: false
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
            isBlock: false,
            isFollow: false
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
            isBlock: false,
            isFollow: false
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
            isBlock: false,
            isFollow: false
        )
    ]

    /// 全部用户（5 本地 + 1 测试）
    static let allUsers: [UserModel] = localUsers + [testUser]

    // MARK: - Posts

    private static let userPublishedPostsKey = "cs.userData.userPublishedPosts"
    private static let postLikeStatesKey = "cs.userData.postLikeStates"
    private static let postCollectStatesKey = "cs.userData.postCollectStates"
    private static let postExtraCommentsKey = "cs.userData.postExtraComments"
    private static let authorProfileOverridesKey = "cs.userData.authorProfileOverrides"
    private static let reportedPostIdsKey = "cs.userData.reportedPostIds"

    private static var builtInPosts: [PostModel] {
        imagePosts + videoPosts
    }

    /// 内置 + 当前用户本地发布的动态（用户发布排在最前），合并点赞状态，并过滤已举报动态
    static var allPosts: [PostModel] {
        let base = loadUserPublishedPosts() + builtInPosts
        let withLikes = applyPostLikeStates(to: base)
        let withCollects = applyPostCollectStates(to: withLikes)
        let withComments = applyPostExtraComments(to: withCollects)
        let withAuthors = applyAuthorProfileOverrides(to: withComments)
        let withFollowing = applyFollowingStates(to: withAuthors)
        let blocked = Set(CS_UserListStorage.userIds(for: .blockList))
        return applyReportStates(to: withFollowing)
            .filter { !$0.isReport && !blocked.contains($0.userId) }
    }

    // MARK: - Follow（本地持久化，与 `CS_UserListStorage` 同步）

    static func isFollowing(userId: String) -> Bool {
        CS_UserListStorage.isFollowing(userId: userId)
    }

    @discardableResult
    static func toggleFollow(userId: String) -> Bool {
        CS_UserListStorage.toggleFollow(userId: userId)
    }

    /// 同步关注 / 拉黑等关系字段（相对当前登录用户）
    static func userWithRelationFlags(_ user: UserModel) -> UserModel {
        var updated = user
        updated.isFollow = isFollowing(userId: user.userId)
        updated.isBlock = CS_UserListStorage.isBlocked(userId: user.userId)
        return updated
    }

    private static func applyFollowingStates(to posts: [PostModel]) -> [PostModel] {
        let followingIds = Set(CS_UserListStorage.userIds(for: .following))
        let currentUserId = CS_CurrentUser.shared.user?.userId
        return posts.map { post in
            var updated = post
            if post.userId == currentUserId {
                updated.isFollowing = false
            } else {
                updated.isFollowing = followingIds.contains(post.userId)
            }
            return updated
        }
    }

    static let starrySkyCampingTag = "#Starry Sky Camping"

    /// 正文带「星空露营」话题标签的动态
    static var starrySkyPosts: [PostModel] {
        allPosts.filter { $0.content.contains(starrySkyCampingTag) }
    }

    // MARK: - Author Profile（编辑资料后同步动态作者展示）

    /// 保存资料后，同步该用户在各动态中的昵称与头像展示
    static func syncAuthorProfile(userId: String, userName: String, avatarURL: String) {
        var map = loadAuthorProfileOverrides()
        map[userId] = AuthorProfileOverride(userName: userName, avatarURL: avatarURL)
        saveAuthorProfileOverrides(map)

        var published = loadUserPublishedPosts()
        var didChange = false
        for index in published.indices where published[index].userId == userId {
            published[index].userName = userName
            published[index].avatarURL = avatarURL
            didChange = true
        }
        if didChange {
            saveUserPublishedPosts(published)
        }
    }

    private static func applyAuthorProfileOverrides(to posts: [PostModel]) -> [PostModel] {
        let overrides = loadAuthorProfileOverrides()
        guard !overrides.isEmpty else { return posts }
        return posts.map { post in
            guard let override = overrides[post.userId] else { return post }
            var updated = post
            updated.userName = override.userName
            updated.avatarURL = override.avatarURL
            return updated
        }
    }

    private static func loadAuthorProfileOverrides() -> [String: AuthorProfileOverride] {
        guard let data = UserDefaults.standard.data(forKey: authorProfileOverridesKey),
              let map = try? JSONDecoder().decode([String: AuthorProfileOverride].self, from: data) else {
            return [:]
        }
        return map
    }

    private static func saveAuthorProfileOverrides(_ map: [String: AuthorProfileOverride]) {
        guard let data = try? JSONEncoder().encode(map) else { return }
        UserDefaults.standard.set(data, forKey: authorProfileOverridesKey)
    }

    // MARK: - Post Report（本地持久化）

    /// 标记动态已举报，保存后 `allPosts` 将不再包含该条
    static func markPostReported(postId: String) {
        var ids = loadReportedPostIds()
        ids.insert(postId)
        saveReportedPostIds(ids)
        syncUserPublishedPostReportFlag(postId: postId, isReport: true)
    }

    static func isPostReported(postId: String) -> Bool {
        loadReportedPostIds().contains(postId)
    }

    private static func applyReportStates(to posts: [PostModel]) -> [PostModel] {
        let reported = loadReportedPostIds()
        guard !reported.isEmpty else { return posts }
        return posts.map { post in
            guard reported.contains(post.postId) else { return post }
            var updated = post
            updated.isReport = true
            return updated
        }
    }

    private static func loadReportedPostIds() -> Set<String> {
        let list = UserDefaults.standard.stringArray(forKey: reportedPostIdsKey) ?? []
        return Set(list)
    }

    private static func saveReportedPostIds(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: reportedPostIdsKey)
    }

    private static func syncUserPublishedPostReportFlag(postId: String, isReport: Bool) {
        var list = loadUserPublishedPosts()
        guard let index = list.firstIndex(where: { $0.postId == postId }) else { return }
        list[index].isReport = isReport
        saveUserPublishedPosts(list)
    }

    // MARK: - Post Like（本地持久化）

    /// 切换点赞：更新 `isLiked`、点赞数 ±1，并写入 UserDefaults
    @discardableResult
    static func toggleLike(postId: String, isLiked: Bool, likeCount: Int) -> (isLiked: Bool, likeCount: Int) {
        let newLiked = !isLiked
        let newCount = max(0, likeCount + (newLiked ? 1 : -1))
        var states = loadPostLikeStates()
        states[postId] = PostLikeState(isLiked: newLiked, likeCount: newCount)
        savePostLikeStates(states)
        return (newLiked, newCount)
    }

    private static func applyPostLikeStates(to posts: [PostModel]) -> [PostModel] {
        let states = loadPostLikeStates()
        guard !states.isEmpty else { return posts }
        return posts.map { post in
            guard let state = states[post.postId] else { return post }
            var updated = post
            updated.isLiked = state.isLiked
            updated.likeCount = state.likeCount
            return updated
        }
    }

    private static func loadPostLikeStates() -> [String: PostLikeState] {
        guard let data = UserDefaults.standard.data(forKey: postLikeStatesKey),
              let states = try? JSONDecoder().decode([String: PostLikeState].self, from: data) else {
            return [:]
        }
        return states
    }

    private static func savePostLikeStates(_ states: [String: PostLikeState]) {
        guard let data = try? JSONEncoder().encode(states) else { return }
        UserDefaults.standard.set(data, forKey: postLikeStatesKey)
    }

    // MARK: - Post Collect（本地持久化）

    /// 切换收藏状态并写入 UserDefaults
    @discardableResult
    static func toggleCollect(postId: String, isCollected: Bool) -> Bool {
        let newCollected = !isCollected
        var states = loadPostCollectStates()
        states[postId] = newCollected
        savePostCollectStates(states)
        syncUserPublishedPostCollectFlag(postId: postId, isCollected: newCollected)
        return newCollected
    }

    private static func applyPostCollectStates(to posts: [PostModel]) -> [PostModel] {
        let states = loadPostCollectStates()
        guard !states.isEmpty else { return posts }
        return posts.map { post in
            guard let collected = states[post.postId] else { return post }
            var updated = post
            updated.isCollected = collected
            return updated
        }
    }

    private static func loadPostCollectStates() -> [String: Bool] {
        guard let data = UserDefaults.standard.data(forKey: postCollectStatesKey),
              let states = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return [:]
        }
        return states
    }

    private static func savePostCollectStates(_ states: [String: Bool]) {
        guard let data = try? JSONEncoder().encode(states) else { return }
        UserDefaults.standard.set(data, forKey: postCollectStatesKey)
    }

    private static func syncUserPublishedPostCollectFlag(postId: String, isCollected: Bool) {
        var list = loadUserPublishedPosts()
        guard let index = list.firstIndex(where: { $0.postId == postId }) else { return }
        list[index].isCollected = isCollected
        saveUserPublishedPosts(list)
    }

    // MARK: - Post Comments（本地持久化）

    /// 为动态追加一条评论，写入本地并返回新评论
    @discardableResult
    static func appendComment(
        postId: String,
        content: String,
        user: UserModel?
    ) -> PostCommentModel {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let comment = PostCommentModel(
            commentId: UUID().uuidString,
            userId: user?.userId ?? "",
            userName: user?.userName ?? "Guest",
            avatarURL: user?.avatarURL ?? "info_avatar",
            content: trimmed,
            time: currentCommentTimeText()
        )
        var map = loadPostExtraComments()
        var list = map[postId] ?? []
        list.append(comment)
        map[postId] = list
        savePostExtraComments(map)
        return comment
    }

    private static func applyPostExtraComments(to posts: [PostModel]) -> [PostModel] {
        let extras = loadPostExtraComments()
        guard !extras.isEmpty else { return posts }
        return posts.map { post in
            guard let extra = extras[post.postId], !extra.isEmpty else { return post }
            var updated = post
            updated.comments.append(contentsOf: extra)
            updated.commentCount += extra.count
            return updated
        }
    }

    private static func loadPostExtraComments() -> [String: [PostCommentModel]] {
        guard let data = UserDefaults.standard.data(forKey: postExtraCommentsKey),
              let map = try? JSONDecoder().decode([String: [PostCommentModel]].self, from: data) else {
            return [:]
        }
        return map
    }

    private static func savePostExtraComments(_ map: [String: [PostCommentModel]]) {
        guard let data = try? JSONEncoder().encode(map) else { return }
        UserDefaults.standard.set(data, forKey: postExtraCommentsKey)
    }

    private static func currentCommentTimeText() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mma"
        return formatter.string(from: Date()).lowercased()
    }

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
            content: "Hiking through the clouds and mist is like stepping into another world. #Starry Sky Camping",
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
            content: "Our little corner of the forest tonight. #Starry Sky Camping",
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
            content: "Golden hour never disappoints out here. #Starry Sky Camping",
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
            content: "First light timelapse from our ridge camp. #Starry Sky Camping",
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
            content: "Campfire jam session last night. #Starry Sky Camping",
            cover: "post_14",
            video: "video_06",
            likeCount: 265,
            commentCount: 58
        )
    ]

    // MARK: - Query

    static func user(userId: String) -> UserModel? {
        guard let found = allUsers.first(where: { $0.userId == userId }) else { return nil }
        return userWithRelationFlags(found)
    }

    /// 根据帖子作者信息获取用户（本地无则按帖子字段构造）
    static func userModel(forPost post: PostModel) -> UserModel {
        if let user = user(userId: post.userId) {
            return user
        }
        return userWithRelationFlags(
            UserModel(
                userId: post.userId,
                userName: post.userName,
                avatarURL: post.avatarURL,
                signature: "Personal signature~",
                followingCount: 0,
                followersCount: 0,
                friendsCount: 0,
                gemsCount: 0,
                postCount: posts(forUserId: post.userId).count,
                email: "",
                password: "",
                isBlock: false,
                isFollow: false
            )
        )
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

    // MARK: - User Published Posts

    static func addUserPost(_ post: PostModel) {
        var list = loadUserPublishedPosts()
        list.insert(post, at: 0)
        saveUserPublishedPosts(list)
    }

    /// 是否为当前用户本地发布的动态（可删除）
    static func isUserPublishedPost(postId: String) -> Bool {
        loadUserPublishedPosts().contains { $0.postId == postId }
    }

    /// 清除指定用户在本地的一切互动与发布数据（删号用）
    static func purgeLocalActivity(forUserId userId: String) {
        loadUserPublishedPosts()
            .filter { $0.userId == userId }
            .forEach { deleteUserPost(postId: $0.postId) }

        savePostLikeStates([:])
        savePostCollectStates([:])

        var extras = loadPostExtraComments()
        for (postId, comments) in extras {
            let filtered = comments.filter { $0.userId != userId }
            if filtered.isEmpty {
                extras.removeValue(forKey: postId)
            } else {
                extras[postId] = filtered
            }
        }
        savePostExtraComments(extras)

        var overrides = loadAuthorProfileOverrides()
        overrides.removeValue(forKey: userId)
        saveAuthorProfileOverrides(overrides)

        saveReportedPostIds([])
    }

    /// 删除用户发布的动态及关联本地数据
    @discardableResult
    static func deleteUserPost(postId: String) -> Bool {
        var list = loadUserPublishedPosts()
        guard let index = list.firstIndex(where: { $0.postId == postId }) else {
            return false
        }
        let post = list.remove(at: index)
        saveUserPublishedPosts(list)
        removePostMediaFiles(for: post)
        cleanupPostLocalState(postId: postId)
        return true
    }

    private static func cleanupPostLocalState(postId: String) {
        var likes = loadPostLikeStates()
        likes.removeValue(forKey: postId)
        savePostLikeStates(likes)

        var collects = loadPostCollectStates()
        collects.removeValue(forKey: postId)
        savePostCollectStates(collects)

        var extras = loadPostExtraComments()
        extras.removeValue(forKey: postId)
        savePostExtraComments(extras)

        var reported = loadReportedPostIds()
        if reported.remove(postId) != nil {
            saveReportedPostIds(reported)
        }
    }

    private static func removePostMediaFiles(for post: PostModel) {
        let fm = FileManager.default
        let dir = CS_PostMediaStorage.directoryURL
        if post.media.isImages {
            for path in post.media.imageURLs {
                if let absolute = CS_PostMediaStorage.resolvePath(path) {
                    try? fm.removeItem(atPath: absolute)
                }
            }
            (try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil))?
                .filter { $0.lastPathComponent.hasPrefix("\(post.postId)_") }
                .forEach { try? fm.removeItem(at: $0) }
        }
        if let cover = post.media.videoCoverURL,
           let absolute = CS_PostMediaStorage.resolvePath(cover) {
            try? fm.removeItem(atPath: absolute)
        }
        if let video = post.media.videoURL,
           let absolute = CS_PostMediaStorage.resolvePath(video) {
            try? fm.removeItem(atPath: absolute)
        }
    }

    static func loadUserPublishedPosts() -> [PostModel] {
        guard let data = UserDefaults.standard.data(forKey: userPublishedPostsKey),
              let posts = try? JSONDecoder().decode([PostModel].self, from: data) else {
            return []
        }
        let migrated = migratePublishedPostMediaPaths(posts)
        if migrated != posts {
            saveUserPublishedPosts(migrated)
        }
        return migrated
    }

    private static func migratePublishedPostMediaPaths(_ posts: [PostModel]) -> [PostModel] {
        posts.map { post in
            var updated = post
            if updated.media.isImages {
                updated.media.imageURLs = updated.media.imageURLs.map {
                    CS_PostMediaStorage.normalizeStoredPath($0)
                }
            }
            if let cover = updated.media.videoCoverURL {
                updated.media.videoCoverURL = CS_PostMediaStorage.normalizeStoredPath(cover)
            }
            if let video = updated.media.videoURL {
                updated.media.videoURL = CS_PostMediaStorage.normalizeStoredPath(video)
            }
            return updated
        }
    }

    private static func saveUserPublishedPosts(_ posts: [PostModel]) {
        guard let data = try? JSONEncoder().encode(posts) else { return }
        UserDefaults.standard.set(data, forKey: userPublishedPostsKey)
    }

    static func savePostImages(_ images: [UIImage], postId: String) -> [String] {
        images.enumerated().compactMap { index, image in
            guard let data = image.jpegData(compressionQuality: 0.85) ?? image.pngData() else {
                return nil
            }
            let fileName = "\(postId)_\(index).jpg"
            let url = CS_PostMediaStorage.fileURL(fileName: fileName)
            do {
                try data.write(to: url, options: .atomic)
                guard FileManager.default.fileExists(atPath: url.path) else { return nil }
                return CS_PostMediaStorage.relativePath(fileName: fileName)
            } catch {
                return nil
            }
        }
    }

    static func savePostVideo(
        thumbnail: UIImage,
        videoURL: URL,
        postId: String
    ) -> (coverPath: String, videoPath: String)? {
        let coverFileName = "\(postId)_cover.jpg"
        let videoFileName = "\(postId).mp4"
        let coverURL = CS_PostMediaStorage.fileURL(fileName: coverFileName)
        let destVideoURL = CS_PostMediaStorage.fileURL(fileName: videoFileName)
        guard let coverData = thumbnail.jpegData(compressionQuality: 0.85) ?? thumbnail.pngData() else {
            return nil
        }
        do {
            try coverData.write(to: coverURL, options: .atomic)
            if FileManager.default.fileExists(atPath: destVideoURL.path) {
                try FileManager.default.removeItem(at: destVideoURL)
            }
            try copyVideoFile(from: videoURL, to: destVideoURL)
            guard FileManager.default.fileExists(atPath: destVideoURL.path) else { return nil }
            return (
                CS_PostMediaStorage.relativePath(fileName: coverFileName),
                CS_PostMediaStorage.relativePath(fileName: videoFileName)
            )
        } catch {
            return nil
        }
    }

    private static func copyVideoFile(from source: URL, to destination: URL) throws {
        let accessed = source.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                source.stopAccessingSecurityScopedResource()
            }
        }
        try FileManager.default.copyItem(at: source, to: destination)
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
