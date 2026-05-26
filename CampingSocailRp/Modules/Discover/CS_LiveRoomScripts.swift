//
//  CS_LiveRoomScripts.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import Foundation

/// 各直播间主题话术（每主题 10 条）与随机昵称
enum CS_LiveRoomScripts {

    static let randomNames: [String] = [
        "Dolly Walker", "Raya Chen", "Leo Martin", "Mia Brooks", "Ethan Cole",
        "Nora Blake", "Owen Hayes", "Luna Price", "Caleb Reed", "Zoe Turner",
        "Finn Carter", "Ivy Lawson", "Jasper Lane", "Ruby West", "Miles Grant"
    ]

    private static let scripts: [String: [String]] = [
        "live_01": [
            "The view from this ridge is unreal!",
            "Love how peaceful the forest feels right now.",
            "Anyone else camping near pine trails this week?",
            "That tent setup looks so cozy.",
            "Morning mist makes everything magical.",
            "Great tips for first-time mountain campers!",
            "The birdsong here is amazing.",
            "Can't stop watching this stream.",
            "Adding this spot to my bucket list.",
            "Stay safe on those rocky paths, everyone."
        ],
        "live_02": [
            "Sunset by the river is pure gold.",
            "This campsite layout is goals.",
            "The campfire glow is so warm.",
            "Perfect evening for outdoor cooking.",
            "Water looks so calm and clear.",
            "Who else loves riverside camping?",
            "Those tents have the best view.",
            "Relaxing vibes from this live.",
            "Nature therapy at its finest.",
            "Don't forget bug spray by the water!"
        ],
        "live_03": [
            "That orange tent is iconic!",
            "Friends + camping = best weekend ever.",
            "So many smiles in one frame.",
            "Group trips are the best trips.",
            "Love the energy in this room!",
            "Tent talk is my favorite talk.",
            "Share your funniest camp story!",
            "Cozy crew goals right here.",
            "This live made my day.",
            "Tag your camping besties!"
        ],
        "live_04": [
            "Morning creek sounds are healing.",
            "Fresh air hits different out here.",
            "Wilderness wake-up call!",
            "Love this quiet forest moment.",
            "Coffee tastes better by the stream.",
            "Anyone hiking nearby today?",
            "The greenery is so vibrant.",
            "Perfect start to the day.",
            "Nature sounds ASMR live!",
            "Keep our trails clean, campers."
        ]
    ]

    static func messages(for themeKey: String) -> [String] {
        scripts[themeKey] ?? scripts["live_01"]!
    }

    static func randomName() -> String {
        randomNames.randomElement() ?? "Guest"
    }

    static func randomMessage(for themeKey: String) -> String {
        messages(for: themeKey).randomElement() ?? "Hello from the trail!"
    }
}
