//
//  CS_ProfileVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_ProfileVC: CS_BaseVC {

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
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: 427)
        tableView.tableHeaderView = headerView

        headerView.onSettingsTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_SettingVC(), animated: true)
        }
        headerView.onEditAvatarTapped = {}
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
            ]
        )

        let videoPost = CS_DiscoverFeedItem(
            coverImageName: "discover",
            content: "Like bitternessLike bitternessLike bitternessLike bitternessLike bitterness",
            userName: "Luoluo",
            isFollowing: false,
            isCollected: true
        )

        posts = [
            CS_ProfilePostItem(kind: .image, imagePost: imagePost, videoPost: nil),
            CS_ProfilePostItem(kind: .video, imagePost: nil, videoPost: videoPost),
            CS_ProfilePostItem(kind: .image, imagePost: imagePost, videoPost: nil)
        ]
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
            cell.configure(with: post, showsDelete: true)
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
            cell.configure(with: post, showsDelete: true)
            bindVideoCellActions(cell, indexPath: indexPath)
            return cell
        }
    }

    private func bindImageCellActions(_ cell: CS_HomePostCell, indexPath: IndexPath) {
        cell.onFollowTapped = { [weak self] in
            guard let self, var post = self.posts[indexPath.row].imagePost else { return }
            post.isFollowing.toggle()
            self.posts[indexPath.row].imagePost = post
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        cell.onLikeTapped = { [weak self] in
            guard let self, var post = self.posts[indexPath.row].imagePost else { return }
            post.isLiked.toggle()
            self.posts[indexPath.row].imagePost = post
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        cell.onCollectTapped = { [weak self] in
            guard let self, var post = self.posts[indexPath.row].imagePost else { return }
            post.isCollected.toggle()
            self.posts[indexPath.row].imagePost = post
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        cell.onDeleteTapped = { [weak self] in
            self?.deletePost(at: indexPath)
        }
    }

    private func bindVideoCellActions(_ cell: CS_DiscoverFeedCell, indexPath: IndexPath) {
        cell.onFollowTapped = { [weak self] in
            guard let self, var post = self.posts[indexPath.row].videoPost else { return }
            post.isFollowing.toggle()
            self.posts[indexPath.row].videoPost = post
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        cell.onCollectTapped = { [weak self] in
            guard let self, var post = self.posts[indexPath.row].videoPost else { return }
            post.isCollected.toggle()
            self.posts[indexPath.row].videoPost = post
            self.tableView.reloadRows(at: [indexPath], with: .none)
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
