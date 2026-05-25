//
//  CS_PostDetailImageCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

final class CS_PostDetailImageCell: UICollectionViewCell {

    static let reuseID = "CS_PostDetailImageCell"

    private let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(image: UIImage?) {
        imageView.image = image
        imageView.backgroundColor = image == nil ? UIColor(hex: "#D4C4A8") : .clear
    }

    func configure(backgroundColor: UIColor) {
        imageView.image = nil
        imageView.backgroundColor = backgroundColor
    }
}
