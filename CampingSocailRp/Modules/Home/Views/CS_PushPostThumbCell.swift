//
//  CS_PushPostThumbCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

final class CS_PushPostThumbCell: UICollectionViewCell {

    static let reuseID = "CS_PushPostThumbCell"

    var onDeleteTapped: (() -> Void)?

    private let thumbView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 12
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        return v
    }()

    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("push_del".toImage, for: .normal)
        btn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbView)
        contentView.addSubview(deleteButton)

        thumbView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        deleteButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage) {
        thumbView.image = image
    }

    @objc private func deleteTapped() {
        onDeleteTapped?()
    }
}
