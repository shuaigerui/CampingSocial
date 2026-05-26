//
//  CS_ChatVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_ChatVC: CS_BaseVC {

    private var conversations: [CS_ChatConversation] = []

    private let titleImageView: UIImageView = {
        let v = UIImageView(image: "chat_title".toImage)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private lazy var friendRequestButton: UIButton = {
        let btn = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        config.image = "chat_add".toImage
        config.title = "Friend request"
        config.imagePadding = 6
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing
        }
        config.background.backgroundColor = UIColor(hex: "#F3F7BB").withAlphaComponent(0.5)
        config.background.cornerRadius = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 12)
        btn.configuration = config
        btn.addTarget(self, action: #selector(friendRequestTapped), for: .touchUpInside)
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
        tv.rowHeight = 88
        tv.register(CS_ChatListCell.self, forCellReuseIdentifier: CS_ChatListCell.reuseID)
        return tv
    }()
    
    private var emptyView = CS_EmptyView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadConversations()
    }

    private func setupUI() {
        view.addSubview(titleImageView)
        view.addSubview(friendRequestButton)
        view.addSubview(tableView)
        view.addSubview(emptyView)

        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(32)
            make.right.lessThanOrEqualTo(friendRequestButton.snp.left).offset(-12)
        }

        friendRequestButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleImageView)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(36)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func reloadConversations() {
        conversations = CS_ChatStorage.conversationList()
        emptyView.isHidden = conversations.count > 0
        tableView.reloadData()
    }

    private func openChatRoom(at indexPath: IndexPath) {
        guard let user = UserData.user(userId: conversations[indexPath.row].userId) else { return }
        openChatRoom(peer: user)
    }

    @objc private func friendRequestTapped() {
        navigationController?.pushViewController(CS_UserListVC(kind: .friendRequest), animated: true)
    }
}

// MARK: - UITableView

extension CS_ChatVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CS_ChatListCell.reuseID,
            for: indexPath
        ) as? CS_ChatListCell else {
            return UITableViewCell()
        }
        cell.configure(with: conversations[indexPath.row])
        cell.onVideoTapped = { [weak self] in
            self?.openChatRoom(at: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openChatRoom(at: indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            self?.deleteConversation(at: indexPath)
            completion(true)
        }
        delete.image = "chat_del".toImage
        delete.backgroundColor = UIColor(hex: "#E85D4A")
        return UISwipeActionsConfiguration(actions: [delete])
    }

    private func deleteConversation(at indexPath: IndexPath) {
        guard conversations.indices.contains(indexPath.row) else { return }
        let userId = conversations[indexPath.row].userId
        CS_ChatStorage.deleteConversation(peerUserId: userId)
        conversations.remove(at: indexPath.row)
        emptyView.isHidden = !conversations.isEmpty
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
