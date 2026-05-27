//
//  CS_HomeVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_HomeVC: CS_BaseVC {

    private enum Layout {
        static let headerHeight: CGFloat = 366
    }

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

    private lazy var headerView = CS_HomeHeaderView()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CS_NetworkTool.shared.postAFD { result in
            switch result {
            case .success(_):
                self.loadData()
            case .failure(_):
                self.loadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    private func loadData() {
        postModels = UserData.allPosts
        posts = postModels.map { $0.toProfilePostItem() }
        tableView.reloadData()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        let width = UIScreen.main.bounds.width
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView

        headerView.onAITapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_AIChatRoomVC(), animated: true)
        }
        headerView.onJoinTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_StarPostVC(), animated: true)
        }
    }

}

extension CS_HomeVC: UITableViewDataSource, UITableViewDelegate {

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
        let detailVC = CS_PostDetailVC(postModel: postModels[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
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

    private func confirmDeletePost(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        let postId = postModels[indexPath.row].postId
        confirmDeletePost(postId: postId) { [weak self] in
            self?.loadData()
        }
    }

    private func openReport(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        let postId = postModels[indexPath.row].postId
        let reportVC = CS_ReportVC(postId: postId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.loadData()
        }
        navigationController?.pushViewController(reportVC, animated: true)
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

    private func toggleFollow(at indexPath: IndexPath) {
        guard indexPath.row < postModels.count else { return }
        let userId = postModels[indexPath.row].userId
        let isFollowing = UserData.toggleFollow(userId: userId)
        applyFollowState(userId: userId, isFollowing: isFollowing)
        tableView.reloadData()
    }

    private func applyFollowState(userId: String, isFollowing: Bool) {
        for index in postModels.indices where postModels[index].userId == userId {
            postModels[index].isFollowing = isFollowing
        }
        posts = postModels.map { $0.toProfilePostItem() }
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
}
