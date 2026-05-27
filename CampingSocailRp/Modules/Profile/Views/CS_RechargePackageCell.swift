//
//  CS_RechargePackageCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

struct CS_RechargePackage: Equatable {
    /// App Store 商品 ID（批次号）
    let productId: String
    let gems: Int
    /// 配置表展示价（未拉取到 StoreKit 价格时使用）
    let displayPrice: String

    var price: String { displayPrice }

    /// 充值档位（与 App Store Connect 商品 ID 一致）
    static let catalog: [CS_RechargePackage] = [
        CS_RechargePackage(productId: "ujpruorrlkbqffzn", gems: 63_700, displayPrice: "$99.99"),
        CS_RechargePackage(productId: "zzcjkacefpbiibug", gems: 29_400, displayPrice: "$49.99"),
        CS_RechargePackage(productId: "hrzfuikywexdnuxk", gems: 10_800, displayPrice: "$19.99"),
        CS_RechargePackage(productId: "woqhjfsmlmeyjqov", gems: 5_150, displayPrice: "$9.99"),
        CS_RechargePackage(productId: "lyekhqwnlnxjwaet", gems: 2_450, displayPrice: "$4.99"),
        CS_RechargePackage(productId: "jcnxubmhvhgnhtyw", gems: 800, displayPrice: "$1.99"),
        CS_RechargePackage(productId: "qjubzksscotwhmqr", gems: 400, displayPrice: "$0.99")
    ]

    static func package(productId: String) -> CS_RechargePackage? {
        catalog.first { $0.productId == productId }
    }

    static var productIds: [String] {
        catalog.map(\.productId)
    }
}

final class CS_RechargePackageCell: UICollectionViewCell {

    static let reuseID = "CS_RechargePackageCell"

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white.withAlphaComponent(0.3)
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
        v.backgroundColor = .white.withAlphaComponent(0.5)
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

    func configure(with package: CS_RechargePackage, priceText: String? = nil) {
        gemsLabel.text = Self.formatGems(package.gems)
        priceLabel.text = priceText ?? package.displayPrice
    }

    private static func formatGems(_ count: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }
}
