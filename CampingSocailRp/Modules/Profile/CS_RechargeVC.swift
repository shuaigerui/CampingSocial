//
//  CS_RechargeVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import SVProgressHUD
import Toast_Swift
import UIKit

class CS_RechargeVC: CS_BaseVC {

    private enum Layout {
        static let columnCount = 3
        static let itemSpacing: CGFloat = 12
        static let sectionInset: CGFloat = 16
        static let gemCardHeight: CGFloat = 95
    }

    private let packages = CS_RechargePackage.catalog
    private var storePrices: [String: String] = [:]
    private var isPurchasing = false

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let gemCardView: UIImageView = {
        let v = UIImageView(image: "profile_gemBg".toImage)
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 16
        return v
    }()

    private let gemsTitleLabel: UILabel = {
        let v = UILabel()
        v.text = "My gems"
        v.font = .systemFont(ofSize: 14)
        v.textColor = .black
        return v
    }()

    private let gemsCountLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 20, weight: .bold)
        v.textColor = .black
        return v
    }()

    private let hintLabel: UILabel = {
        let v = UILabel()
        v.text = "*Use gems to unlock posting features and chat with AI."
        v.font = .systemFont(ofSize: 11)
        v.textColor = UIColor(hex: "#4A3F35").withAlphaComponent(0.75)
        v.numberOfLines = 0
        return v
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Layout.itemSpacing
        layout.minimumInteritemSpacing = Layout.itemSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Layout.sectionInset,
            bottom: Layout.sectionInset,
            right: Layout.sectionInset
        )

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(
            CS_RechargePackageCell.self,
            forCellWithReuseIdentifier: CS_RechargePackageCell.reuseID
        )
        return cv
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
        refreshGemsCount()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(false)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshGemsCount()
        loadStoreProducts()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(gemCardView)
        gemCardView.addSubview(gemsTitleLabel)
        gemCardView.addSubview(gemsCountLabel)
        view.addSubview(hintLabel)
        view.addSubview(collectionView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        gemCardView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(Layout.gemCardHeight)
        }

        gemsTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(22)
        }

        gemsCountLabel.snp.makeConstraints { make in
            make.left.equalTo(gemsTitleLabel)
            make.top.equalTo(gemsTitleLabel.snp.bottom).offset(5)
        }

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(gemCardView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(hintLabel.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private func refreshGemsCount() {
        gemsCountLabel.text = formatGems(CS_CurrentUser.shared.user?.gemsCount ?? 0)
    }

    private func formatGems(_ count: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }

    private func loadStoreProducts() {
        Task {
            let products = await CS_IAPManager.shared.loadProducts()
            var prices: [String: String] = [:]
            for product in products {
                prices[product.id] = product.displayPrice
            }
            storePrices = prices
            collectionView.reloadData()
        }
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    private func purchase(package: CS_RechargePackage) {
        guard !isPurchasing else { return }
        isPurchasing = true
        SVProgressHUD.show()

        Task {
            defer {
                Task { @MainActor in
                    isPurchasing = false
                    SVProgressHUD.dismiss()
                }
            }

            do {
                try await CS_IAPManager.shared.purchase(package: package)
                await MainActor.run {
                    refreshGemsCount()
                    view.makeToast("+\(formatGems(package.gems)) gems added")
                }
            } catch CS_IAPError.userCancelled {
                break
            } catch {
                await MainActor.run {
                    let message = (error as? LocalizedError)?.errorDescription
                        ?? error.localizedDescription
                    if !message.isEmpty {
                        view.makeToast(message)
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionView

extension CS_RechargeVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        packages.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CS_RechargePackageCell.reuseID,
            for: indexPath
        ) as? CS_RechargePackageCell else {
            return UICollectionViewCell()
        }
        let package = packages[indexPath.item]
        let price = storePrices[package.productId] ?? package.displayPrice
        cell.configure(with: package, priceText: price)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        purchase(package: packages[indexPath.item])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let inset = Layout.sectionInset * 2
        let spacing = Layout.itemSpacing * CGFloat(Layout.columnCount - 1)
        let width = (collectionView.bounds.width - inset - spacing) / CGFloat(Layout.columnCount)
        return CGSize(width: floor(width), height: floor(width * 1.15))
    }
}
