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

    private enum StorageKey {
        static let isLoggedIn = "cs.currentUser.isLoggedIn"
        static let loginKind = "cs.currentUser.loginKind"
        static let userJSON = "cs.currentUser.userJSON"
        static let registeredUsers = "cs.currentUser.registeredUsers"
    }

    private(set) var user: UserModel?
    private(set) var loginKind: CS_LoginKind?

    var isLoggedIn: Bool { user != nil }

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

    @discardableResult
    func loginWithApple(userName: String, signature: String, avatarURL: String? = "info_avatar") -> Bool {
        let model = Self.makeUser(
            userName: userName,
            signature: signature,
            email: "apple_\(UUID().uuidString.prefix(8))@local",
            password: "",
            avatarURL: avatarURL
        )
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

    // MARK: - Private

    @discardableResult
    private func persist(user: UserModel, kind: CS_LoginKind) -> Bool {
        guard let data = try? JSONEncoder().encode(user) else { return false }
        UserDefaults.standard.set(true, forKey: StorageKey.isLoggedIn)
        UserDefaults.standard.set(kind.rawValue, forKey: StorageKey.loginKind)
        UserDefaults.standard.set(data, forKey: StorageKey.userJSON)
        self.user = user
        loginKind = kind
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
            isBlock: false
        )
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}
