//
//  CS_ContactVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/27.
//

import Toast_Swift
import UIKit

class CS_ContactVC: CS_BaseVC {

    static let supportEmail = "Taggoofeadback@gmail.com"

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "Contact Us"
        v.textColor = .white
        v.font = .systemFont(ofSize: 18, weight: .semibold)
        v.textAlignment = .center
        return v
    }()

    private let panelView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F3F7BB").withAlphaComponent(0.5)
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private let messageLabel: UILabel = {
        let v = UILabel()
        v.text = "If you have any questions, feedback, or need help, please reach out to us by email. We will get back to you as soon as possible."
        v.font = .systemFont(ofSize: 15)
        v.textColor = UIColor(hex: "#4A3F35")
        v.numberOfLines = 0
        return v
    }()

    private let emailTitleLabel: UILabel = {
        let v = UILabel()
        v.text = "Email"
        v.font = .systemFont(ofSize: 13, weight: .medium)
        v.textColor = UIColor(hex: "#4A3F35").withAlphaComponent(0.7)
        return v
    }()

    private lazy var emailButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(Self.supportEmail, for: .normal)
        btn.setTitleColor(UIColor(hex: "#2D6A4F"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .left
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(onEmailTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var copyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Copy email", for: .normal)
        btn.setTitleColor(UIColor(hex: "#4A3F35"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = UIColor(hex: "#E6E2D0")
        btn.layer.cornerRadius = 18
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        btn.addTarget(self, action: #selector(onCopyEmail), for: .touchUpInside)
        return btn
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(panelView)
        panelView.addSubview(messageLabel)
        panelView.addSubview(emailTitleLabel)
        panelView.addSubview(emailButton)
        panelView.addSubview(copyButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
            make.left.greaterThanOrEqualTo(backButton.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-20)
        }

        panelView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(20)
        }

        emailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(24)
            make.left.right.equalTo(messageLabel)
        }

        emailButton.snp.makeConstraints { make in
            make.top.equalTo(emailTitleLabel.snp.bottom).offset(8)
            make.left.right.equalTo(messageLabel)
        }

        copyButton.snp.makeConstraints { make in
            make.top.equalTo(emailButton.snp.bottom).offset(20)
            make.left.equalTo(messageLabel)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onEmailTapped() {
        let encoded = Self.supportEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? Self.supportEmail
        guard let url = URL(string: "mailto:\(encoded)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            copyEmailToPasteboard()
        }
    }

    @objc private func onCopyEmail() {
        copyEmailToPasteboard()
    }

    private func copyEmailToPasteboard() {
        UIPasteboard.general.string = Self.supportEmail
        view.makeToast("Email copied")
    }
}
