//
//  CS_PersonVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import Toast_Swift
import UIKit

class CS_PersonVC: CS_BaseVC {

    private let user: UserModel
    private var isFollowing: Bool
    private var postModels: [PostModel] = []
    private var posts: [CS_ProfilePostItem] = []

    private var isCurrentUser: Bool {
        guard let currentId = CS_CurrentUser.shared.user?.userId else { return false }
        return currentId == user.userId
    }

    private lazy var headerView = CS_PersonHeaderView()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInsetAdjustmentBehavior = .never
        tv.dataSource = self
        tv.estimatedRowHeight = 340
        tv.rowHeight = UITableView.automaticDimension
        tv.register(CS_HomePostCell.self, forCellReuseIdentifier: CS_HomePostCell.reuseID)
        tv.register(CS_DiscoverFeedCell.self, forCellReuseIdentifier: CS_DiscoverFeedCell.reuseID)
        return tv
    }()

    init(user: UserModel, isFollowing: Bool = false) {
        self.user = user
        self.isFollowing = isFollowing
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupTableView()
    }

    private func loadData() {
        let userPosts = UserData.posts(forUserId: user.userId)
        postModels = userPosts
        posts = userPosts.map { $0.toProfilePostItem() }
        headerView.configure(
            with: user,
            postCount: userPosts.count,
            isFollowing: isFollowing,
            isCurrentUser: isCurrentUser
        )
        tableView.reloadData()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        let width = UIScreen.main.bounds.width
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: CS_PersonHeaderView.preferredHeight)
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView

        headerView.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        headerView.onFollowTapped = { [weak self] in
            self?.toggleFollow()
        }
        headerView.onMoreTapped = { [weak self] in
            self?.confirmBlockUser()
        }
        headerView.onChatTapped = { [weak self] in
            guard let self, !self.isCurrentUser else { return }
            self.navigationController?.pushViewController(CS_ChatRoomVC(peer: self.user), animated: true)
        }
    }

    private func toggleFollow() {
        isFollowing.toggle()
        headerView.configure(
            with: user,
            postCount: posts.count,
            isFollowing: isFollowing,
            isCurrentUser: isCurrentUser
        )
    }

    private func confirmBlockUser() {
        guard CS_CurrentUser.shared.user?.userId != user.userId else { return }

        let alert = UIAlertController(
            title: "Block User",
            message: "You will no longer see posts from \(user.userName). Your chat history will be deleted and they will be added to your blacklist.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            self?.performBlockUser()
        })
        present(alert, animated: true)
    }

    private func performBlockUser() {
        CS_UserListStorage.blockUser(userId: user.userId)
        view.makeToast("Blocked \(user.userName)")
        navigationController?.popViewController(animated: true)
    }
}

extension CS_PersonVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = posts[indexPath.row]
        let showsDelete = CS_CurrentUser.shared.ownsPost(userId: postModels[indexPath.row].userId)

        switch item.kind {
        case .image:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CS_HomePostCell.reuseID,
                for: indexPath
            ) as? CS_HomePostCell,
                  let post = item.imagePost else {
                return UITableViewCell()
            }
            cell.configure(with: post, showsDelete: showsDelete, showsFollowButton: false)
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
            cell.configure(with: post, showsDelete: showsDelete, showsFollowButton: false)
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

    private func deletePost(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        let postId = postModels[indexPath.row].postId
        confirmDeletePost(postId: postId) { [weak self] in
            self?.loadData()
        }
    }
}
