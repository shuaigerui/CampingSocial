//
//  CS_ChatRoomVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit
import Toast_Swift

class CS_ChatRoomVC: CS_BaseVC {

    private let peer: UserModel
    private var messages: [CS_ChatRoomMessage] = []

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

    private lazy var moreButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("person_more".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onMore), for: .touchUpInside)
        return btn
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInsetAdjustmentBehavior = .never
        tv.estimatedRowHeight = 80
        tv.rowHeight = UITableView.automaticDimension
        tv.keyboardDismissMode = .onDrag
        tv.dataSource = self
        tv.register(CS_ChatRoomMessageCell.self, forCellReuseIdentifier: CS_ChatRoomMessageCell.reuseID)
        return tv
    }()

    private lazy var videoButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("room_video".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onVideo), for: .touchUpInside)
        return btn
    }()

    private let inputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    private lazy var galleryButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("push_add".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onGallery), for: .touchUpInside)
        return btn
    }()

    private let inputField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Say something"
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = UIColor(hex: "#4A3F35")
        tf.returnKeyType = .send
        tf.attributedPlaceholder = NSAttributedString(
            string: "Say something",
            attributes: [.foregroundColor: UIColor(hex: "#999999")]
        )
        return tf
    }()

    private lazy var sendButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("post_send".toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(onSend), for: .touchUpInside)
        return btn
    }()

    init(peer: UserModel) {
        self.peer = peer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
        reloadMessages()
        CS_ChatStorage.markConversationRead(peerUserId: peer.userId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = peer.userName
        inputField.delegate = self
        setupUI()
        CS_ChatStorage.ensurePeerGreetingIfEmpty(peer: peer)
        reloadMessages()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(moreButton)
        view.addSubview(tableView)
        view.addSubview(videoButton)
        view.addSubview(inputContainer)
        inputContainer.addSubview(galleryButton)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(sendButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(backButton.snp.right).offset(8)
            make.right.lessThanOrEqualTo(moreButton.snp.left).offset(-8)
        }

        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }

        inputContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(52)
        }

        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        galleryButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        inputField.snp.makeConstraints { make in
            make.left.equalTo(galleryButton.snp.right).offset(4)
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }

        videoButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalTo(inputContainer.snp.top).offset(-12)
            make.width.height.equalTo(52)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(videoButton.snp.top).offset(-8)
        }
    }

    private func reloadMessages() {
        messages = CS_ChatStorage.messages(peerUserId: peer.userId)
        tableView.reloadData()
        scrollToBottom(animated: false)
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onMore() {
        confirmBlockUser()
    }

    @objc private func onVideo() {
        CS_VideoRoomVC.open(from: self, peer: peer)
    }

    @objc private func onGallery() {
        view.makeToast("Coming soon")
    }

    @objc private func onSend() {
        
        CS_NetworkTool.shared.postAFD(isShow: false) { result in
            switch result {
            case .success(_):
                self.sendAction()
            case .failure(_):
                self.sendAction()
            }
        }
    }
    
    private func sendAction(){
        
        let text = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        inputField.text = nil

        let message = CS_ChatRoomMessage(sender: .me, text: text)
        CS_ChatStorage.appendMessage(
            peerUserId: peer.userId,
            peerUserName: peer.userName,
            peerAvatarURL: peer.avatarURL,
            message: message
        )
        reloadMessages()
    }
    
    private func confirmBlockUser() {
        guard CS_CurrentUser.shared.user?.userId != peer.userId else { return }

        let alert = UIAlertController(
            title: "Block User",
            message: "You will no longer see posts from \(peer.userName). Your chat history will be deleted and they will be added to your blacklist.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            self?.performBlockUser()
        })
        present(alert, animated: true)
    }

    private func performBlockUser() {
        CS_UserListStorage.blockUser(userId: peer.userId)
        view.makeToast("Blocked \(peer.userName)")
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView

extension CS_ChatRoomVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CS_ChatRoomMessageCell.reuseID,
            for: indexPath
        ) as? CS_ChatRoomMessageCell else {
            return UITableViewCell()
        }
        let message = messages[indexPath.row]
        cell.configure(
            with: message,
            peerAvatarURL: peer.avatarURL,
            myAvatarURL: CS_CurrentUser.shared.user?.avatarURL
        )
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension CS_ChatRoomVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSend()
        return true
    }
}
