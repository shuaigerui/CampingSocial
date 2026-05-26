//
//  UIViewController+PostDelete.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import Toast_Swift
import UIKit

extension UIViewController {

    /// 系统弹窗确认后删除当前用户发布的动态
    func confirmDeletePost(postId: String, onDeleted: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Delete Post",
            message: "Are you sure you want to delete this post?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard CS_CurrentUser.shared.deletePost(postId: postId) else {
                self?.view.makeToast("Unable to delete this post")
                return
            }
            onDeleted()
        })
        present(alert, animated: true)
    }
}
