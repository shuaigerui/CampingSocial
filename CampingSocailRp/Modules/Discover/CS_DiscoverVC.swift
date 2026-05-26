//
//  CS_DiscoverVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_DiscoverVC: CS_BaseVC {

    private var forYouPostModels: [PostModel] = []
    private var followingPostModels: [PostModel] = []
    private var forYouItems: [CS_ProfilePostItem] = []
    private var followingItems: [CS_ProfilePostItem] = []
    private var currentSegment = 0

    private var displayPostModels: [PostModel] {
        currentSegment == 0 ? forYouPostModels : followingPostModels
    }

    private var displayItems: [CS_ProfilePostItem] {
        currentSegment == 0 ? forYouItems : followingItems
    }

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

    private lazy var headerView = CS_DiscoverHeaderView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func loadData() {
        let all = UserData.allPosts
        forYouPostModels = all
        forYouItems = all.map { $0.toProfilePostItem() }

        followingPostModels = all
        followingItems = forYouItems

        tableView.reloadData()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        let width = UIScreen.main.bounds.width
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: CS_DiscoverHeaderView.preferredHeight)
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView

        headerView.onSegmentChanged = { [weak self] tag in
            self?.currentSegment = tag
            self?.tableView.reloadData()
        }
    }

}

extension CS_DiscoverVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = displayItems[indexPath.row]

        switch item.kind {
        case .image:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CS_HomePostCell.reuseID,
                for: indexPath
            ) as? CS_HomePostCell,
                  let post = item.imagePost else {
                return UITableViewCell()
            }
            cell.configure(with: post)
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
            cell.configure(with: post)
            bindVideoCellActions(cell, indexPath: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let models = displayPostModels
        guard indexPath.row < models.count else { return }
        let detailVC = CS_PostDetailVC(postModel: models[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func bindImageCellActions(_ cell: CS_HomePostCell, indexPath: IndexPath) {
        cell.onFollowTapped = { [weak self] in
            self?.toggleImageFollow(at: indexPath)
        }
        cell.onLikeTapped = { [weak self] in
            self?.toggleImageLike(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleCollect(at: indexPath)
        }
        cell.onReportTapped = { [weak self] in
            self?.openReport(at: indexPath)
        }
        cell.onAvatarTapped = { [weak self] in
            guard let self else { return }
            let models = self.displayPostModels
            guard indexPath.row < models.count else { return }
            self.pushPerson(post: models[indexPath.row])
        }
    }

    private func openReport(at indexPath: IndexPath) {
        let models = displayPostModels
        guard indexPath.row < models.count else { return }
        let postId = models[indexPath.row].postId
        let reportVC = CS_ReportVC(postId: postId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.loadData()
        }
        navigationController?.pushViewController(reportVC, animated: true)
    }

    private func bindVideoCellActions(_ cell: CS_DiscoverFeedCell, indexPath: IndexPath) {
        cell.onFollowTapped = { [weak self] in
            self?.toggleVideoFollow(at: indexPath)
        }
        cell.onLikeTapped = { [weak self] in
            self?.toggleVideoLike(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleCollect(at: indexPath)
        }
        cell.onReportTapped = { [weak self] in
            self?.openReport(at: indexPath)
        }
        cell.onPlayTapped = {}
        cell.onAvatarTapped = { [weak self] in
            guard let self else { return }
            let models = self.displayPostModels
            guard indexPath.row < models.count else { return }
            self.pushPerson(post: models[indexPath.row])
        }
    }

    private func updateItem(at indexPath: IndexPath, _ transform: (inout CS_ProfilePostItem) -> Void) {
        if currentSegment == 0 {
            transform(&forYouItems[indexPath.row])
        } else {
            transform(&followingItems[indexPath.row])
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    private func toggleImageFollow(at indexPath: IndexPath) {
        updateItem(at: indexPath) { item in
            item.imagePost?.isFollowing.toggle()
        }
    }

    private func toggleImageLike(at indexPath: IndexPath) {
        toggleLike(at: indexPath)
    }

    private func toggleVideoLike(at indexPath: IndexPath) {
        toggleLike(at: indexPath)
    }

    private func toggleLike(at indexPath: IndexPath) {
        let models = displayPostModels
        guard indexPath.row < models.count else { return }
        let postId = models[indexPath.row].postId
        let result = UserData.toggleLike(
            postId: postId,
            isLiked: models[indexPath.row].isLiked,
            likeCount: models[indexPath.row].likeCount
        )
        syncLikeState(postId: postId, isLiked: result.isLiked, likeCount: result.likeCount)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    private func syncLikeState(postId: String, isLiked: Bool, likeCount: Int) {
        func apply(to models: inout [PostModel]) {
            guard let index = models.firstIndex(where: { $0.postId == postId }) else { return }
            models[index].isLiked = isLiked
            models[index].likeCount = likeCount
        }
        apply(to: &forYouPostModels)
        apply(to: &followingPostModels)
        forYouItems = forYouPostModels.map { $0.toProfilePostItem() }
        followingItems = followingPostModels.map { $0.toProfilePostItem() }
    }

    private func toggleCollect(at indexPath: IndexPath) {
        let models = displayPostModels
        guard indexPath.row < models.count else { return }
        let postId = models[indexPath.row].postId
        let isCollected = UserData.toggleCollect(
            postId: postId,
            isCollected: models[indexPath.row].isCollected
        )
        syncCollectState(postId: postId, isCollected: isCollected)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    private func syncCollectState(postId: String, isCollected: Bool) {
        func apply(to models: inout [PostModel]) {
            guard let index = models.firstIndex(where: { $0.postId == postId }) else { return }
            models[index].isCollected = isCollected
        }
        apply(to: &forYouPostModels)
        apply(to: &followingPostModels)
        forYouItems = forYouPostModels.map { $0.toProfilePostItem() }
        followingItems = followingPostModels.map { $0.toProfilePostItem() }
    }

    private func toggleVideoFollow(at indexPath: IndexPath) {
        updateItem(at: indexPath) { item in
            item.videoPost?.isFollowing.toggle()
        }
    }

}
