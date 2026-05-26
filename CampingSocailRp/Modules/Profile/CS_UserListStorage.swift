//
//  CS_UserListStorage.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import Foundation

/// 关注 / 好友 / 粉丝 / 好友申请 / 黑名单（本地 UserDefaults）
enum CS_UserListStorage {

    private enum Key {
        static let didBootstrap = "cs.userList.didBootstrap"
        static let friendRequests = "cs.userList.friendRequests"
        static let following = "cs.userList.following"
        static let friends = "cs.userList.friends"
        static let followers = "cs.userList.followers"
        static let blockList = "cs.userList.blockList"
    }

    // MARK: - Read

    static func userIds(for kind: CS_UserListKind) -> [String] {
        bootstrapIfNeeded()
        switch kind {
        case .friends:
            return mutualFriendIds()
        case .friendRequest, .followers:
            return pendingFollowerIds()
        case .following, .blockList:
            return loadIds(key(for: kind))
        }
    }

    static func users(for kind: CS_UserListKind) -> [UserModel] {
        userIds(for: kind).compactMap { UserData.user(userId: $0) }
    }

    static func count(for kind: CS_UserListKind) -> Int {
        bootstrapIfNeeded()
        switch kind {
        case .friendRequest:
            return pendingFollowerIds().count
        case .followers:
            return loadIds(Key.followers).count
        default:
            return userIds(for: kind).count
        }
    }

    /// 关注我的用户 ID（全部粉丝）
    static func allFollowerIds() -> [String] {
        bootstrapIfNeeded()
        return loadIds(Key.followers)
    }

    /// 关注我、我尚未回关的用户
    static func pendingFollowerIds() -> [String] {
        let followers = allFollowerIds()
        let followingSet = Set(loadIds(Key.following))
        return followers.filter { !followingSet.contains($0) }
    }

    /// 互相关注：对方关注我且我已关注对方
    static func isMutualFriend(userId: String) -> Bool {
        allFollowerIds().contains(userId) && isFollowing(userId: userId)
    }

    /// 互相关注：我关注的 ∩ 关注我的
    private static func mutualFriendIds() -> [String] {
        let following = loadIds(Key.following)
        let followerSet = Set(loadIds(Key.followers))
        return following.filter { followerSet.contains($0) }
    }

    // MARK: - Write

    /// 接受关注：回关对方，成为互相关注好友
    static func acceptFriendRequest(userId: String) {
        follow(userId: userId)
    }

    static func follow(userId: String) {
        var following = loadIds(Key.following)
        guard !following.contains(userId) else { return }
        following.append(userId)
        saveIds(following, key: Key.following)
    }

    static func unfollow(userId: String) {
        var following = userIds(for: .following)
        following.removeAll { $0 == userId }
        saveIds(following, key: Key.following)
    }

    /// 当前登录用户是否已关注该用户
    static func isFollowing(userId: String) -> Bool {
        guard let currentId = CS_CurrentUser.shared.user?.userId else { return false }
        guard currentId != userId else { return false }
        return userIds(for: .following).contains(userId)
    }

    /// 切换关注状态，返回切换后是否已关注（已持久化到 UserDefaults）
    @discardableResult
    static func toggleFollow(userId: String) -> Bool {
        if isFollowing(userId: userId) {
            unfollow(userId: userId)
            return false
        }
        follow(userId: userId)
        return true
    }

    static func unblock(userId: String) {
        var list = userIds(for: .blockList)
        list.removeAll { $0 == userId }
        saveIds(list, key: Key.blockList)
    }

    static func isBlocked(userId: String) -> Bool {
        userIds(for: .blockList).contains(userId)
    }

    static func addToBlockList(userId: String) {
        var list = userIds(for: .blockList)
        guard !list.contains(userId) else { return }
        list.append(userId)
        saveIds(list, key: Key.blockList)
        removeFromAllListsExceptBlock(userId: userId)
    }

    /// 拉黑：加入黑名单、移出关注/好友等列表，并删除与该用户的聊天记录
    static func blockUser(userId: String) {
        addToBlockList(userId: userId)
        CS_ChatStorage.deleteConversation(peerUserId: userId)
    }

    /// 清空当前账号的关注 / 粉丝 / 黑名单等社交列表（删号用）
    static func clearAccountSocialData() {
        saveIds([], key: Key.following)
        saveIds([], key: Key.followers)
        saveIds([], key: Key.friendRequests)
        saveIds([], key: Key.friends)
        saveIds([], key: Key.blockList)
    }

    // MARK: - Bootstrap

    private static func bootstrapIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Key.didBootstrap) else { return }
        UserDefaults.standard.set(true, forKey: Key.didBootstrap)

        let all = UserData.localUsers.map(\.userId)
        guard all.count >= 5 else { return }

        saveIds([all[0], all[1]], key: Key.following)
        saveIds([all[1], all[3], all[4]], key: Key.followers)
        saveIds([], key: Key.friendRequests)
        saveIds([], key: Key.friends)
        saveIds([], key: Key.blockList)
    }

    // MARK: - Private

    private static func key(for kind: CS_UserListKind) -> String {
        switch kind {
        case .friendRequest: return Key.friendRequests
        case .following: return Key.following
        case .friends: return Key.friends
        case .followers: return Key.followers
        case .blockList: return Key.blockList
        }
    }

    private static func loadIds(_ key: String) -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    private static func saveIds(_ ids: [String], key: String) {
        UserDefaults.standard.set(ids, forKey: key)
    }

    private static func removeFromAllListsExceptBlock(userId: String) {
        var following = loadIds(Key.following)
        following.removeAll { $0 == userId }
        saveIds(following, key: Key.following)

        var followers = loadIds(Key.followers)
        followers.removeAll { $0 == userId }
        saveIds(followers, key: Key.followers)
    }
}
