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
        view.addSubview(tableView)

        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(32)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func reloadConversations() {
        conversations = CS_ChatStorage.conversationList()
        tableView.reloadData()
    }

    private func openChatRoom(at indexPath: IndexPath) {
        guard let user = UserData.user(userId: conversations[indexPath.row].userId) else { return }
        navigationController?.pushViewController(CS_ChatRoomVC(peer: user), animated: true)
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
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
