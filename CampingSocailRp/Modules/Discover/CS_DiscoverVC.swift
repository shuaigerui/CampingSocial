//
//  CS_DiscoverVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_DiscoverVC: CS_BaseVC {

    private var forYouItems: [CS_DiscoverFeedItem] = []
    private var followingItems: [CS_DiscoverFeedItem] = []
    private var currentSegment = 0

    private var displayItems: [CS_DiscoverFeedItem] {
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
        let sample = CS_DiscoverFeedItem(
            coverImageName: "discover",
            content: "Like bitternessLike bitternessLike bitternessLike bitternessLike bitterness",
            userName: "Luoluo",
            isFollowing: false,
            isCollected: false
        )
        let sampleFollowing = CS_DiscoverFeedItem(
            coverImageName: "discover",
            content: "Like bitternessLike bitternessLike bitternessLike bitternessLike bitterness",
            userName: "Luoluo",
            isFollowing: true,
            isCollected: true
        )
        forYouItems = Array(repeating: sample, count: 4)
        followingItems = Array(repeating: sampleFollowing, count: 2)
    }
}

extension CS_DiscoverVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CS_DiscoverFeedCell.reuseID,
            for: indexPath
        ) as? CS_DiscoverFeedCell else {
            return UITableViewCell()
        }

        let item = displayItems[indexPath.row]
        cell.configure(with: item)

        cell.onFollowTapped = { [weak self] in
            self?.toggleFollow(at: indexPath)
        }
        cell.onCollectTapped = { [weak self] in
            self?.toggleCollect(at: indexPath)
        }
        cell.onReportTapped = {}
        cell.onPlayTapped = {}

        return cell
    }

    private func toggleFollow(at indexPath: IndexPath) {
        if currentSegment == 0 {
            forYouItems[indexPath.row].isFollowing.toggle()
        } else {
            followingItems[indexPath.row].isFollowing.toggle()
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    private func toggleCollect(at indexPath: IndexPath) {
        if currentSegment == 0 {
            forYouItems[indexPath.row].isCollected.toggle()
        } else {
            followingItems[indexPath.row].isCollected.toggle()
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
