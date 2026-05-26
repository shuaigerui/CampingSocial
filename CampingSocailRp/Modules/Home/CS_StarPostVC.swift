//
//  CS_StarPostVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import UIKit

class CS_StarPostVC: CS_BaseVC {

    private enum Layout {
        static let postButtonHeight: CGFloat = 56
        static let postButtonBottomInset: CGFloat = 12
    }

    private var postModels: [PostModel] = []
    private var posts: [CS_ProfilePostItem] = []
    private var isAddMenuVisible = false

    private lazy var addMenuView: CS_AddMenuView = {
        let v = CS_AddMenuView()
        v.isHidden = true
        v.onDismiss = { [weak self] in
            self?.hideAddMenu()
        }
        v.onPhotoTapped = { [weak self] in
            self?.hideAddMenu { [weak self] in
                self?.pushPostPage(mode: .photos)
            }
        }
        v.onVideoTapped = { [weak self] in
            self?.hideAddMenu { [weak self] in
                self?.pushPostPage(mode: .video)
            }
        }
        return v
    }()

    private lazy var topView: UIImageView = {
        let v = UIImageView()
        v.image = "star_top".toImage
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

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

    private lazy var postButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage("star_post".toImage, for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(onPostTapped), for: .touchUpInside)
        return btn
    }()

    private let emptyView = CS_EmptyView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
        loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideAddMenu()
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(topView)
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(postButton)
        view.addSubview(backButton)
        view.addSubview(addMenuView)

        addMenuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.bringSubviewToFront(addMenuView)
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(postButton)

        topView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(218)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        postButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Layout.postButtonBottomInset)
            make.height.equalTo(Layout.postButtonHeight)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.bottom.equalTo(postButton.snp.top).offset(-8)
        }

        emptyView.snp.makeConstraints { make in
            make.centerX.equalTo(tableView)
            make.centerY.equalTo(tableView).offset(-20)
        }
    }

    private func loadData() {
        postModels = UserData.starrySkyPosts
        posts = postModels.map { $0.toProfilePostItem() }
        emptyView.isHidden = !posts.isEmpty
        tableView.reloadData()
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onPostTapped() {
        if isAddMenuVisible {
            hideAddMenu()
        } else {
            showAddMenu()
        }
    }

    private func showAddMenu() {
        isAddMenuVisible = true
        view.bringSubviewToFront(addMenuView)
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(postButton)
        addMenuView.show()
    }

    private func hideAddMenu(completion: (() -> Void)? = nil) {
        guard isAddMenuVisible else {
            completion?()
            return
        }
        isAddMenuVisible = false
        addMenuView.hide(completion: completion)
    }

    private func pushPostPage(mode: CS_PushPostMediaMode) {
        navigationController?.pushViewController(
            CS_PushPostVC(mediaMode: mode, appendStarrySkyTag: true),
            animated: true
        )
    }
}

// MARK: - UITableView

extension CS_StarPostVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = posts[indexPath.row]
        let model = postModels[indexPath.row]
        let showsDelete = CS_CurrentUser.shared.ownsPost(userId: model.userId)

        switch item.kind {
        case .image:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CS_HomePostCell.reuseID,
                for: indexPath
            ) as? CS_HomePostCell,
                  let post = item.imagePost else {
                return UITableViewCell()
            }
            cell.configure(with: post, showsDelete: showsDelete, showsFollowButton: !showsDelete)
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
            cell.configure(with: post, showsDelete: showsDelete, showsFollowButton: !showsDelete)
            bindVideoCellActions(cell, indexPath: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < postModels.count else { return }
        navigationController?.pushViewController(
            CS_PostDetailVC(postModel: postModels[indexPath.row]),
            animated: true
        )
    }

    private func bindImageCellActions(_ cell: CS_HomePostCell, indexPath: IndexPath) {
        cell.onFollowTapped = { [weak self] in
            self?.toggleFollow(at: indexPath)
        }
        cell.onLikeTapped = { [weak self] in
            self?.toggleLike(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleCollect(at: indexPath)
        }
        cell.onReportTapped = { [weak self] in
            self?.openReport(at: indexPath)
        }
        cell.onDeleteTapped = { [weak self] in
            self?.confirmDeletePost(at: indexPath)
        }
        cell.onAvatarTapped = { [weak self] in
            guard let self, indexPath.row < self.postModels.count else { return }
            self.pushPerson(post: self.postModels[indexPath.row])
        }
    }

    private func bindVideoCellActions(_ cell: CS_DiscoverFeedCell, indexPath: IndexPath) {
        cell.onFollowTapped = { [weak self] in
            self?.toggleFollow(at: indexPath)
        }
        cell.onLikeTapped = { [weak self] in
            self?.toggleLike(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleCollect(at: indexPath)
        }
        cell.onReportTapped = { [weak self] in
            self?.openReport(at: indexPath)
        }
        cell.onDeleteTapped = { [weak self] in
            self?.confirmDeletePost(at: indexPath)
        }
        cell.onPlayTapped = {}
        cell.onAvatarTapped = { [weak self] in
            guard let self, indexPath.row < self.postModels.count else { return }
            self.pushPerson(post: self.postModels[indexPath.row])
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

    private func confirmDeletePost(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        confirmDeletePost(postId: postModels[indexPath.row].postId) { [weak self] in
            self?.loadData()
        }
    }

    private func toggleFollow(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        let userId = postModels[indexPath.row].userId
        let isFollowing = UserData.toggleFollow(userId: userId)
        for index in postModels.indices where postModels[index].userId == userId {
            postModels[index].isFollowing = isFollowing
        }
        posts = postModels.map { $0.toProfilePostItem() }
        tableView.reloadData()
    }

    private func openReport(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        let reportVC = CS_ReportVC(postId: postModels[indexPath.row].postId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.loadData()
        }
        navigationController?.pushViewController(reportVC, animated: true)
    }
}
