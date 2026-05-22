//
//  CS_AddMenuView.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

/// 点击 TabBar 中间 + 号后展示的 Photo / Video 选择层
final class CS_AddMenuView: UIView {

    private enum Layout {
        static let designWidth: CGFloat = 465
        static let designHeight: CGFloat = 291
        static let buttonWidth: CGFloat = designWidth / 3
        static let buttonHeight: CGFloat = designHeight / 3
    }

    var onPhotoTapped: (() -> Void)?
    var onVideoTapped: (() -> Void)?
    var onDismiss: (() -> Void)?

    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    private lazy var photoButton = makeImageButton(imageName: "add_pic", action: #selector(photoTapped))
    private lazy var videoButton = makeImageButton(imageName: "add_video", action: #selector(videoTapped))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(dimView)
        addSubview(buttonsStack)
        buttonsStack.addArrangedSubview(photoButton)
        buttonsStack.addArrangedSubview(videoButton)

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        buttonsStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-110)
        }

        photoButton.snp.makeConstraints { make in
            make.width.equalTo(Layout.buttonWidth)
            make.height.equalTo(Layout.buttonHeight)
        }

        videoButton.snp.makeConstraints { make in
            make.width.height.equalTo(photoButton)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(tap)
    }

    private func makeImageButton(imageName: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setImage(imageName.toImage, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    func show(animated: Bool = true) {
        isHidden = false
        guard animated else {
            alpha = 1
            return
        }
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard animated else {
            isHidden = true
            alpha = 0
            completion?()
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            completion?()
        })
    }

    @objc private func dimTapped() {
        onDismiss?()
    }

    @objc private func photoTapped() {
        onPhotoTapped?()
    }

    @objc private func videoTapped() {
        onVideoTapped?()
    }
}
