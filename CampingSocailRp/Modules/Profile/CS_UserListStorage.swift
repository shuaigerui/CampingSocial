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
        return loadIds(key(for: kind))
    }

    static func users(for kind: CS_UserListKind) -> [UserModel] {
        userIds(for: kind).compactMap { UserData.user(userId: $0) }
    }

    static func count(for kind: CS_UserListKind) -> Int {
        userIds(for: kind).count
    }

    // MARK: - Write

    static func acceptFriendRequest(userId: String) {
        var requests = userIds(for: .friendRequest)
        requests.removeAll { $0 == userId }
        saveIds(requests, key: Key.friendRequests)

        var friends = userIds(for: .friends)
        if !friends.contains(userId) {
            friends.append(userId)
            saveIds(friends, key: Key.friends)
        }
    }

    static func follow(userId: String) {
        var following = userIds(for: .following)
        guard !following.contains(userId) else { return }
        following.append(userId)
        saveIds(following, key: Key.following)

        var followers = userIds(for: .followers)
        if !followers.contains(userId) {
            followers.append(userId)
            saveIds(followers, key: Key.followers)
        }
    }

    static func unfollow(userId: String) {
        var following = userIds(for: .following)
        following.removeAll { $0 == userId }
        saveIds(following, key: Key.following)
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

    // MARK: - Bootstrap

    private static func bootstrapIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Key.didBootstrap) else { return }
        UserDefaults.standard.set(true, forKey: Key.didBootstrap)

        let all = UserData.localUsers.map(\.userId)
        guard all.count >= 5 else { return }

        saveIds(Array(all.prefix(3)), key: Key.friendRequests)
        saveIds([all[0], all[1]], key: Key.following)
        saveIds([all[2]], key: Key.friends)
        saveIds([all[3], all[4]], key: Key.followers)
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
        var requests = userIds(for: .friendRequest)
        requests.removeAll { $0 == userId }
        saveIds(requests, key: Key.friendRequests)

        var following = userIds(for: .following)
        following.removeAll { $0 == userId }
        saveIds(following, key: Key.following)

        var friends = userIds(for: .friends)
        friends.removeAll { $0 == userId }
        saveIds(friends, key: Key.friends)

        var followers = userIds(for: .followers)
        followers.removeAll { $0 == userId }
        saveIds(followers, key: Key.followers)
    }
}
