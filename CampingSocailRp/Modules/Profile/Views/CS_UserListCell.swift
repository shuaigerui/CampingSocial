//
//  CS_UserListCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import UIKit

final class CS_UserListCell: UITableViewCell {

    static let reuseID = "CS_UserListCell"

    var onActionTapped: (() -> Void)?

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#C8E6A0").withAlphaComponent(0.88)
        v.layer.cornerRadius = 18
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

    private let nameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 16, weight: .semibold)
        v.textColor = UIColor(hex: "#2D2D2D")
        return v
    }()

    private lazy var imageActionButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var textActionButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(UIColor(hex: "#2D2D2D"), for: .normal)
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        btn.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        btn.isHidden = true
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
        cardView.addSubview(nameLabel)
        cardView.addSubview(imageActionButton)
        cardView.addSubview(textActionButton)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            )
        }

        avatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }

        imageActionButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.equalTo(88)
            make.height.equalTo(36)
        }

        textActionButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(imageActionButton.snp.left).offset(-8)
        }
    }

    func configure(user: UserModel, actionStyle: CS_UserListActionStyle) {
        nameLabel.text = user.userName
        if let path = user.avatarURL, !path.isEmpty {
            avatarView.image = path.resourceFileImage ?? path.toImage
            avatarView.backgroundColor = avatarView.image == nil
                ? UIColor(hex: "#D4C4A8") : .clear
        } else {
            avatarView.image = "info_avatar".toImage
            avatarView.backgroundColor = .clear
        }

        switch actionStyle {
        case .image(let name):
            imageActionButton.isHidden = false
            textActionButton.isHidden = true
            imageActionButton.setImage(name.toImage, for: .normal)
            nameLabel.snp.remakeConstraints { make in
                make.left.equalTo(avatarView.snp.right).offset(12)
                make.centerY.equalToSuperview()
                make.right.lessThanOrEqualTo(imageActionButton.snp.left).offset(-8)
            }
        case .text(let title, let color):
            imageActionButton.isHidden = true
            textActionButton.isHidden = false
            textActionButton.setTitle(title, for: .normal)
            textActionButton.backgroundColor = color
            nameLabel.snp.remakeConstraints { make in
                make.left.equalTo(avatarView.snp.right).offset(12)
                make.centerY.equalToSuperview()
                make.right.lessThanOrEqualTo(textActionButton.snp.left).offset(-8)
            }
        }
    }

    @objc private func actionTapped() {
        onActionTapped?()
    }
}
