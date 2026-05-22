//
//  CS_SetupFormVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

enum CS_SetupMode {
    case signIn
    case create
}

class CS_SetupFormVC: CS_BaseVC {

    private let mode: CS_SetupMode
    private var isPasswordVisible = false

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "common_back"), for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let titleImageView: UIImageView = {
        let v = UIImageView()
        v.image = "setup_title".toImage
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#E9DC8A")
        v.layer.cornerRadius = 24
        return v
    }()

    private let emailIconView = CS_SetupFormVC.makeIconView(named: "setup_email")
    private let passwordIconView = CS_SetupFormVC.makeIconView(named: "setup_password")

    private let emailTitleLabel = CS_SetupFormVC.makeSectionTitle("Email")
    private let passwordTitleLabel = CS_SetupFormVC.makeSectionTitle("Password")

    private lazy var emailField = CS_SetupFormVC.makeTextField(placeholder: "Your Email", keyboard: .emailAddress)
    private lazy var passwordField = CS_SetupFormVC.makeTextField(placeholder: "Your Password", keyboard: .default, isSecure: true)

    private lazy var passwordToggleButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("setup_show".toImage, for: .normal)
        btn.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return btn
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
        tv.linkTextAttributes = [
            .foregroundColor: UIColor(hex: "#4A3F35"),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return tv
    }()

    private lazy var actionButton: UIButton = {
        let btn = UIButton(type: .custom)
        let imageName = mode == .signIn ? "setup_sign" : "setup_next"
        btn.setImage(imageName.toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(onAction), for: .touchUpInside)
        return btn
    }()

    init(mode: CS_SetupMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.mode = .signIn
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switchTextView.attributedText = Self.makeSwitchText(mode: mode)
        setupUI()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleImageView)
        view.addSubview(cardView)
        view.addSubview(switchTextView)
        view.addSubview(actionButton)

        cardView.addSubview(emailIconView)
        cardView.addSubview(emailTitleLabel)
        cardView.addSubview(emailField)
        cardView.addSubview(passwordIconView)
        cardView.addSubview(passwordTitleLabel)
        cardView.addSubview(passwordField)
        cardView.addSubview(passwordToggleButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }

        titleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(34)
        }

        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(titleImageView.snp.bottom).offset(28)
            make.height.equalTo(260)
        }

        emailIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(20)
        }

        emailTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(emailIconView)
            make.left.equalTo(emailIconView.snp.right).offset(4)
        }

        emailField.snp.makeConstraints { make in
            make.top.equalTo(emailIconView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(65)
        }

        passwordIconView.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(20)
        }

        passwordTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(passwordIconView)
            make.left.equalTo(passwordIconView.snp.right).offset(4)
        }

        passwordField.snp.makeConstraints { make in
            make.top.equalTo(passwordIconView.snp.bottom).offset(8)
            make.height.left.right.equalTo(emailField)
        }

        passwordToggleButton.snp.makeConstraints { make in
            make.centerY.equalTo(passwordField)
            make.right.equalTo(passwordField).offset(-16)
            make.width.height.equalTo(16)
        }

        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(358)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        switchTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(25)
            make.bottom.equalTo(actionButton.snp.top).offset(-16)
        }
    }

    private static func makeIconView(named: String) -> UIImageView {
        let v = UIImageView(image: named.toImage)
        v.contentMode = .scaleAspectFill
        return v
    }

    private static func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(hex: "#4A3F35")
        return label
    }

    private static func makeTextField(
        placeholder: String,
        keyboard: UIKeyboardType,
        isSecure: Bool = false
    ) -> UITextField {
        let tf = UITextField()
        tf.keyboardType = keyboard
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.isSecureTextEntry = isSecure
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = UIColor(hex: "#4A3F35")
        tf.backgroundColor = UIColor(hex: "#F3F7BB",alpha: 0.5)
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 1))
        tf.rightViewMode = .always
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(hex: "#999999")]
        )
        return tf
    }

    private static func makeSwitchText(mode: CS_SetupMode) -> NSAttributedString {
        let text: String
        let linkText: String
        let linkURL: String
        switch mode {
        case .signIn:
            text = "Don't have an account yet ? Create Account"
            linkText = "Create Account"
            linkURL = "cs://create-account"
        case .create:
            text = "Already have an account? Sign in"
            linkText = "Sign in"
            linkURL = "cs://sign-in"
        }
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor(hex: "#4A3F35")
            ]
        )
        let range = (text as NSString).range(of: linkText)
        attr.addAttribute(.link, value: linkURL, range: range)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        attr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: text.count))
        return attr
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordField.isSecureTextEntry = !isPasswordVisible
        let imageName = isPasswordVisible ? "setup_hidden" : "setup_show"
        passwordToggleButton.setImage(imageName.toImage, for: .normal)
    }

    @objc private func onAction() {
        switch mode {
        case .signIn:
            enterMainApp()
        case .create:
            navigationController?.pushViewController(CS_SetupInfoVC(), animated: true)
        }
    }

    private func enterMainApp() {
        guard let window = view.window ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: { $0.isKeyWindow }) else { return }
        window.rootViewController = CS_TabBarVC()
        UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
    }

    private func openCreateAccount() {
        guard mode == .signIn else { return }
        navigationController?.pushViewController(CS_SetupFormVC(mode: .create), animated: true)
    }

    private func openSignIn() {
        navigationController?.popViewController(animated: true)
    }
}

extension CS_SetupFormVC: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        switch URL.absoluteString {
        case "cs://create-account":
            openCreateAccount()
        case "cs://sign-in":
            openSignIn()
        default:
            break
        }
        return false
    }
}
