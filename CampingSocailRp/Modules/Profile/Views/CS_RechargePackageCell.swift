//
//  CS_RechargePackageCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

struct CS_RechargePackage {
    let gems: Int
    let price: String
}

final class CS_RechargePackageCell: UICollectionViewCell {

    static let reuseID = "CS_RechargePackageCell"

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F5F0DC")
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let diamondView: UIImageView = {
        let v = UIImageView(image: "profile_diamond".toImage)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let gemsLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 16, weight: .semibold)
        v.textColor = UIColor(hex: "#4A3F35")
        v.textAlignment = .center
        return v
    }()

    private let priceContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#E6E2D0")
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    private let priceLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13, weight: .medium)
        v.textColor = UIColor(hex: "#666666")
        v.textAlignment = .center
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
        contentView.addSubview(cardView)
        cardView.addSubview(diamondView)
        cardView.addSubview(gemsLabel)
        cardView.addSubview(priceContainer)
        priceContainer.addSubview(priceLabel)

        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        diamondView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(35)
        }

        gemsLabel.snp.makeConstraints { make in
            make.top.equalTo(diamondView.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }

        priceContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(28)
        }

        priceLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func configure(with package: CS_RechargePackage) {
        gemsLabel.text = "\(package.gems)"
        priceLabel.text = package.price
    }
}
