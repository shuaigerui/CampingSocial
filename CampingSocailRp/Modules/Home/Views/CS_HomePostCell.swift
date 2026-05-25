//
//  CS_HomePostCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

final class CS_HomePostCell: UITableViewCell {

    static let reuseID = "CS_HomePostCell"

    var onFollowTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    var onCollectTapped: (() -> Void)?
    var onReportTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F9F1C1")
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        return v
    }()

    private let nameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 15, weight: .semibold)
        v.textColor = UIColor(hex: "#4A3F35")
        return v
    }()

    private let timeLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 12)
        v.textColor = UIColor(hex: "#4A3F35").withAlphaComponent(0.6)
        return v
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

    private let imagesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private var imageViews: [UIImageView] = []

    private lazy var likeButton = makeActionButton(action: #selector(likeTapped))
    private lazy var commentButton: UIButton = {
        let btn = makeActionButton(action: #selector(commentTapped))
        btn.setImage("home_commit".toImage, for: .normal)
        return btn
    }()
    private lazy var collectButton = makeActionButton(action: #selector(collectTapped))

    private let likeCountLabel = makeCountLabel()
    private let commentCountLabel = makeCountLabel()

    private let actionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(timeLabel)
        cardView.addSubview(followButton)
        cardView.addSubview(reportButton)
        cardView.addSubview(deleteButton)
        cardView.addSubview(contentLabel)
        cardView.addSubview(imagesStack)
        cardView.addSubview(actionStack)

        for _ in 0..<3 {
            let iv = UIImageView()
            iv.backgroundColor = UIColor(hex: "#E8DFC8")
            iv.layer.cornerRadius = 10
            iv.clipsToBounds = true
            iv.contentMode = .scaleAspectFill
            imagesStack.addArrangedSubview(iv)
            imageViews.append(iv)
        }

        let likeWrap = makeActionWrap(button: likeButton, label: likeCountLabel)
        let commentWrap = makeActionWrap(button: commentButton, label: commentCountLabel)
        let collectWrap = makeActionWrap(button: collectButton, label: UILabel())
        actionStack.addArrangedSubview(likeWrap)
        actionStack.addArrangedSubview(commentWrap)
        actionStack.addArrangedSubview(collectWrap)
        actionStack.addArrangedSubview(UIView())

        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        avatarView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
            make.width.height.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalTo(avatarView).offset(2)
            make.right.lessThanOrEqualTo(followButton.snp.left).offset(-8)
        }

        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }

        reportButton.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(20)
        }

        deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(24)
        }

        followButton.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.right.equalTo(reportButton.snp.left).offset(-8)
            make.width.equalTo(70)
            make.height.equalTo(27)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
        }

        imagesStack.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(105)
        }

        actionStack.snp.makeConstraints { make in
            make.top.equalTo(imagesStack.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.lessThanOrEqualToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }

        [likeButton, commentButton, collectButton].forEach { btn in
            btn.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }
        }
    }

    func configure(with post: CS_HomePost, showsDelete: Bool = false) {
        nameLabel.text = post.userName
        timeLabel.text = post.time
        contentLabel.text = post.content
        likeCountLabel.text = "\(post.likeCount)"
        commentCountLabel.text = "\(post.commentCount)"
        updateFollowButton(isFollowing: post.isFollowing)
        updateLikeButton(isLiked: post.isLiked)
        updateCollectButton(isCollected: post.isCollected)
        zip(imageViews, post.imageColors).forEach { iv, color in
            iv.image = nil
            iv.backgroundColor = color
        }
        setShowsDeleteButton(showsDelete)
    }

    private func setShowsDeleteButton(_ shows: Bool) {
        reportButton.isHidden = shows
        deleteButton.isHidden = !shows
        followButton.snp.remakeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.width.equalTo(70)
            make.height.equalTo(27)
            if shows {
                make.right.equalTo(deleteButton.snp.left).offset(-8)
            } else {
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

    private static func makeCountLabel() -> UILabel {
        let v = UILabel()
        v.font = .systemFont(ofSize: 13, weight: .medium)
        v.textColor = UIColor(hex: "#4A3F35")
        return v
    }

    private func makeActionButton(action: Selector) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    private func makeActionWrap(button: UIButton, label: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [button, label])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }

    @objc private func followTapped() { onFollowTapped?() }
    @objc private func likeTapped() { onLikeTapped?() }
    @objc private func collectTapped() { onCollectTapped?() }
    @objc private func reportTapped() { onReportTapped?() }
    @objc private func deleteTapped() { onDeleteTapped?() }
    @objc private func commentTapped() {}
}
