//
//  CS_LiveChatCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/26.
//

import UIKit

final class CS_LiveChatCell: UITableViewCell {

    static let reuseID = "CS_LiveChatCell"

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()

    private let messageLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-48)
            make.top.bottom.equalToSuperview().inset(3)
        }
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }

    func configure(with message: CS_LiveChatMessage) {
        let attr = NSMutableAttributedString(
            string: message.userName,
            attributes: [
                .foregroundColor: UIColor(hex: "#E9DC8A"),
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
            ]
        )
        attr.append(NSAttributedString(
            string: ": \(message.text)",
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 13)
            ]
        ))
        messageLabel.attributedText = attr
    }
}
