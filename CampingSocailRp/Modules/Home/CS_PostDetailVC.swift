//
//  CS_PostDetailVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

class CS_PostDetailVC: CS_BaseVC {

    private enum Section: Int, CaseIterable {
        case post
        case comments
    }

    private let galleryView = CS_PostDetailGalleryView()
    private let inputBar = CS_PostDetailInputBar()

    private var postModel: PostModel
    private var post: CS_HomePost
    private var comments: [CS_PostComment]

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInsetAdjustmentBehavior = .never
        tv.keyboardDismissMode = .onDrag
        tv.dataSource = self
        tv.delegate = self
        tv.estimatedRowHeight = 120
        tv.rowHeight = UITableView.automaticDimension
        tv.register(CS_PostDetailPostCell.self, forCellReuseIdentifier: CS_PostDetailPostCell.reuseID)
        tv.register(CS_PostDetailCommentCell.self, forCellReuseIdentifier: CS_PostDetailCommentCell.reuseID)
        return tv
    }()

    init(postModel: PostModel) {
        self.postModel = postModel
        self.post = postModel.toDetailDisplayPost()
        self.comments = postModel.comments.map { $0.toPostComment() }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CS_TabBarVC)?.setCustomTabBarHidden(true)
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
        applyGalleryData()
    }

    private func setupUI() {
        view.addSubview(galleryView)
        view.addSubview(tableView)
        view.addSubview(inputBar)

        galleryView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(390)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(galleryView.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBar.snp.top)
        }

        inputBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        galleryView.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        galleryView.onGalleryTapped = { [weak self] in
            self?.openVideoPlayer()
        }

        inputBar.onSendTapped = { [weak self] text in
            self?.appendComment(text)
        }
        inputBar.textField.delegate = self
    }

    private func applyGalleryData() {
        let paths = postModel.galleryImagePaths()
        guard !paths.isEmpty else { return }
        galleryView.configure(
            imagePaths: paths,
            isVideo: postModel.media.isVideo,
            videoPath: postModel.media.videoURL
        )
    }

    private func openVideoPlayer() {
        guard postModel.media.isVideo else { return }
        let videoVC = CS_VideoVC(postModel: postModel)
        navigationController?.pushViewController(videoVC, animated: true)
    }

    private func appendComment(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newComment = UserData.appendComment(
            postId: postModel.postId,
            content: trimmed,
            user: CS_CurrentUser.shared.user
        )
        postModel.comments.append(newComment)
        postModel.commentCount += 1
        comments.append(newComment.toPostComment())
        post.commentCount = postModel.commentCount
        tableView.reloadSections(
            [Section.comments.rawValue, Section.post.rawValue],
            with: .automatic
        )
        scrollCommentsToBottom()
    }

    private func scrollCommentsToBottom() {
        guard !comments.isEmpty else { return }
        let indexPath = IndexPath(row: comments.count - 1, section: Section.comments.rawValue)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    private func syncPostModelFromDisplayPost() {
        postModel.isFollowing = post.isFollowing
        postModel.isLiked = post.isLiked
        postModel.isCollected = post.isCollected
    }
}

// MARK: - UITableView

extension CS_PostDetailVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .post: return 1
        case .comments: return comments.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .post:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CS_PostDetailPostCell.reuseID,
                for: indexPath
            ) as? CS_PostDetailPostCell else {
                return UITableViewCell()
            }
            cell.configure(with: post)
            bindPostCellActions(cell)
            return cell

        case .comments:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CS_PostDetailCommentCell.reuseID,
                for: indexPath
            ) as? CS_PostDetailCommentCell else {
                return UITableViewCell()
            }
            let comment = comments[indexPath.row]
            cell.configure(with: comment)
            cell.onAvatarTapped = { [weak self] in
                guard let self, let userId = comment.userId else { return }
                self.pushPerson(userId: userId)
            }
            return cell
        }
    }

    private func bindPostCellActions(_ cell: CS_PostDetailPostCell) {
        cell.onFollowTapped = { [weak self] in
            guard let self else { return }
            self.post.isFollowing.toggle()
            self.syncPostModelFromDisplayPost()
            self.tableView.reloadSections(IndexSet(integer: Section.post.rawValue), with: .none)
        }
        cell.onLikeTapped = { [weak self] in
            guard let self else { return }
            let result = UserData.toggleLike(
                postId: self.postModel.postId,
                isLiked: self.post.isLiked,
                likeCount: self.post.likeCount
            )
            self.post.isLiked = result.isLiked
            self.post.likeCount = result.likeCount
            self.postModel.isLiked = result.isLiked
            self.postModel.likeCount = result.likeCount
            self.tableView.reloadSections(IndexSet(integer: Section.post.rawValue), with: .none)
        }
        cell.onCollectTapped = { [weak self] in
            guard let self else { return }
            let collected = UserData.toggleCollect(
                postId: self.postModel.postId,
                isCollected: self.post.isCollected
            )
            self.post.isCollected = collected
            self.postModel.isCollected = collected
            self.tableView.reloadSections(IndexSet(integer: Section.post.rawValue), with: .none)
        }
        cell.onReportTapped = { [weak self] in
            guard let self else { return }
            let reportVC = CS_ReportVC(postId: self.postModel.postId)
            reportVC.onReportSubmitted = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            self.navigationController?.pushViewController(reportVC, animated: true)
        }
        cell.onAvatarTapped = { [weak self] in
            guard let self else { return }
            self.pushPerson(post: self.postModel)
        }
    }
}

// MARK: - UITextFieldDelegate

extension CS_PostDetailVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return true }
        appendComment(text)
        textField.text = nil
        return true
    }
}
