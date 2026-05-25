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

    private var posts: [CS_HomePost] = []

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInsetAdjustmentBehavior = .never
        tv.dataSource = self
        tv.delegate = self
        tv.estimatedRowHeight = 320
        tv.rowHeight = UITableView.automaticDimension
        tv.register(CS_HomePostCell.self, forCellReuseIdentifier: CS_HomePostCell.reuseID)
        return tv
    }()

    private lazy var headerView = CS_HomeHeaderView()

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
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: Layout.headerHeight)
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
    }

    private func loadMockData() {
        posts = [
            CS_HomePost(
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
            ),
            CS_HomePost(
                userName: "Luoluo",
                time: "09:08am",
                content: "Hiking through the clouds and mist is like stepping into another world",
                likeCount: 125,
                commentCount: 39,
                isFollowing: true,
                isLiked: true,
                isCollected: true,
                imageColors: [
                    UIColor(hex: "#C5D4B0"),
                    UIColor(hex: "#A8B89A"),
                    UIColor(hex: "#8FA67E")
                ]
            )
        ]
    }
}

extension CS_HomeVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CS_HomePostCell.reuseID,
            for: indexPath
        ) as? CS_HomePostCell else {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        cell.configure(with: post)

        cell.onFollowTapped = { [weak self] in
            self?.posts[indexPath.row].isFollowing.toggle()
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        cell.onLikeTapped = { [weak self] in
            self?.posts[indexPath.row].isLiked.toggle()
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        cell.onCollectTapped = { [weak self] in
            self?.posts[indexPath.row].isCollected.toggle()
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        cell.onReportTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_ReportVC(), animated: true)
        }

        return cell
    }
}
