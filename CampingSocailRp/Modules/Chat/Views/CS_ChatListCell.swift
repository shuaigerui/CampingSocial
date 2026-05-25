//
//  CS_ChatListCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

final class CS_ChatListCell: UITableViewCell {

    static let reuseID = "CS_ChatListCell"

    var onVideoTapped: (() -> Void)?

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F3EFBB")
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        return v
    }()

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 26
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        return v
    }()

    private let badgeLabel: UILabel = {
        let v = UILabel()
        v.backgroundColor = UIColor(hex: "#E85D4A")
        v.textColor = .white
        v.font = .systemFont(ofSize: 11, weight: .bold)
        v.textAlignment = .center
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        v.isHidden = true
        return v
    }()

    private let nameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 16, weight: .bold)
        v.textColor = UIColor(hex: "#4A3F35")
        return v
    }()

    private let timeLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 11)
        v.textColor = UIColor(hex: "#8FA67E")
        return v
    }()

    private let previewLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13)
        v.textColor = UIColor(hex: "#8FA67E")
        v.numberOfLines = 1
        return v
    }()

    private lazy var videoButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("chat_video".toImage, for: .normal)
        btn.addTarget(self, action: #selector(videoTapped), for: .touchUpInside)
        return btn
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarView)
        cardView.addSubview(badgeLabel)
        cardView.addSubview(nameLabel)
        cardView.addSubview(timeLabel)
        cardView.addSubview(previewLabel)
        cardView.addSubview(videoButton)

        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.height.equalTo(76)
        }

        avatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }

        badgeLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView).offset(-2)
            make.left.equalTo(avatarView).offset(-2)
            make.width.height.equalTo(20)
        }

        videoButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalTo(avatarView).offset(6)
            make.right.lessThanOrEqualTo(timeLabel.snp.left).offset(-8)
        }

        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.right.equalTo(videoButton.snp.left).offset(-8)
        }

        previewLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.right.equalTo(videoButton.snp.left).offset(-8)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    func configure(with item: CS_ChatConversation) {
        nameLabel.text = item.userName
        previewLabel.text = item.preview
        timeLabel.text = item.timeText

        if item.unreadCount > 0 {
            badgeLabel.isHidden = false
            badgeLabel.text = item.unreadCount > 99 ? "99+" : "\(item.unreadCount)"
        } else {
            badgeLabel.isHidden = true
        }

        if let path = item.avatarURL, !path.isEmpty {
            avatarView.image = path.resourceFileImage ?? path.toImage
            avatarView.backgroundColor = avatarView.image == nil
                ? UIColor(hex: "#D4C4A8") : .clear
        } else {
            avatarView.image = "info_avatar".toImage
            avatarView.backgroundColor = .clear
        }
    }

    @objc private func videoTapped() {
        onVideoTapped?()
    }
}
