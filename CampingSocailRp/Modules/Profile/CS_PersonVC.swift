//
//  CS_PersonVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

class CS_PersonVC: CS_BaseVC {

    private let user: UserModel
    private var isFollowing: Bool
    private var posts: [CS_ProfilePostItem] = []

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
        posts = userPosts.map { $0.toProfilePostItem() }
        headerView.configure(with: user, postCount: userPosts.count, isFollowing: isFollowing)
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
            self?.navigationController?.pushViewController(CS_ReportVC(), animated: true)
        }
        headerView.onChatTapped = {}
    }

    private func toggleFollow() {
        isFollowing.toggle()
        headerView.configure(
            with: user,
            postCount: posts.count,
            isFollowing: isFollowing
        )
    }
}

extension CS_PersonVC: UITableViewDataSource {

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
            cell.configure(with: post, showsFollowButton: false)
            return cell

        case .video:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CS_DiscoverFeedCell.reuseID,
                for: indexPath
            ) as? CS_DiscoverFeedCell,
                  let post = item.videoPost else {
                return UITableViewCell()
            }
            cell.configure(with: post, showsFollowButton: false)
            return cell
        }
    }
}
