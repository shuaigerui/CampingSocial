//
//  CS_PersonHeaderView.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

/// 他人主页顶部：封面图 + 导航 + 资料卡 + Posts 标题条
final class CS_PersonHeaderView: UIView {

    static let preferredHeight: CGFloat = 688

    private enum Layout {
        static let coverHeight: CGFloat = 490
        static let cardOverlap: CGFloat = 30
        static let cardHeight: CGFloat = 180
        static let postsBarHeight: CGFloat = 48
    }

    var onBackTapped: (() -> Void)?
    var onFollowTapped: (() -> Void)?
    var onMoreTapped: (() -> Void)?
    var onChatTapped: (() -> Void)?

    private let coverImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor(hex: "#C5D4B0")
        return v
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var followButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var moreButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("person_more".toImage, for: .normal)
        btn.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        return btn
    }()

    private let userCardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#E9DD8A")
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        return v
    }()

    private let nameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 20, weight: .semibold)
        v.textColor = .black
        return v
    }()

    private let idLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 12)
        v.textColor = UIColor(hex: "#999999")
        return v
    }()

    private let signatureLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 12)
        v.textColor = .black
        v.numberOfLines = 2
        return v
    }()

    private lazy var chatButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("person_chat".toImage, for: .normal)
        btn.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        return btn
    }()

    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()

    private let postsBarView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let postsTitleLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14, weight: .semibold)
        v.textColor = .white
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
        clipsToBounds = true
        backgroundColor = .clear

        addSubview(coverImageView)
        addSubview(backButton)
        addSubview(followButton)
        addSubview(moreButton)
        addSubview(userCardView)
        addSubview(postsBarView)

        userCardView.addSubview(avatarView)
        userCardView.addSubview(nameLabel)
        userCardView.addSubview(idLabel)
        userCardView.addSubview(signatureLabel)
        userCardView.addSubview(chatButton)
        userCardView.addSubview(statsStack)

        postsBarView.addSubview(postsTitleLabel)

        coverImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(Layout.coverHeight)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }

        followButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.right.equalTo(moreButton.snp.left).offset(-8)
            make.width.equalTo(70)
            make.height.equalTo(27)
        }

        userCardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(coverImageView.snp.bottom).offset(-Layout.cardOverlap)
            make.height.equalTo(Layout.cardHeight)
        }

        avatarView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
            make.width.height.equalTo(80)
        }

        chatButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalTo(avatarView).offset(6)
            make.right.lessThanOrEqualTo(chatButton.snp.left).offset(-8)
        }

        idLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        signatureLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(idLabel.snp.bottom).offset(6)
            make.right.equalTo(chatButton.snp.left).offset(-8)
        }

        statsStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(40)
        }

        postsBarView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(userCardView.snp.bottom).offset(10)
            make.height.equalTo(Layout.postsBarHeight)
        }

        postsTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with user: UserModel, postCount: Int, isFollowing: Bool) {
        nameLabel.text = user.userName
        idLabel.text = user.displayID
        signatureLabel.text = user.signature
        postsTitleLabel.text = "Posts(\(postCount))"
        updateFollowButton(isFollowing: isFollowing)

        if let avatarPath = user.avatarURL, !avatarPath.isEmpty {
            let image = avatarPath.resourceFileImage ?? avatarPath.toImage
            avatarView.image = image
            coverImageView.image = image
            avatarView.backgroundColor = image == nil ? UIColor(hex: "#D4C4A8") : .clear
            coverImageView.backgroundColor = avatarView.backgroundColor
        } else {
            let fallback = "info_avatar".toImage
            avatarView.image = fallback
            coverImageView.image = fallback
            avatarView.backgroundColor = UIColor(hex: "#D4C4A8")
            coverImageView.backgroundColor = UIColor(hex: "#C5D4B0")
        }

        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        statsStack.addArrangedSubview(
            makeStatItem(value: "\(user.followingCount)", title: "Following")
        )
        statsStack.addArrangedSubview(
            makeStatItem(value: "\(user.followersCount)", title: "Followers")
        )
        statsStack.addArrangedSubview(
            makeStatItem(value: "\(user.friendsCount)", title: "Friends")
        )
    }

    private func updateFollowButton(isFollowing: Bool) {
        let name = isFollowing ? "home_following" : "home_follow"
        followButton.setImage(name.toImage, for: .normal)
    }

    private func makeStatItem(value: String, title: String) -> UIStackView {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = UIColor(hex: "#4A3F35")
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor(hex: "#4A3F35").withAlphaComponent(0.55)
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }

    @objc private func backTapped() { onBackTapped?() }
    @objc private func followTapped() { onFollowTapped?() }
    @objc private func moreTapped() { onMoreTapped?() }
    @objc private func chatTapped() { onChatTapped?() }
}
