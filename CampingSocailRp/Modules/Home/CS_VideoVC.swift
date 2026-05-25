//
//  CS_VideoVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import AVFoundation
import UIKit

/// 全屏本地视频播放（仅播放与返回，无其它业务操作）
final class CS_VideoVC: CS_BaseVC {

    private let postModel: PostModel
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isPlaying = false

    private let playerContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var playButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("detail_play".toImage, for: .normal)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        return btn
    }()

    private let contentLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .white
        v.numberOfLines = 0
        return v
    }()

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        return v
    }()

    private let userNameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13, weight: .bold)
        v.textColor = .white
        return v
    }()

    init(postModel: PostModel) {
        self.postModel = postModel
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
        player?.pause()
        NotificationCenter.default.removeObserver(self)
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        view.backgroundColor = .black
        setupUI()
        applyPostInfo()
        setupPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }

    private func setupUI() {
        view.addSubview(playerContainerView)
        view.addSubview(backButton)
        view.addSubview(playButton)
        view.addSubview(contentLabel)
        view.addSubview(avatarView)
        view.addSubview(userNameLabel)

        playerContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(64)
        }

        avatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.height.equalTo(28)
        }

        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.left.equalTo(avatarView.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }

        contentLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(avatarView.snp.top).offset(-12)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePlayPause))
        playerContainerView.addGestureRecognizer(tap)
    }

    private func applyPostInfo() {
        contentLabel.text = postModel.content
        userNameLabel.text = postModel.userName.uppercased()

        if let avatarPath = postModel.avatarURL, !avatarPath.isEmpty {
            avatarView.image = avatarPath.resourceFileImage ?? avatarPath.toImage
            avatarView.backgroundColor = avatarView.image == nil
                ? UIColor(hex: "#D4C4A8") : .clear
        } else {
            avatarView.image = "info_avatar".toImage
        }
    }

    private func setupPlayer() {
        guard let path = postModel.media.videoURL,
              let url = path.resourceFileURL else {
            return
        }

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        layer.frame = playerContainerView.bounds
        playerContainerView.layer.insertSublayer(layer, at: 0)
        playerLayer = layer

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )

        startPlayback()
    }

    private func startPlayback() {
        player?.play()
        isPlaying = true
        playButton.isHidden = true
    }

    private func updatePlayButtonVisibility() {
        playButton.isHidden = isPlaying
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
        updatePlayButtonVisibility()
    }

    @objc private func playerDidFinish() {
        player?.seek(to: .zero)
        player?.play()
        isPlaying = true
        playButton.isHidden = true
    }
}
