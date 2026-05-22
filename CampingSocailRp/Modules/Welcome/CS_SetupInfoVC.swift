//
//  CS_SetupInfoVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_SetupInfoVC: CS_BaseVC {

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "common_back"), for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private lazy var avatarButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(onAvatarTapped), for: .touchUpInside)
        return btn
    }()

    private let avatarImageView: UIImageView = {
        let v = UIImageView(image: "info_avatar".toImage)
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 93 / 2
        v.isUserInteractionEnabled = false
        return v
    }()

    private let cameraImageView: UIImageView = {
        let v = UIImageView(image: "info_camera".toImage)
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
    }()

    private lazy var nameField = CS_SetupInfoVC.makeInputField(placeholder: "Halle Berry")

    private lazy var bioTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = .white
        tv.backgroundColor = UIColor(hex: "#F3F7BB", alpha: 0.5)
        tv.layer.cornerRadius = 16
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        tv.autocapitalizationType = .sentences
        tv.delegate = self
        return tv
    }()

    private let bioPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Your bio"
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        return label
    }()

    private lazy var switchTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isSelectable = true
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.delegate = self
        tv.attributedText = Self.makeSignInText()
        tv.linkTextAttributes = [
            .foregroundColor: UIColor(hex: "#4A3F35"),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return tv
    }()

    private lazy var createButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("info_create".toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(onCreate), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateBioPlaceholder()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(avatarButton)
        avatarButton.addSubview(avatarImageView)
        avatarButton.addSubview(cameraImageView)
        view.addSubview(nameField)
        view.addSubview(bioTextView)
        bioTextView.addSubview(bioPlaceholderLabel)
        view.addSubview(switchTextView)
        view.addSubview(createButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }

        avatarButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(93)
        }

        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cameraImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        nameField.snp.makeConstraints { make in
            make.top.equalTo(avatarButton.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(65)
        }

        bioTextView.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(16)
            make.left.right.equalTo(nameField)
            make.height.equalTo(140)
        }

        bioPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(15)
        }

        createButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(358)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        switchTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.bottom.equalTo(createButton.snp.top).offset(-16)
        }
    }

    private static func makeInputField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = .white
        tf.backgroundColor = UIColor(hex: "#F3F7BB", alpha: 0.5)
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftViewMode = .always
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.85)]
        )
        return tf
    }

    private static func makeSignInText() -> NSAttributedString {
        let text = "Already have an account? Sign in"
        let linkText = "Sign in"
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor(hex: "#4A3F35")
            ]
        )
        let range = (text as NSString).range(of: linkText)
        attr.addAttribute(.link, value: "cs://sign-in", range: range)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        attr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: text.count))
        return attr
    }

    private func updateBioPlaceholder() {
        bioPlaceholderLabel.isHidden = !bioTextView.text.isEmpty
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onAvatarTapped() {}

    @objc private func onCreate() {
        enterMainApp()
    }

    private func openSignIn() {
        guard let nav = navigationController else { return }
        nav.popToRootViewController(animated: false)
        nav.pushViewController(CS_SetupFormVC(mode: .signIn), animated: true)
    }

    private func enterMainApp() {
        guard let window = view.window ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow }) else { return }
        window.rootViewController = CS_TabBarVC()
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
    }
}

extension CS_SetupInfoVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        if textView === bioTextView {
            updateBioPlaceholder()
        }
    }

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        if URL.absoluteString == "cs://sign-in" {
            openSignIn()
        }
        return false
    }
}
