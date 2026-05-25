//
//  UIViewController+Person.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

extension UIViewController {

    func pushPerson(userId: String, isFollowing: Bool = false) {
        guard let user = UserData.user(userId: userId) else { return }
        navigationController?.pushViewController(
            CS_PersonVC(user: user, isFollowing: isFollowing),
            animated: true
        )
    }

    func pushPerson(post: PostModel) {
        let user = UserData.userModel(forPost: post)
        navigationController?.pushViewController(
            CS_PersonVC(user: user, isFollowing: post.isFollowing),
            animated: true
        )
    }
}
