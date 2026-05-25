//
//  CS_PostDetailCommentCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

final class CS_PostDetailCommentCell: UITableViewCell {

    static let reuseID = "CS_PostDetailCommentCell"

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#FFF6D6")
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        return v
    }()

    private let contentLabel: UILabel = {
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

        contentView.addSubview(cardView)
        cardView.addSubview(avatarView)
        cardView.addSubview(contentLabel)

        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }

        avatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(36)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }

        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    func configure(with comment: CS_PostComment) {
        contentLabel.text = comment.content
        if let name = comment.avatarImageName, let image = name.toImage {
            avatarView.image = image
            avatarView.backgroundColor = .clear
        } else {
            avatarView.image = nil
            avatarView.backgroundColor = UIColor(hex: "#D4C4A8")
        }
    }
}
