//
//  CS_CurrentUser.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

enum CS_LoginKind: String, Codable {
    case test
    case apple
    case email
}

/// 当前登录用户单例（持久化，下次启动直达主页）
final class CS_CurrentUser {

    static let shared = CS_CurrentUser()

    static let testEmail = "test@gmail.com"
    static let testPassword = "123456"
    /// 发布一条动态消耗的宝石数
    static let postPublishGemCost = 30

    private enum StorageKey {
        static let isLoggedIn = "cs.currentUser.isLoggedIn"
        static let loginKind = "cs.currentUser.loginKind"
        static let userJSON = "cs.currentUser.userJSON"
        static let registeredUsers = "cs.currentUser.registeredUsers"
        static let appleUsers = "cs.currentUser.appleUsers"
    }

    private struct AppleAccountRecord: Codable {
        let appleUserId: String
        var user: UserModel
    }

    private(set) var user: UserModel?
    private(set) var loginKind: CS_LoginKind?

    var isLoggedIn: Bool { user != nil }

    /// 是否为当前登录用户发布的动态
    func ownsPost(userId: String) -> Bool {
        user?.userId == userId
    }

    private init() {}

    // MARK: - Launch

    func restore() {
        guard UserDefaults.standard.bool(forKey: StorageKey.isLoggedIn),
              let data = UserDefaults.standard.data(forKey: StorageKey.userJSON),
              let saved = try? JSONDecoder().decode(UserModel.self, from: data) else {
            clearMemory()
            return
        }
        user = saved
        if let raw = UserDefaults.standard.string(forKey: StorageKey.loginKind) {
            loginKind = CS_LoginKind(rawValue: raw)
        }
        normalizeStoredAvatarIfNeeded()
    }

    func rootViewController() -> UIViewController {
        if isLoggedIn {
            return CS_TabBarVC()
        }
        let nav = UINavigationController(rootViewController: CS_WelcomeVC())
        nav.navigationBar.isHidden = true
        return nav
    }

    func switchRoot(animated: Bool = true, on window: UIWindow? = nil) {
        let targetWindow = window ?? Self.keyWindow
        guard let targetWindow else { return }
        targetWindow.rootViewController = rootViewController()
        guard animated else { return }
        UIView.transition(
            with: targetWindow,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }

    // MARK: - Login

    @discardableResult
    func login(email: String, password: String) -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pwd = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if normalizedEmail == Self.testEmail.lowercased(), pwd == Self.testPassword {
            return persist(user: UserData.testUser, kind: .test)
        }

        if let matched = registeredUsers().first(where: {
            $0.email.lowercased() == normalizedEmail && $0.password == pwd
        }) {
            return persist(user: matched, kind: .email)
        }

        return false
    }

    /// 是否已有该 Apple 账号的本地资料（非首次登录）
    func hasAppleAccount(appleUserId: String) -> Bool {
        appleUserIdRecord(appleUserId) != nil
    }

    /// 回访 Apple 用户：直接登录
    @discardableResult
    func loginExistingAppleAccount(appleUserId: String) -> Bool {
        guard let record = appleUserIdRecord(appleUserId) else { return false }
        return persist(user: record.user, kind: .apple)
    }

    /// 首次 Apple 登录：完善资料后注册并登录
    @discardableResult
    func registerAppleAccount(
        appleUserId: String,
        userName: String,
        signature: String,
        avatarURL: String? = "info_avatar"
    ) -> Bool {
        guard appleUserIdRecord(appleUserId) == nil else { return false }
        let model = Self.makeUser(
            userName: userName,
            signature: signature,
            email: Self.appleEmail(appleUserId: appleUserId),
            password: "",
            avatarURL: avatarURL
        )
        var records = loadAppleUsers()
        records.append(AppleAccountRecord(appleUserId: appleUserId, user: model))
        saveAppleUsers(records)
        return persist(user: model, kind: .apple)
    }

    @discardableResult
    func register(
        email: String,
        password: String,
        userName: String,
        signature: String,
        avatarURL: String? = "info_avatar"
    ) -> Bool {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pwd = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedEmail.isEmpty, !pwd.isEmpty else { return false }

        var users = registeredUsers()
        if users.contains(where: { $0.email.lowercased() == normalizedEmail }) {
            return false
        }

        let model = Self.makeUser(
            userName: userName,
            signature: signature,
            email: normalizedEmail,
            password: pwd,
            avatarURL: avatarURL
        )
        users.append(model)
        saveRegisteredUsers(users)
        return persist(user: model, kind: .email)
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: StorageKey.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: StorageKey.loginKind)
        UserDefaults.standard.removeObject(forKey: StorageKey.userJSON)
        clearMemory()
    }

    /// 删除当前账号：清空本地数据、注销并返回登录前状态
    @discardableResult
    func deleteAccount() -> Bool {
        guard let current = user, let kind = loginKind else { return false }
        let userId = current.userId

        UserData.purgeLocalActivity(forUserId: userId)
        CS_UserListStorage.clearAccountSocialData()
        CS_ChatStorage.deleteAllConversations()

        let avatarPath = Self.avatarFileURL(userId: userId)
        if FileManager.default.fileExists(atPath: avatarPath.path) {
            try? FileManager.default.removeItem(at: avatarPath)
        }
        let legacyAvatarPath = Self.legacyAvatarFileURL(userId: userId)
        if FileManager.default.fileExists(atPath: legacyAvatarPath.path) {
            try? FileManager.default.removeItem(at: legacyAvatarPath)
        }

        if kind == .email {
            var users = registeredUsers()
            users.removeAll { $0.userId == userId }
            saveRegisteredUsers(users)
        }

        if kind == .apple, let appleUserId = Self.parseAppleUserId(from: current.email) {
            var records = loadAppleUsers()
            records.removeAll { $0.appleUserId == appleUserId }
            saveAppleUsers(records)
        }

        logout()
        return true
    }

    // MARK: - Profile

    /// 更新当前用户昵称、签名、头像，并持久化到本地
    @discardableResult
    func updateProfile(userName: String, signature: String, avatarURL: String) -> Bool {
        guard var current = user, let kind = loginKind else { return false }
        current.userName = userName
        current.signature = signature
        current.avatarURL = avatarURL
        syncRegisteredUserIfNeeded(current, kind: kind)
        UserData.syncAuthorProfile(
            userId: current.userId,
            userName: userName,
            avatarURL: avatarURL
        )
        return persist(user: current, kind: kind)
    }

    @discardableResult
    func addGems(_ amount: Int) -> Bool {
        guard amount > 0, var current = user, let kind = loginKind else { return false }
        current.gemsCount += amount
        syncRegisteredUserIfNeeded(current, kind: kind)
        return persist(user: current, kind: kind)
    }

    func canAffordPostPublish() -> Bool {
        (user?.gemsCount ?? 0) >= Self.postPublishGemCost
    }

    @discardableResult
    func publishPost(_ post: PostModel) -> Bool {
        guard var current = user, let kind = loginKind else { return false }
        guard current.gemsCount >= Self.postPublishGemCost else { return false }
        UserData.addUserPost(post)
        current.gemsCount -= Self.postPublishGemCost
        current.postCount = UserData.posts(forUserId: current.userId).count
        syncRegisteredUserIfNeeded(current, kind: kind)
        return persist(user: current, kind: kind)
    }

    /// 删除当前用户发布的动态（本地持久化）
    @discardableResult
    func deletePost(postId: String) -> Bool {
        guard UserData.deleteUserPost(postId: postId) else { return false }
        guard var current = user, let kind = loginKind else { return true }
        current.postCount = UserData.posts(forUserId: current.userId).count
        syncRegisteredUserIfNeeded(current, kind: kind)
        return persist(user: current, kind: kind)
    }

    func saveAvatarImage(_ image: UIImage) -> String? {
        guard let userId = user?.userId else { return nil }
        let url = Self.avatarFileURL(userId: userId)
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            let legacy = Self.legacyAvatarFileURL(userId: userId)
            if legacy.path != url.path, FileManager.default.fileExists(atPath: legacy.path) {
                try? FileManager.default.removeItem(at: legacy)
            }
            return CS_AvatarStorage.relativePath(userId: userId)
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private func syncRegisteredUserIfNeeded(_ user: UserModel, kind: CS_LoginKind) {
        switch kind {
        case .email:
            var users = registeredUsers()
            guard let index = users.firstIndex(where: { $0.userId == user.userId }) else { return }
            users[index] = user
            saveRegisteredUsers(users)
        case .apple:
            guard let appleUserId = Self.parseAppleUserId(from: user.email) else { return }
            var records = loadAppleUsers()
            guard let index = records.firstIndex(where: { $0.appleUserId == appleUserId }) else { return }
            records[index].user = user
            saveAppleUsers(records)
        case .test:
            break
        }
    }

    private static func avatarFileURL(userId: String) -> URL {
        CS_AvatarStorage.directoryURL.appendingPathComponent(CS_AvatarStorage.fileName(userId: userId))
    }

    private static func legacyAvatarFileURL(userId: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(CS_AvatarStorage.fileName(userId: userId))
    }

    /// 将历史绝对路径头像迁移为 `Avatars/avatar_*.jpg` 相对路径
    private func normalizeStoredAvatarIfNeeded() {
        guard var current = user, let kind = loginKind,
              let stored = current.avatarURL,
              !stored.isEmpty,
              stored != "info_avatar",
              !stored.hasPrefix("\(CS_AvatarStorage.folderName)/") else { return }

        guard let absolute = CS_AvatarStorage.resolvePath(stored),
              let image = UIImage(contentsOfFile: absolute),
              let relative = saveAvatarImage(image) else { return }

        current.avatarURL = relative
        syncRegisteredUserIfNeeded(current, kind: kind)
        persist(user: current, kind: kind)
    }

    @discardableResult
    private func persist(user: UserModel, kind: CS_LoginKind) -> Bool {
        guard let data = try? JSONEncoder().encode(user) else { return false }
        UserDefaults.standard.set(true, forKey: StorageKey.isLoggedIn)
        UserDefaults.standard.set(kind.rawValue, forKey: StorageKey.loginKind)
        UserDefaults.standard.set(data, forKey: StorageKey.userJSON)
        self.user = user
        loginKind = kind
        normalizeStoredAvatarIfNeeded()
        return true
    }

    private func clearMemory() {
        user = nil
        loginKind = nil
    }

    private func registeredUsers() -> [UserModel] {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.registeredUsers),
              let users = try? JSONDecoder().decode([UserModel].self, from: data) else {
            return []
        }
        return users
    }

    private func saveRegisteredUsers(_ users: [UserModel]) {
        guard let data = try? JSONEncoder().encode(users) else { return }
        UserDefaults.standard.set(data, forKey: StorageKey.registeredUsers)
    }

    private func appleUserIdRecord(_ appleUserId: String) -> AppleAccountRecord? {
        loadAppleUsers().first { $0.appleUserId == appleUserId }
    }

    private func loadAppleUsers() -> [AppleAccountRecord] {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.appleUsers),
              let records = try? JSONDecoder().decode([AppleAccountRecord].self, from: data) else {
            return []
        }
        return records
    }

    private func saveAppleUsers(_ records: [AppleAccountRecord]) {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: StorageKey.appleUsers)
    }

    private static func appleEmail(appleUserId: String) -> String {
        "apple_\(appleUserId)@local"
    }

    private static func parseAppleUserId(from email: String) -> String? {
        let prefix = "apple_"
        let suffix = "@local"
        guard email.hasPrefix(prefix), email.hasSuffix(suffix) else { return nil }
        let start = email.index(email.startIndex, offsetBy: prefix.count)
        let end = email.index(email.endIndex, offsetBy: -suffix.count)
        guard start < end else { return nil }
        return String(email[start..<end])
    }

    private static func makeUser(
        userName: String,
        signature: String,
        email: String,
        password: String,
        avatarURL: String?
    ) -> UserModel {
        UserModel(
            userId: String(Int.random(in: 10_000_000...99_999_999)),
            userName: userName,
            avatarURL: avatarURL,
            signature: signature,
            followingCount: 0,
            followersCount: 0,
            friendsCount: 0,
            gemsCount: 0,
            postCount: 0,
            email: email,
            password: password,
            isBlock: false,
            isFollow: false
        )
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}
