//
//  CS_ChatAccess.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import UIKit

/// 聊天 / 视频通话入口：需互相关注（好友）
enum CS_ChatAccess {

    static let friendsOnlyTitle = "Friendly Reminder"
    static let friendsOnlyMessage = "Only friends can chat with each other.\nFollow each other to become friends."

    static func canChat(with userId: String) -> Bool {
        CS_UserListStorage.isMutualFriend(userId: userId)
    }
}

extension UIViewController {

    /// 进入文字聊天前校验互关；未互关则弹出 `CS_PopView`
    func openChatRoom(peer: UserModel, animated: Bool = true) {
        guard CS_ChatAccess.canChat(with: peer.userId) else {
            showFriendsOnlyPop()
            return
        }
        navigationController?.pushViewController(CS_ChatRoomVC(peer: peer), animated: animated)
    }

    func showFriendsOnlyPop() {
        showPop(title: CS_ChatAccess.friendsOnlyTitle, des: CS_ChatAccess.friendsOnlyMessage)
    }
}
