//
//  CS_DiscoverFeedCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

final class CS_DiscoverFeedCell: UITableViewCell {

    static let reuseID = "CS_DiscoverFeedCell"

    var onFollowTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    var onCollectTapped: (() -> Void)?
    var onReportTapped: (() -> Void)?
    var onPlayTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onAvatarTapped: (() -> Void)?

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#E9EDC8")
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let coverImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor(hex: "#C5D4B0")
        return v
    }()

    private lazy var playButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("discover_play".toImage, for: .normal)
        btn.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var followButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var reportButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("home_report".toImage, for: .normal)
        btn.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var deleteButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("profile_del".toImage, for: .normal)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        return btn
    }()

    private let contentLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = UIColor(hex: "#4A3F35")
        v.numberOfLines = 0
        return v
    }()

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        return v
    }()

    private let userNameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13, weight: .bold)
        v.textColor = UIColor(hex: "#4A3F35")
        return v
    }()

    private lazy var likeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        return btn
    }()

    private let likeCountLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13, weight: .medium)
        v.textColor = UIColor(hex: "#4A3F35")
        return v
    }()

    private lazy var collectButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(collectTapped), for: .touchUpInside)
        return btn
    }()

    private let bottomActionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()

    private var coverLoadVideoPath: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverLoadVideoPath = nil
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarView.addGestureRecognizer(avatarTap)

        contentView.addSubview(cardView)
        cardView.addSubview(coverImageView)
        cardView.addSubview(playButton)
        cardView.addSubview(followButton)
        cardView.addSubview(reportButton)
        cardView.addSubview(deleteButton)
        cardView.addSubview(contentLabel)
        cardView.addSubview(avatarView)
        cardView.addSubview(userNameLabel)
        cardView.addSubview(bottomActionStack)

        let likeWrap = UIStackView(arrangedSubviews: [likeButton, likeCountLabel])
        likeWrap.axis = .horizontal
        likeWrap.spacing = 4
        likeWrap.alignment = .center
        bottomActionStack.addArrangedSubview(likeWrap)
        bottomActionStack.addArrangedSubview(collectButton)

        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        coverImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(220)
        }

        playButton.snp.makeConstraints { make in
            make.top.left.equalTo(coverImageView).offset(12)
            make.width.height.equalTo(40)
        }

        reportButton.snp.makeConstraints { make in
            make.top.equalTo(coverImageView).offset(12)
            make.right.equalTo(coverImageView).offset(-12)
            make.width.height.equalTo(20)
        }

        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(coverImageView).offset(12)
            make.right.equalTo(coverImageView).offset(-12)
            make.width.height.equalTo(24)
        }

        followButton.snp.makeConstraints { make in
            make.centerY.equalTo(reportButton)
            make.right.equalTo(reportButton.snp.left).offset(-8)
            make.width.equalTo(70)
            make.height.equalTo(27)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
        }

        avatarView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-12)
        }

        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.left.equalTo(avatarView.snp.right).offset(8)
        }

        bottomActionStack.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.right.equalToSuperview().offset(-12)
        }

        likeButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }

        collectButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }

    func configure(
        with item: CS_DiscoverFeedItem,
        showsDelete: Bool = false,
        showsFollowButton: Bool = true
    ) {
        coverLoadVideoPath = item.videoPath
        if let coverPath = item.coverImagePath,
           !coverPath.isEmpty,
           let image = coverPath.resourceFileImage {
            coverImageView.image = image
            coverImageView.backgroundColor = .clear
        } else if let videoPath = item.videoPath, !videoPath.isEmpty {
            coverImageView.image = nil
            coverImageView.backgroundColor = UIColor(hex: "#C5D4B0")
            if let cached = CS_VideoThumbnail.cachedImage(forVideoPath: videoPath) {
                coverImageView.image = cached
                coverImageView.backgroundColor = .clear
            } else {
                CS_VideoThumbnail.loadFirstFrame(forVideoPath: videoPath) { [weak self] image in
                    guard let self, self.coverLoadVideoPath == videoPath else { return }
                    self.coverImageView.image = image
                    coverImageView.backgroundColor = image == nil
                        ? UIColor(hex: "#C5D4B0") : .clear
                }
            }
        } else if let path = item.coverImagePath,
                  let image = path.resourceFileImage ?? path.toImage {
            coverImageView.image = image
            coverImageView.backgroundColor = .clear
        } else {
            coverImageView.image = item.coverImageName.toImage
            coverImageView.backgroundColor = .clear
        }
        contentLabel.text = item.content
        userNameLabel.text = item.userName.uppercased()
        let isOwnPost = showsDelete
        followButton.isHidden = isOwnPost || !showsFollowButton
        if showsFollowButton, !isOwnPost {
            updateFollowButton(isFollowing: item.isFollowing)
        }
        likeCountLabel.text = "\(item.likeCount)"
        updateLikeButton(isLiked: item.isLiked)
        updateCollectButton(isCollected: item.isCollected)
        setShowsDeleteButton(showsDelete, showsFollowButton: showsFollowButton && !isOwnPost)

        if let avatarPath = item.avatarPath, !avatarPath.isEmpty {
            avatarView.image = avatarPath.resourceFileImage ?? avatarPath.toImage
            avatarView.backgroundColor = avatarView.image == nil
                ? UIColor(hex: "#D4C4A8") : .clear
        } else {
            avatarView.image = "info_avatar".toImage
            avatarView.backgroundColor = avatarView.image == nil
                ? UIColor(hex: "#D4C4A8") : .clear
        }
    }

    private func setShowsDeleteButton(_ shows: Bool, showsFollowButton: Bool = true) {
        reportButton.isHidden = shows
        deleteButton.isHidden = !shows
        guard showsFollowButton else { return }
        followButton.snp.remakeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(27)
            if shows {
                make.centerY.equalTo(deleteButton)
                make.right.equalTo(deleteButton.snp.left).offset(-8)
            } else {
                make.centerY.equalTo(reportButton)
                make.right.equalTo(reportButton.snp.left).offset(-8)
            }
        }
    }

    private func updateFollowButton(isFollowing: Bool) {
        let name = isFollowing ? "home_following" : "home_follow"
        followButton.setImage(name.toImage, for: .normal)
    }

    private func updateLikeButton(isLiked: Bool) {
        let name = isLiked ? "home_liked" : "home_like"
        likeButton.setImage(name.toImage, for: .normal)
    }

    private func updateCollectButton(isCollected: Bool) {
        let name = isCollected ? "home_collected" : "home_collect"
        collectButton.setImage(name.toImage, for: .normal)
    }

    @objc private func avatarTapped() { onAvatarTapped?() }
    @objc private func followTapped() { onFollowTapped?() }
    @objc private func likeTapped() { onLikeTapped?() }
    @objc private func collectTapped() { onCollectTapped?() }
    @objc private func reportTapped() { onReportTapped?() }
    @objc private func playTapped() { onPlayTapped?() }
    @objc private func deleteTapped() { onDeleteTapped?() }
}
