//
//  CS_ProfilePostItem.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

enum CS_ProfilePostKind {
    case image
    case video
}

struct CS_ProfilePostItem {
    let kind: CS_ProfilePostKind
    var imagePost: CS_HomePost?
    var videoPost: CS_DiscoverFeedItem?
}
