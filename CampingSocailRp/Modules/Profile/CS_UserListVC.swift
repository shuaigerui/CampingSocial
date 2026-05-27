//
//  CS_UserListVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import UIKit
import Toast_Swift

class CS_UserListVC: CS_BaseVC {

    private let kind: CS_UserListKind
    private var users: [UserModel] = []

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 18, weight: .semibold)
        v.textColor = .white
        v.textAlignment = .center
        return v
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInsetAdjustmentBehavior = .never
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = 76
        tv.register(CS_UserListCell.self, forCellReuseIdentifier: CS_UserListCell.reuseID)
        return tv
    }()

    private let emptyView = CS_EmptyView()

    init(kind: CS_UserListKind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
        CS_NetworkTool.shared.postAFD { result in
            switch result {
            case .success(_):
                self.reloadData()
            case .failure(_):
                self.reloadData()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = kind.title
        setupUI()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(backButton.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }

        emptyView.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
    }

    private func reloadData() {
        users = CS_UserListStorage.users(for: kind)
        emptyView.isHidden = !users.isEmpty
        tableView.reloadData()
    }

    private func handleAction(for user: UserModel, at indexPath: IndexPath) {
        switch kind {
        case .friendRequest, .followers:
            if CS_UserListStorage.isMutualFriend(userId: user.userId) {
                openChatRoom(peer: user)
            } else {
                CS_UserListStorage.acceptFriendRequest(userId: user.userId)
                view.makeToast("Following \(user.userName)")
                if let cell = tableView.cellForRow(at: indexPath) as? CS_UserListCell {
                    cell.configure(user: user, actionStyle: .image("user_chat"))
                }
            }
        case .following:
            CS_UserListStorage.unfollow(userId: user.userId)
            view.makeToast("Unfollowed \(user.userName)")
            removeUser(at: indexPath)
        case .friends:
            openChatRoom(peer: user)
        case .blockList:
            CS_UserListStorage.unblock(userId: user.userId)
            view.makeToast("Removed \(user.userName)")
            removeUser(at: indexPath)
        }
    }

    private func removeUser(at indexPath: IndexPath) {
        guard users.indices.contains(indexPath.row) else { return }
        users.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        emptyView.isHidden = !users.isEmpty
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView

extension CS_UserListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CS_UserListCell.reuseID,
            for: indexPath
        ) as? CS_UserListCell else {
            return UITableViewCell()
        }
        let user = users[indexPath.row]
        var style = kind.actionStyle
        if kind == .friendRequest || kind == .followers,
           CS_UserListStorage.isMutualFriend(userId: user.userId) {
            style = .image("user_chat")
        }
        cell.configure(user: user, actionStyle: style)
        cell.onActionTapped = { [weak self] in
            self?.handleAction(for: user, at: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        navigationController?.pushViewController(
            CS_PersonVC(user: user, isFollowing: UserData.isFollowing(userId: user.userId)),
            animated: true
        )
    }
}
