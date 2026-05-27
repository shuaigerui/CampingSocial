//
//  CS_LiveVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import AVFoundation
import UIKit

/// 直播间：全屏循环播放视频 + 弹幕式聊天
final class CS_LiveVC: CS_BaseVC {

    private enum Layout {
        static let chatAreaHeight: CGFloat = 200
    }

    private let liveItem: CS_DiscoverLiveItem
    private var messages: [CS_LiveChatMessage] = []
    private var messageTimer: Timer?

    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    private var playerLayer: AVPlayerLayer?

    private let playerContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isUserInteractionEnabled = false
        return v
    }()

    private let infoCardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.layer.cornerRadius = 14
        return v
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14, weight: .semibold)
        v.textColor = .white
        v.numberOfLines = 2
        return v
    }()

    private let peopleIconView: UIImageView = {
        let v = UIImageView(image: "discover_people".toImage)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let viewerLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 12, weight: .semibold)
        v.textColor = UIColor(hex: "#7BC67E")
        return v
    }()

    private lazy var closeButton: UIButton = {
        let btn = makeCircleIconButton()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        return btn
    }()

    private lazy var chatTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.isScrollEnabled = true
        tv.contentInsetAdjustmentBehavior = .never
        tv.estimatedRowHeight = 44
        tv.rowHeight = UITableView.automaticDimension
        tv.dataSource = self
        tv.register(CS_LiveChatCell.self, forCellReuseIdentifier: CS_LiveChatCell.reuseID)
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

    init(liveItem: CS_DiscoverLiveItem) {
        self.liveItem = liveItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
        queuePlayer?.play()
        
        CS_NetworkTool.shared.postAFD(isShow: false) { result in
//            switch result {
//            case .success(_):
//            case .failure(_):
//            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if messages.isEmpty {
            appendAutoMessage()
        }
        startMessageTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMessageTimer()
        queuePlayer?.pause()
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        view.backgroundColor = .black
        setupUI()
        applyLiveInfo()
        setupPlayer()
        inputField.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }

    private func setupUI() {
        view.addSubview(playerContainerView)
        view.addSubview(infoCardView)
        infoCardView.addSubview(titleLabel)
        infoCardView.addSubview(peopleIconView)
        infoCardView.addSubview(viewerLabel)
        view.addSubview(closeButton)
        view.addSubview(chatTableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(sendButton)

        view.bringSubviewToFront(infoCardView)
        view.bringSubviewToFront(closeButton)
        view.bringSubviewToFront(chatTableView)
        view.bringSubviewToFront(inputContainer)

        playerContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }

        infoCardView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-12)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
        }

        peopleIconView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.width.height.equalTo(16)
            make.bottom.equalToSuperview().offset(-10)
        }

        viewerLabel.snp.makeConstraints { make in
            make.leading.equalTo(peopleIconView.snp.trailing).offset(4)
            make.centerY.equalTo(peopleIconView)
        }

        inputContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(52)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        inputField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        chatTableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(inputContainer.snp.top).offset(-12)
            make.height.equalTo(Layout.chatAreaHeight)
        }
    }

    private func applyLiveInfo() {
        titleLabel.text = liveItem.title
        viewerLabel.text = "\(liveItem.viewerCount)"
    }

    private func setupPlayer() {
        guard let url = liveItem.videoPath.resourceFileURL else { return }

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer(playerItem: item)
        player.isMuted = false
        queuePlayer = player

        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = playerContainerView.bounds
        playerContainerView.layer.insertSublayer(layer, at: 0)
        playerLayer = layer

        player.play()
    }

    private func makeCircleIconButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }

    // MARK: - Chat

    private func startMessageTimer() {
        stopMessageTimer()
        scheduleNextAutoMessage()
    }

    private func stopMessageTimer() {
        messageTimer?.invalidate()
        messageTimer = nil
    }

    private func scheduleNextAutoMessage() {
        let delay = Double.random(in: 3...6)
        let timer = Timer(timeInterval: delay, repeats: false) { [weak self] _ in
            self?.appendAutoMessage()
            self?.scheduleNextAutoMessage()
        }
        RunLoop.main.add(timer, forMode: .common)
        messageTimer = timer
    }

    private func appendAutoMessage() {
        appendMessage(
            userName: CS_LiveRoomScripts.randomName(),
            text: CS_LiveRoomScripts.randomMessage(for: liveItem.themeKey)
        )
    }

    private func appendMessage(userName: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let appendBlock = { [weak self] in
            guard let self else { return }
            self.messages.append(CS_LiveChatMessage(userName: userName, text: trimmed))
            self.chatTableView.reloadData()
            let lastRow = self.messages.count - 1
            guard lastRow >= 0 else { return }
            let indexPath = IndexPath(row: lastRow, section: 0)
            self.chatTableView.layoutIfNeeded()
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }

        if Thread.isMainThread {
            appendBlock()
        } else {
            DispatchQueue.main.async(execute: appendBlock)
        }
    }

    @objc private func onClose() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onMore() {
        // 预留更多操作
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
        
        guard let text = inputField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        let name = CS_CurrentUser.shared.user?.userName ?? "You"
        appendMessage(userName: name, text: text)
        inputField.text = nil
    }
}

// MARK: - UITableViewDataSource

extension CS_LiveVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CS_LiveChatCell.reuseID,
            for: indexPath
        ) as? CS_LiveChatCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - UITextFieldDelegate

extension CS_LiveVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSend()
        return true
    }
}
