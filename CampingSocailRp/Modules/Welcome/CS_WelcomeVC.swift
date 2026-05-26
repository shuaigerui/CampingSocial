//
//  CS_WelcomeVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import AuthenticationServices
import Toast_Swift
import UIKit

class CS_WelcomeVC: CS_BaseVC {

    private let topImageView: UIImageView = {
        let v = UIImageView()
        v.image = "login_top".toImage
        v.contentMode = .scaleAspectFill
        return v
    }()

    private let bottomImageView: UIImageView = {
        let v = UIImageView()
        v.image = "login_bottom".toImage
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()

    private let titleImageView: UIImageView = {
        let v = UIImageView()
        v.image = "login_title".toImage
        v.contentMode = .scaleAspectFill
        return v
    }()

    private lazy var appleButton = makeImageButton(imageName: "login_apple", action: #selector(onAppleSignIn))
    private lazy var createButton = makeImageButton(imageName: "login_create", action: #selector(onCreateAccount))
    private lazy var signInButton = makeImageButton(imageName: "login_sign", action: #selector(onSignIn))

    private lazy var agreementTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isSelectable = true
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.delegate = self
        tv.attributedText = Self.makeAgreementText()
        tv.linkTextAttributes = [
            .foregroundColor: UIColor(hex: "#4A3F35"),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        setupUI()
    }

    private func setupUI() {
        view.addSubview(topImageView)
        view.addSubview(bottomImageView)
        view.addSubview(titleImageView)
        bottomImageView.addSubview(appleButton)
        bottomImageView.addSubview(createButton)
        bottomImageView.addSubview(signInButton)
        bottomImageView.addSubview(agreementTextView)

        topImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomImageView.snp.top)
        }
        
        bottomImageView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom).offset(-40)
        }

        titleImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(70)
        }

        appleButton.snp.makeConstraints { make in
            make.centerX.equalTo(bottomImageView)
            make.width.equalTo(358)
            make.height.equalTo(60)
            make.top.equalTo(bottomImageView).offset(40)
        }

        createButton.snp.makeConstraints { make in
            make.centerX.width.height.equalTo(appleButton)
            make.top.equalTo(appleButton.snp.bottom).offset(16)
        }

        signInButton.snp.makeConstraints { make in
            make.centerX.width.height.equalTo(appleButton)
            make.top.equalTo(createButton.snp.bottom).offset(16)
        }

        agreementTextView.snp.makeConstraints { make in
            make.left.right.equalTo(bottomImageView).inset(75)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }

    private func makeImageButton(imageName: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setImage(imageName.toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    private static func makeAgreementText() -> NSAttributedString {
        let text = "By signing up, you agree to the User Agreement & Privacy Policy"
        let attr = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor(hex: "#4A3F35")
            ]
        )
        let userRange = (text as NSString).range(of: "User Agreement")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        attr.addAttribute(.link, value: "cs://user-agreement", range: userRange)
        attr.addAttribute(.link, value: "cs://privacy-policy", range: privacyRange)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        attr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: text.count))
        return attr
    }

    @objc private func onAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private static func formattedName(from components: PersonNameComponents?) -> String? {
        guard let components else { return nil }
        let formatter = PersonNameComponentsFormatter()
        let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? nil : name
    }

    @objc private func onCreateAccount() {
        navigationController?.pushViewController(CS_SetupFormVC(mode: .create), animated: true)
    }

    @objc private func onSignIn() {
        navigationController?.pushViewController(CS_SetupFormVC(mode: .signIn), animated: true)
    }
}

// MARK: - Sign in with Apple

extension CS_WelcomeVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window ?? UIWindow()
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            view.makeToast("Apple sign in failed")
            return
        }

        let appleUserId = credential.user
        if CS_CurrentUser.shared.loginExistingAppleAccount(appleUserId: appleUserId) {
            CS_CurrentUser.shared.switchRoot(on: view.window)
            return
        }

        let suggestedName = Self.formattedName(from: credential.fullName)
        navigationController?.pushViewController(
            CS_SetupInfoVC(mode: .apple(appleUserId: appleUserId, suggestedName: suggestedName)),
            animated: true
        )
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            return
        }
        view.makeToast("Apple sign in failed")
    }
}

extension CS_WelcomeVC: UITextViewDelegate {

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        switch URL.absoluteString {
        case "cs://user-agreement":
            break
        case "cs://privacy-policy":
            break
        default:
            break
        }
        return false
    }
}
