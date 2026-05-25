//
//  CS_DiscoverVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_DiscoverVC: CS_BaseVC {

    private var forYouItems: [CS_ProfilePostItem] = []
    private var followingItems: [CS_ProfilePostItem] = []
    private var currentSegment = 0

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

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMockData()
        setupTableView()
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

    private func loadMockData() {
        let imagePost = CS_HomePost(
            userName: "Luoluo",
            time: "09:08am",
            content: "Hiking through the clouds and mist is like stepping into another world",
            likeCount: 125,
            commentCount: 39,
            isFollowing: false,
            isLiked: false,
            isCollected: false,
            imageColors: [
                UIColor(hex: "#C5D4B0"),
                UIColor(hex: "#A8B89A"),
                UIColor(hex: "#8FA67E")
            ],
            imagePaths: [],
            avatarPath: nil
        )

        let videoPost = CS_DiscoverFeedItem(
            coverImageName: "discover",
            content: "Like bitternessLike bitternessLike bitternessLike bitternessLike bitterness",
            userName: "Luoluo",
            isFollowing: false,
            isCollected: false,
            coverImagePath: nil,
            videoPath: nil
        )

        let videoPostFollowing = CS_DiscoverFeedItem(
            coverImageName: "discover",
            content: "Like bitternessLike bitternessLike bitternessLike bitternessLike bitterness",
            userName: "Luoluo",
            isFollowing: true,
            isCollected: true,
            coverImagePath: nil,
            videoPath: nil
        )

        forYouItems = [
            CS_ProfilePostItem(kind: .video, imagePost: nil, videoPost: videoPost),
            CS_ProfilePostItem(kind: .image, imagePost: imagePost, videoPost: nil),
            CS_ProfilePostItem(kind: .video, imagePost: nil, videoPost: videoPost),
            CS_ProfilePostItem(kind: .image, imagePost: imagePost, videoPost: nil)
        ]

        followingItems = [
            CS_ProfilePostItem(kind: .video, imagePost: nil, videoPost: videoPostFollowing),
            CS_ProfilePostItem(kind: .image, imagePost: imagePost, videoPost: nil)
        ]
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

    private func bindImageCellActions(_ cell: CS_HomePostCell, indexPath: IndexPath) {
        cell.onFollowTapped = { [weak self] in
            self?.toggleImageFollow(at: indexPath)
        }
        cell.onLikeTapped = { [weak self] in
            self?.toggleImageLike(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleImageCollect(at: indexPath)
        }
        cell.onReportTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_ReportVC(), animated: true)
        }
    }

    private func bindVideoCellActions(_ cell: CS_DiscoverFeedCell, indexPath: IndexPath) {
        cell.onFollowTapped = { [weak self] in
            self?.toggleVideoFollow(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleVideoCollect(at: indexPath)
        }
        cell.onReportTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_ReportVC(), animated: true)
        }
        cell.onPlayTapped = {}
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
        updateItem(at: indexPath) { item in
            item.imagePost?.isLiked.toggle()
        }
    }

    private func toggleImageCollect(at indexPath: IndexPath) {
        updateItem(at: indexPath) { item in
            item.imagePost?.isCollected.toggle()
        }
    }

    private func toggleVideoFollow(at indexPath: IndexPath) {
        updateItem(at: indexPath) { item in
            item.videoPost?.isFollowing.toggle()
        }
    }

    private func toggleVideoCollect(at indexPath: IndexPath) {
        updateItem(at: indexPath) { item in
            item.videoPost?.isCollected.toggle()
        }
    }
}
