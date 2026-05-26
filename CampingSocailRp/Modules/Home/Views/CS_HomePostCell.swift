//
//  CS_HomePostCell.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

final class CS_HomePostCell: UITableViewCell {

    static let reuseID = "CS_HomePostCell"

    private enum Layout {
        static let imageRowHeight: CGFloat = 105
        static let visibleImageCount: CGFloat = 3
        static let imageSpacing: CGFloat = 8
    }

    var onFollowTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    var onCollectTapped: (() -> Void)?
    var onReportTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onAvatarTapped: (() -> Void)?

    private var imagePaths: [String] = []
    private var placeholderColors: [UIColor] = []

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#E9DC8A")
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private let avatarView: UIImageView = {
        let v = UIImageView()
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
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
        btn.clipsToBounds = true
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        return btn
    }()

    private let reportContainer: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = true
        return v
    }()

    private let reportImageView: UIImageView = {
        let v = UIImageView(image: UIImage(named: "home_report"))
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
    }()

    private let headerActionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
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

    private lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Layout.imageSpacing
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(CS_HomePostImageCell.self, forCellWithReuseIdentifier: CS_HomePostImageCell.reuseID)
        return cv
    }()

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

    override func prepareForReuse() {
        super.prepareForReuse()
        imagePaths = []
        placeholderColors = []
        reportContainer.isHidden = false
        deleteButton.isHidden = true
        imagesCollectionView.setContentOffset(.zero, animated: false)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let reportTap = UITapGestureRecognizer(target: self, action: #selector(reportTapped))
        reportContainer.addGestureRecognizer(reportTap)

        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarView.addGestureRecognizer(avatarTap)

        reportContainer.addSubview(reportImageView)

        contentView.addSubview(cardView)
        cardView.addSubview(avatarView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(timeLabel)
        headerActionsStack.addArrangedSubview(followButton)
        headerActionsStack.addArrangedSubview(reportContainer)
        headerActionsStack.addArrangedSubview(deleteButton)
        cardView.addSubview(headerActionsStack)
        cardView.addSubview(contentLabel)
        cardView.addSubview(imagesCollectionView)
        cardView.addSubview(actionStack)

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
            make.right.lessThanOrEqualTo(headerActionsStack.snp.left).offset(-8)
        }

        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }

        headerActionsStack.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.right.equalToSuperview().offset(-12)
        }

        followButton.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(27)
        }

        reportContainer.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }

        reportImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        deleteButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }

        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
        }

        imagesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(Layout.imageRowHeight)
        }

        actionStack.snp.makeConstraints { make in
            make.top.equalTo(imagesCollectionView.snp.bottom).offset(12)
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

    func configure(
        with post: CS_HomePost,
        showsDelete: Bool = false,
        showsFollowButton: Bool = true
    ) {
        nameLabel.text = post.userName
        timeLabel.text = post.time
        contentLabel.text = post.content
        likeCountLabel.text = "\(post.likeCount)"
        commentCountLabel.text = "\(post.commentCount)"
        let isOwnPost = showsDelete
        followButton.isHidden = isOwnPost || !showsFollowButton
        if showsFollowButton, !isOwnPost {
            updateFollowButton(isFollowing: post.isFollowing)
        }
        updateLikeButton(isLiked: post.isLiked)
        updateCollectButton(isCollected: post.isCollected)

        if let avatarPath = post.avatarPath {
            avatarView.image = avatarPath.resourceFileImage
            avatarView.backgroundColor = avatarView.image == nil
                ? UIColor(hex: "#D4C4A8") : .clear
        } else {
            avatarView.image = nil
            avatarView.backgroundColor = UIColor(hex: "#D4C4A8")
        }

        imagePaths = post.imagePaths
        placeholderColors = post.imageColors
        imagesCollectionView.reloadData()
        imagesCollectionView.showsHorizontalScrollIndicator = imagePaths.count > 3
        imagesCollectionView.isScrollEnabled = imagePaths.count > Int(Layout.visibleImageCount)

        setShowsDeleteButton(showsDelete)
        cardView.bringSubviewToFront(headerActionsStack)
    }

    private func setShowsDeleteButton(_ shows: Bool) {
        reportContainer.isHidden = shows
        deleteButton.isHidden = !shows
    }

    private func imageItemSize(for collectionView: UICollectionView) -> CGSize {
        let count = max(CGFloat(max(imagePaths.count, placeholderColors.count)), 1)
        let visible = min(Layout.visibleImageCount, count)
        let spacing = Layout.imageSpacing * max(visible - 1, 0)
        let width = (collectionView.bounds.width - spacing) / visible
        return CGSize(width: max(width, 80), height: Layout.imageRowHeight)
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

    @objc private func avatarTapped() { onAvatarTapped?() }
    @objc private func followTapped() { onFollowTapped?() }
    @objc private func likeTapped() { onLikeTapped?() }
    @objc private func collectTapped() { onCollectTapped?() }
    @objc private func reportTapped() { onReportTapped?() }
    @objc private func deleteTapped() { onDeleteTapped?() }
    @objc private func commentTapped() {}
}

// MARK: - Images Collection

extension CS_HomePostCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !imagePaths.isEmpty { return imagePaths.count }
        return placeholderColors.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CS_HomePostImageCell.reuseID,
            for: indexPath
        ) as? CS_HomePostImageCell else {
            return UICollectionViewCell()
        }

        if !imagePaths.isEmpty {
            cell.configure(path: imagePaths[indexPath.item])
        } else {
            let color = placeholderColors.indices.contains(indexPath.item)
                ? placeholderColors[indexPath.item]
                : UIColor(hex: "#E8DFC8")
            cell.configure(color: color)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        imageItemSize(for: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 可在此跳转详情
    }
}
