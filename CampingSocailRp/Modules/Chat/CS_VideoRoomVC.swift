//
//  CS_VideoRoomVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import AVFoundation
import UIKit

class CS_VideoRoomVC: CS_BaseVC {

    private let peer: UserModel
    private let cameraCapturer = CS_LocalCameraCapturer()

    private var isMicOn = true
    private var isSpeakerOn = true
    private var didStartCamera = false

    // MARK: - UI

    /// 全屏：本地相机画面
    private let remoteImageView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#3D3D3D")
        v.clipsToBounds = true
        return v
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "common_back"), for: .normal)
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

    /// 右上角小窗：对方头像，等待接起
    private let localPreviewContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#4A4A4A")
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    private let peerAvatarImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor(hex: "#4A4A4A")
        return v
    }()

    /// 头像上的半透明遮罩，保证菊花可见
    private let peerWaitingOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.isUserInteractionEnabled = false
        return v
    }()

    private let peerWaitingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.color = .white
        v.hidesWhenStopped = false
        return v
    }()

    private let bottomBarBackground: UIImageView = {
        let v = UIImageView(image: "video_bg".toImage)
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()

    private lazy var micButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("video_mic".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onToggleMic), for: .touchUpInside)
        return btn
    }()

    private lazy var hangUpButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("video_off".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onHangUp), for: .touchUpInside)
        return btn
    }()

    private lazy var speakerButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("video_voice".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onToggleSpeaker), for: .touchUpInside)
        return btn
    }()

    // MARK: - Init

    init(peer: UserModel) {
        self.peer = peer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Entry（进入页面前检查权限）

    static func open(from presenter: UIViewController, peer: UserModel) {
        guard CS_ChatAccess.canChat(with: peer.userId) else {
            presenter.showFriendsOnlyPop()
            return
        }
        CS_MediaPermission.requestCamera(from: presenter) { cameraGranted in
            guard cameraGranted else { return }
            CS_MediaPermission.requestMicrophone(from: presenter) { micGranted in
                guard micGranted else { return }
                let vc = CS_VideoRoomVC(peer: peer)
                presenter.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        view.backgroundColor = .black
        titleLabel.text = peer.userName
        loadPeerAvatar()
        setupUI()
        startPeerWaitingIndicator()
        
        CS_NetworkTool.shared.postAFD(isShow: false) { result in
//            switch result {
//            case .success(_):
//            case .failure(_):
//            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCameraIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            cameraCapturer.stop()
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraCapturer.updatePreviewFrame()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(remoteImageView)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(localPreviewContainer)
        localPreviewContainer.addSubview(peerAvatarImageView)
        localPreviewContainer.addSubview(peerWaitingOverlay)
        localPreviewContainer.addSubview(peerWaitingIndicator)
        view.addSubview(bottomBarBackground)
        bottomBarBackground.addSubview(micButton)
        bottomBarBackground.addSubview(hangUpButton)
        bottomBarBackground.addSubview(speakerButton)

        remoteImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.width - 120)
        }

        localPreviewContainer.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(108)
            make.height.equalTo(148)
        }

        peerAvatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        peerWaitingOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        peerWaitingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        bottomBarBackground.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-113)
        }

        hangUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(68)
            make.height.equalTo(52)
        }

        micButton.snp.makeConstraints { make in
            make.centerY.equalTo(hangUpButton)
            make.leading.equalToSuperview().offset(40)
            make.width.equalTo(68)
            make.height.equalTo(52)
        }

        speakerButton.snp.makeConstraints { make in
            make.centerY.equalTo(hangUpButton)
            make.trailing.equalToSuperview().offset(-40)
            make.width.equalTo(68)
            make.height.equalTo(52)
        }

        view.bringSubviewToFront(localPreviewContainer)
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(titleLabel)
    }

    private func loadPeerAvatar() {
        if let path = peer.avatarURL, !path.isEmpty {
            peerAvatarImageView.image = path.resourceFileImage ?? path.toImage
        } else {
            peerAvatarImageView.image = "info_avatar".toImage
        }
    }

    private func startCameraIfNeeded() {
        guard !didStartCamera else { return }
        didStartCamera = true
        cameraCapturer.configureAudioSession(speakerOn: isSpeakerOn)
        cameraCapturer.attachPreview(to: remoteImageView)
        cameraCapturer.start()
    }

    /// 等待对方接起，菊花持续显示不自动停止
    private func startPeerWaitingIndicator() {
        peerWaitingOverlay.isHidden = false
        peerWaitingIndicator.startAnimating()
        localPreviewContainer.bringSubviewToFront(peerWaitingOverlay)
        localPreviewContainer.bringSubviewToFront(peerWaitingIndicator)
    }

    // MARK: - Actions

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onMore() {
        navigationController?.pushViewController(CS_ReportVC(), animated: true)
    }

    @objc private func onHangUp() {
        peerWaitingIndicator.stopAnimating()
        cameraCapturer.stop()
        navigationController?.popViewController(animated: true)
    }

    @objc private func onToggleMic() {
        isMicOn.toggle()
        cameraCapturer.isMicEnabled = isMicOn
        micButton.setImage((isMicOn ? "video_mic" : "video_mic_off").toImage, for: .normal)
    }

    @objc private func onToggleSpeaker() {
        isSpeakerOn.toggle()
        cameraCapturer.configureAudioSession(speakerOn: isSpeakerOn)
        speakerButton.setImage((isSpeakerOn ? "video_voice" : "video_voice_off").toImage, for: .normal)
    }
}
