//
//  CS_ChatRoomMessage.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import Foundation

enum CS_ChatMessageSender: String, Codable {
    case me
    case peer
}

struct CS_ChatRoomMessage: Codable, Equatable {
    let id: String
    let sender: CS_ChatMessageSender
    let text: String
    let createdAt: TimeInterval

    init(sender: CS_ChatMessageSender, text: String, createdAt: Date = Date()) {
        self.id = UUID().uuidString
        self.sender = sender
        self.text = text
        self.createdAt = createdAt.timeIntervalSince1970
    }
}

struct CS_ChatConversationSummary: Codable, Equatable {
    var peerUserId: String
    var peerUserName: String
    var peerAvatarURL: String?
    var lastMessage: String
    var lastMessageAt: TimeInterval
    var unreadCount: Int
}
