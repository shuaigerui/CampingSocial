//
//  CS_ProfileVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_ProfileVC: CS_BaseVC {

    private var postModels: [PostModel] = []
    private var posts: [CS_ProfilePostItem] = []

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInsetAdjustmentBehavior = .never
        tv.dataSource = self
        tv.delegate = self
        tv.estimatedRowHeight = 340
        tv.rowHeight = UITableView.automaticDimension
        tv.register(CS_HomePostCell.self, forCellReuseIdentifier: CS_HomePostCell.reuseID)
        tv.register(CS_DiscoverFeedCell.self, forCellReuseIdentifier: CS_DiscoverFeedCell.reuseID)
        return tv
    }()

    private lazy var headerView = CS_ProfileHeaderView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadData()
    }

    private func loadData() {
        guard var user = CS_CurrentUser.shared.user else { return }

        user.followingCount = CS_UserListStorage.count(for: .following)
        user.followersCount = CS_UserListStorage.count(for: .followers)
        user.friendsCount = CS_UserListStorage.count(for: .friends)

        let userPosts = UserData.posts(forUserId: user.userId)
        postModels = userPosts
        posts = userPosts.map { $0.toProfilePostItem() }

        headerView.configure(with: user, postCount: userPosts.count)
        tableView.reloadData()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        let width = UIScreen.main.bounds.width
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: 427)
        tableView.tableHeaderView = headerView

        headerView.onSettingsTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_SettingVC(), animated: true)
        }
        headerView.onEditAvatarTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_EditVC(), animated: true)
        }
        headerView.onGemCardTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_RechargeVC(), animated: true)
        }
        headerView.onFollowingTapped = { [weak self] in
            self?.pushUserList(.following)
        }
        headerView.onFollowersTapped = { [weak self] in
            self?.pushUserList(.followers)
        }
        headerView.onFriendsTapped = { [weak self] in
            self?.pushUserList(.friends)
        }
        headerView.onFriendRequestTapped = { [weak self] in
            self?.pushUserList(.friendRequest)
        }
    }

    private func pushUserList(_ kind: CS_UserListKind) {
        navigationController?.pushViewController(CS_UserListVC(kind: kind), animated: true)
    }

}

extension CS_ProfileVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = posts[indexPath.row]

        switch item.kind {
        case .image:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CS_HomePostCell.reuseID,
                for: indexPath
            ) as? CS_HomePostCell,
                  let post = item.imagePost else {
                return UITableViewCell()
            }
            cell.configure(with: post, showsDelete: true, showsFollowButton: false)
            bindImageCellActions(cell, indexPath: indexPath)
            return cell

        case .video:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CS_DiscoverFeedCell.reuseID,
                for: indexPath
            ) as? CS_DiscoverFeedCell,
                  let post = item.videoPost else {
                return UITableViewCell()
            }
            cell.configure(with: post, showsDelete: true, showsFollowButton: false)
            bindVideoCellActions(cell, indexPath: indexPath)
            return cell
        }
    }

    private func bindImageCellActions(_ cell: CS_HomePostCell, indexPath: IndexPath) {
        cell.onLikeTapped = { [weak self] in
            self?.toggleLike(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleCollect(at: indexPath)
        }
        cell.onDeleteTapped = { [weak self] in
            self?.deletePost(at: indexPath)
        }
    }

    private func toggleLike(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        var model = postModels[indexPath.row]
        let result = UserData.toggleLike(
            postId: model.postId,
            isLiked: model.isLiked,
            likeCount: model.likeCount
        )
        model.isLiked = result.isLiked
        model.likeCount = result.likeCount
        postModels[indexPath.row] = model
        posts[indexPath.row] = model.toProfilePostItem()
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    private func toggleCollect(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        var model = postModels[indexPath.row]
        model.isCollected = UserData.toggleCollect(
            postId: model.postId,
            isCollected: model.isCollected
        )
        postModels[indexPath.row] = model
        posts[indexPath.row] = model.toProfilePostItem()
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    private func bindVideoCellActions(_ cell: CS_DiscoverFeedCell, indexPath: IndexPath) {
        cell.onLikeTapped = { [weak self] in
            self?.toggleLike(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleCollect(at: indexPath)
        }
        cell.onDeleteTapped = { [weak self] in
            self?.deletePost(at: indexPath)
        }
    }

    private func deletePost(at indexPath: IndexPath) {
        posts.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
