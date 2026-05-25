//
//  CS_AIChatMessageCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

final class CS_AIChatMessageCell: UITableViewCell {

    static let reuseID = "CS_AIChatMessageCell"

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 22
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        return v
    }()

    private let bubbleView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let messageLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = UIColor(hex: "#4A3F35")
        v.numberOfLines = 0
        return v
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

        contentView.addSubview(avatarView)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
            )
        }

        avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }

        bubbleView.snp.makeConstraints { make in
            make.top.equalTo(avatarView)
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
        }
    }

    func configure(with message: CS_AIChatMessage) {
        messageLabel.text = message.text

        avatarView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
            if message.sender == .ai {
                make.leading.equalToSuperview().offset(16)
            } else {
                make.trailing.equalToSuperview().offset(-16)
            }
        }

        bubbleView.snp.remakeConstraints { make in
            make.top.equalTo(avatarView)
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
            if message.sender == .ai {
                make.leading.equalTo(avatarView.snp.trailing).offset(8)
                make.trailing.lessThanOrEqualToSuperview().offset(-48)
            } else {
                make.trailing.equalTo(avatarView.snp.leading).offset(-8)
                make.leading.greaterThanOrEqualToSuperview().offset(48)
            }
        }

        switch message.sender {
        case .ai:
            avatarView.image = "ai_icon".toImage
            avatarView.backgroundColor = .clear
            bubbleView.backgroundColor = .white

        case .user:
            if let path = CS_CurrentUser.shared.user?.avatarURL, !path.isEmpty {
                avatarView.image = path.resourceFileImage ?? path.toImage
                avatarView.backgroundColor = avatarView.image == nil
                    ? UIColor(hex: "#D4C4A8") : .clear
            } else {
                avatarView.image = "info_avatar".toImage
                avatarView.backgroundColor = .clear
            }
            bubbleView.backgroundColor = UIColor(hex: "#E9DC8A")
        }
    }
}
