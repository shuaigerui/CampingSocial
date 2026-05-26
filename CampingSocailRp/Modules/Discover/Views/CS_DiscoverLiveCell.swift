//
//  CS_DiscoverLiveCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

final class CS_DiscoverLiveCell: UICollectionViewCell {

    static let reuseID = "CS_DiscoverLiveCell"

    private var coverVideoPath: String?

    private let coverImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 16
        return v
    }()

    private let gradientView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let viewerBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.layer.cornerRadius = 12
        return v
    }()

    private let peopleIconView: UIImageView = {
        let v = UIImageView(image: "discover_people".toImage)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let viewerLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 12, weight: .semibold)
        v.textColor = .white
        return v
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13, weight: .semibold)
        v.textColor = .white
        v.numberOfLines = 2
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor
        ]
        gradient.locations = [0.4, 1.0]
        gradient.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradient, at: 0)
    }

    private func setupUI() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(viewerBadge)
        viewerBadge.addSubview(peopleIconView)
        viewerBadge.addSubview(viewerLabel)
        contentView.addSubview(titleLabel)

        coverImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        viewerBadge.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(10)
            make.height.equalTo(24)
        }

        peopleIconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        viewerLabel.snp.makeConstraints { make in
            make.left.equalTo(peopleIconView.snp.right).offset(4)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverVideoPath = nil
        coverImageView.image = nil
        coverImageView.backgroundColor = UIColor(hex: "#4A5A42")
    }

    func configure(with item: CS_DiscoverLiveItem) {
        coverVideoPath = item.videoPath
        viewerLabel.text = "\(item.viewerCount)"
        titleLabel.text = item.title

        if let cached = CS_VideoThumbnail.cachedImage(forVideoPath: item.videoPath) {
            coverImageView.image = cached
            coverImageView.backgroundColor = .clear
            return
        }

        coverImageView.image = nil
        coverImageView.backgroundColor = UIColor(hex: "#4A5A42")
        CS_VideoThumbnail.loadFirstFrame(forVideoPath: item.videoPath) { [weak self] image in
            guard let self, self.coverVideoPath == item.videoPath else { return }
            self.coverImageView.image = image
            self.coverImageView.backgroundColor = image == nil ? UIColor(hex: "#4A5A42") : .clear
        }
    }
}
