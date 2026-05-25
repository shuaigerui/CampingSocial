//
//  CS_AIChatMessage.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import Foundation

enum CS_AIChatSender {
    case ai
    case user
}

struct CS_AIChatMessage {
    let id: UUID
    let sender: CS_AIChatSender
    let text: String

    init(sender: CS_AIChatSender, text: String) {
        self.id = UUID()
        self.sender = sender
        self.text = text
    }
}

enum CS_AIChatReplyProvider {

    static let welcomeMessage = "Planning a camping trip? Where would you like to go?"

    private static let genericReplies: [String] = [
        "That sounds like a great adventure! Tell me more about where you'd like to go.",
        "I'd recommend checking the weather forecast before you pack your gear.",
        "Don't forget a reliable tent and a warm sleeping bag for cooler nights.",
        "Many popular campsites require reservations—it's worth booking early.",
        "A portable stove and enough drinking water are essential for any trip.",
        "Morning hikes are quieter and cooler—worth setting an early alarm.",
        "Leave no trace—please pack out everything you bring in.",
        "A headlamp is one of the most useful items campers often forget.",
        "Layer your clothing so you can adjust as temperatures change through the day.",
        "Share your experience level and I can suggest some beginner-friendly spots."
    ]

    static func randomReply() -> String {
        genericReplies.randomElement() ?? genericReplies[0]
    }
}
