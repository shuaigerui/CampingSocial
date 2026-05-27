//
//  CS_AIChatRoomVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

class CS_AIChatRoomVC: CS_BaseVC {

    private var messages: [CS_AIChatMessage] = []
    private var pendingReplyWorkItem: DispatchWorkItem?
    private var didSendWelcome = false

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let bannerImageView: UIImageView = {
        let v = UIImageView(image: "home_ai".toImage)
        v.contentMode = .scaleAspectFill
        return v
    }()

    private let chatBackgroundView: UIImageView = {
        let v = UIImageView(image: "ai_bg".toImage)
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.masksToBounds = true
        return v
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
        tv.register(CS_AIChatMessageCell.self, forCellReuseIdentifier: CS_AIChatMessageCell.reuseID)
        return tv
    }()

    private let inputContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pendingReplyWorkItem?.cancel()
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        inputField.delegate = self
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sendWelcomeMessageIfNeeded()
    }

    private func setupUI() {
        view.addSubview(backButton)        
        view.addSubview(chatBackgroundView)
        view.addSubview(bannerImageView)
        view.addSubview(tableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(sendButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        bannerImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(backButton.snp.bottom)
            make.height.equalTo(110)
        }

        inputContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(52)
        }

        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.width.equalTo(59)
            make.height.equalTo(40)
        }

        inputField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }

        chatBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(bannerImageView.snp.bottom).offset(-24)
            make.left.right.bottom.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(chatBackgroundView).offset(65)
            make.bottom.equalTo(inputContainer.snp.top).offset(-15)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func sendWelcomeMessageIfNeeded() {
        guard !didSendWelcome else { return }
        didSendWelcome = true
        appendMessage(CS_AIChatMessage(
            sender: .ai,
            text: CS_AIChatReplyProvider.welcomeMessage
        ))
    }

    private func appendMessage(_ message: CS_AIChatMessage) {
        messages.append(message)
        tableView.reloadData()
        scrollToBottom(animated: true)
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    private func scheduleAIReply() {
        pendingReplyWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.appendMessage(CS_AIChatMessage(
                sender: .ai,
                text: CS_AIChatReplyProvider.randomReply()
            ))
        }
        pendingReplyWorkItem = work
        let delay = Double.random(in: 1...4)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onSend() {
        let text = inputField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        inputField.text = nil
        
        CS_NetworkTool.shared.postAFD(isShow: false) { result in
            switch result {
            case .success(_):
                self.appendMessage(CS_AIChatMessage(sender: .user, text: text))
                self.scheduleAIReply()
            case .failure(_):
                self.appendMessage(CS_AIChatMessage(sender: .user, text: text))
                self.scheduleAIReply()
            }
        }        
    }
}

// MARK: - UITableView

extension CS_AIChatRoomVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CS_AIChatMessageCell.reuseID,
            for: indexPath
        ) as? CS_AIChatMessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension CS_AIChatRoomVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSend()
        return true
    }
}
