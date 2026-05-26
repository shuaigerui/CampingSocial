//
//  CS_ChatStorage.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import Foundation

/// 私聊消息与会话列表本地持久化
enum CS_ChatStorage {

    private static let summariesKey = "cs.chat.conversationSummaries"
    private static let messagesKeyPrefix = "cs.chat.messages."
    private static let legacyBootstrapKey = "cs.chat.didBootstrap"
    private static let clearedLegacyBootstrapKey = "cs.chat.clearedLegacyBootstrap"

    // MARK: - Conversations

    static func conversationList() -> [CS_ChatConversation] {
        clearLegacyBootstrapDataIfNeeded()
        return loadSummaries()
            .sorted { $0.lastMessageAt > $1.lastMessageAt }
            .map { summary in
                CS_ChatConversation(
                    userId: summary.peerUserId,
                    userName: summary.peerUserName,
                    avatarURL: summary.peerAvatarURL,
                    preview: summary.lastMessage,
                    timeText: formatListTime(summary.lastMessageAt),
                    unreadCount: summary.unreadCount
                )
            }
    }

    static func deleteConversation(peerUserId: String) {
        var summaries = loadSummaries().filter { $0.peerUserId != peerUserId }
        saveSummaries(summaries)
        UserDefaults.standard.removeObject(forKey: messagesKey(peerUserId))
    }

    /// 删除全部私聊会话与消息（删号用）
    static func deleteAllConversations() {
        loadSummaries().forEach {
            UserDefaults.standard.removeObject(forKey: messagesKey($0.peerUserId))
        }
        UserDefaults.standard.removeObject(forKey: summariesKey)
    }

    // MARK: - Messages

    static func messages(peerUserId: String) -> [CS_ChatRoomMessage] {
        guard let data = UserDefaults.standard.data(forKey: messagesKey(peerUserId)),
              let list = try? JSONDecoder().decode([CS_ChatRoomMessage].self, from: data) else {
            return []
        }
        return list.sorted { $0.createdAt < $1.createdAt }
    }

    @discardableResult
    static func appendMessage(
        peerUserId: String,
        peerUserName: String,
        peerAvatarURL: String?,
        message: CS_ChatRoomMessage,
        increaseUnread: Bool = false
    ) -> CS_ChatRoomMessage {
        var list = messages(peerUserId: peerUserId)
        list.append(message)
        saveMessages(list, peerUserId: peerUserId)
        updateSummary(
            peerUserId: peerUserId,
            peerUserName: peerUserName,
            peerAvatarURL: peerAvatarURL,
            lastMessage: message.text,
            lastMessageAt: message.createdAt,
            increaseUnread: increaseUnread
        )
        return message
    }

    static func markConversationRead(peerUserId: String) {
        var summaries = loadSummaries()
        guard let index = summaries.firstIndex(where: { $0.peerUserId == peerUserId }) else { return }
        summaries[index].unreadCount = 0
        saveSummaries(summaries)
    }

    static func ensurePeerGreetingIfEmpty(peer: UserModel) {
        let existing = messages(peerUserId: peer.userId)
        guard existing.isEmpty else { return }
        let greeting = CS_ChatRoomMessage(
            sender: .peer,
            text: "Hello, I'm \(peer.userName), You can pour out your heart to me freely."
        )
        appendMessage(
            peerUserId: peer.userId,
            peerUserName: peer.userName,
            peerAvatarURL: peer.avatarURL,
            message: greeting,
            increaseUnread: true
        )
    }

    /// 清除旧版本为所有本地用户自动生成的假会话（仅执行一次）
    private static func clearLegacyBootstrapDataIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: clearedLegacyBootstrapKey) else { return }
        UserDefaults.standard.set(true, forKey: clearedLegacyBootstrapKey)

        guard UserDefaults.standard.bool(forKey: legacyBootstrapKey) else { return }
        UserDefaults.standard.removeObject(forKey: legacyBootstrapKey)

        let summaries = loadSummaries()
        summaries.forEach {
            UserDefaults.standard.removeObject(forKey: messagesKey($0.peerUserId))
        }
        UserDefaults.standard.removeObject(forKey: summariesKey)
    }

    // MARK: - Private

    private static func messagesKey(_ peerUserId: String) -> String {
        messagesKeyPrefix + peerUserId
    }

    private static func loadSummaries() -> [CS_ChatConversationSummary] {
        guard let data = UserDefaults.standard.data(forKey: summariesKey),
              let list = try? JSONDecoder().decode([CS_ChatConversationSummary].self, from: data) else {
            return []
        }
        return list
    }

    private static func saveSummaries(_ summaries: [CS_ChatConversationSummary]) {
        guard let data = try? JSONEncoder().encode(summaries) else { return }
        UserDefaults.standard.set(data, forKey: summariesKey)
    }

    private static func saveMessages(_ messages: [CS_ChatRoomMessage], peerUserId: String) {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        UserDefaults.standard.set(data, forKey: messagesKey(peerUserId))
    }

    private static func updateSummary(
        peerUserId: String,
        peerUserName: String,
        peerAvatarURL: String?,
        lastMessage: String,
        lastMessageAt: TimeInterval,
        increaseUnread: Bool
    ) {
        var summaries = loadSummaries()
        if let index = summaries.firstIndex(where: { $0.peerUserId == peerUserId }) {
            summaries[index].peerUserName = peerUserName
            summaries[index].peerAvatarURL = peerAvatarURL
            summaries[index].lastMessage = lastMessage
            summaries[index].lastMessageAt = lastMessageAt
            if increaseUnread {
                summaries[index].unreadCount += 1
            }
        } else {
            summaries.append(
                CS_ChatConversationSummary(
                    peerUserId: peerUserId,
                    peerUserName: peerUserName,
                    peerAvatarURL: peerAvatarURL,
                    lastMessage: lastMessage,
                    lastMessageAt: lastMessageAt,
                    unreadCount: increaseUnread ? 1 : 0
                )
            )
        }
        saveSummaries(summaries)
    }

    static func formatListTime(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let seconds = Date().timeIntervalSince(date)
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(Int(seconds / 60)) mins ago" }
        if seconds < 86400 { return "\(Int(seconds / 3600)) hour\(seconds >= 7200 ? "s" : "") ago" }
        if seconds < 172800 { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
