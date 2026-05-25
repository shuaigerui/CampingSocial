//
//  CS_ProfileHeaderView.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

class CS_ProfileHeaderView: UIView {

    var onSettingsTapped: (() -> Void)?
    var onEditAvatarTapped: (() -> Void)?

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "Profile"
        v.textColor = .white
        v.font = .systemFont(ofSize: 25, weight: .semibold)
        return v
    }()

    private lazy var settingsButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("profile_setting".toImage, for: .normal)
        btn.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        return btn
    }()

    private let userCardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#E9DD8A")
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        v.layer.cornerRadius = 48
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        if let avatar = "info_avatar".toImage {
            v.image = avatar
        }
        return v
    }()

    private lazy var editButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("profile_edit".toImage, for: .normal)
        btn.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return btn
    }()

    private let nameLabel: UILabel = {
        let v = UILabel()
        v.text = "Boluo"
        v.font = .systemFont(ofSize: 20)
        v.textColor = .black
        return v
    }()

    private let idLabel: UILabel = {
        let v = UILabel()
        v.text = "ID:24367278"
        v.font = .systemFont(ofSize: 12)
        v.textColor = UIColor(hex: "#999999")
        return v
    }()

    private let signatureLabel: UILabel = {
        let v = UILabel()
        v.text = "Personal signature~"
        v.font = .systemFont(ofSize: 12)
        v.textColor = .black
        return v
    }()

    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()

    private let gemCardView: UIImageView = {
        let v = UIImageView(image: "profile_gemBg".toImage)
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()

    private let gemsTitleLabel: UILabel = {
        let v = UILabel()
        v.text = "My gems"
        v.font = .systemFont(ofSize: 14)
        v.textColor = .black
        return v
    }()

    private let gemsCountLabel: UILabel = {
        let v = UILabel()
        v.text = "9999"
        v.font = .systemFont(ofSize: 20)
        v.textColor = .black
        return v
    }()

    private let postsTitleLabel: UILabel = {
        let v = UILabel()
        v.text = "My posts(67)"
        v.font = .systemFont(ofSize: 14)
        v.textColor = .white
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(settingsButton)
        addSubview(userCardView)
        addSubview(gemCardView)
        addSubview(postsTitleLabel)

        userCardView.addSubview(avatarView)
        userCardView.addSubview(editButton)
        userCardView.addSubview(nameLabel)
        userCardView.addSubview(idLabel)
        userCardView.addSubview(signatureLabel)
        userCardView.addSubview(statsStack)

        statsStack.addArrangedSubview(makeStatItem(value: "999", title: "Following"))
        statsStack.addArrangedSubview(makeStatItem(value: "999", title: "Followers"))
        statsStack.addArrangedSubview(makeStatItem(value: "999", title: "Friends"))

        gemCardView.addSubview(gemsTitleLabel)
        gemCardView.addSubview(gemsCountLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }

        settingsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(118)
            make.height.equalTo(36)
        }

        userCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(settingsButton.snp.bottom).offset(16)
            make.height.equalTo(194)
        }

        avatarView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
            make.width.height.equalTo(96)
        }

        editButton.snp.makeConstraints { make in
            make.bottom.equalTo(avatarView)
            make.right.equalTo(avatarView).offset(-6)
            make.width.height.equalTo(26)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalTo(avatarView).offset(9)
            make.right.lessThanOrEqualToSuperview().offset(-12)
            make.height.equalTo(25)
        }

        idLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.height.equalTo(15)
        }

        signatureLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(idLabel.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        statsStack.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-12)
        }

        gemCardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(userCardView.snp.bottom).offset(20)
            make.height.equalTo(95)
        }

        gemsTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(22)
        }

        gemsCountLabel.snp.makeConstraints { make in
            make.left.equalTo(gemsTitleLabel)
            make.top.equalTo(gemsTitleLabel.snp.bottom).offset(5)
        }

        postsTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(gemCardView.snp.bottom).offset(24)
        }
    }

    private func makeStatItem(value: String, title: String) -> UIStackView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = UIColor(hex: "#4A3F35")
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(hex: "#4A3F35").withAlphaComponent(0.55)
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }

    @objc private func settingsTapped() {
        onSettingsTapped?()
    }

    @objc private func editTapped() {
        onEditAvatarTapped?()
    }
}
