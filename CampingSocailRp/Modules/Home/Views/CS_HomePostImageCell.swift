//
//  CS_HomePostImageCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

final class CS_HomePostImageCell: UICollectionViewCell {

    static let reuseID = "CS_HomePostImageCell"

    private let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 10
        v.backgroundColor = UIColor(hex: "#E8DFC8")
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

    func configure(path: String) {
        imageView.image = path.resourceFileImage
        imageView.backgroundColor = imageView.image == nil
            ? UIColor(hex: "#E8DFC8") : .clear
    }

    func configure(color: UIColor) {
        imageView.image = nil
        imageView.backgroundColor = color
    }
}
