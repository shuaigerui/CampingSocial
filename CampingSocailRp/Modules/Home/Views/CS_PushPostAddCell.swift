//
//  CS_PushPostAddCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

final class CS_PushPostAddCell: UICollectionViewCell {

    static let reuseID = "CS_PushPostAddCell"

    var onTapped: (() -> Void)?

    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("push_add".toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.backgroundColor = UIColor(hex: "#F3F7BB", alpha: 0.5)
        btn.layer.cornerRadius = 12
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func addTapped() {
        onTapped?()
    }
}
