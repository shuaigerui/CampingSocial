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

    private var post: CS_HomePost
    private var comments: [CS_PostComment]

    private let imageColors: [UIColor]
    private let imageNames: [String]

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

    private let contentPanel: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F9F1C1")
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    init(
        post: CS_HomePost,
        comments: [CS_PostComment] = [],
        imageNames: [String] = []
    ) {
        self.post = post
        self.comments = comments.isEmpty ? Self.defaultComments : comments
        self.imageColors = post.imageColors
        self.imageNames = imageNames
        super.init(nibName: nil, bundle: nil)
    }

    init(imageColors: [UIColor] = [], imageNames: [String] = []) {
        self.post = CS_HomePost(
            userName: "Luoluo",
            time: "09:08am",
            content: "Hiking through the clouds and mist is like stepping into another world",
            likeCount: 125,
            commentCount: 39,
            isFollowing: false,
            isLiked: false,
            isCollected: false,
            imageColors: imageColors.isEmpty
                ? [UIColor(hex: "#C5D4B0"), UIColor(hex: "#A8B89A"), UIColor(hex: "#8FA67E")]
                : imageColors,
            imagePaths: [],
            avatarPath: nil
        )
        self.comments = Self.defaultComments
        self.imageColors = self.post.imageColors
        self.imageNames = imageNames
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        view.backgroundColor = UIColor(hex: "#F9F1C1")
        setupUI()
        applyGalleryData()
    }

    private func setupUI() {
        view.addSubview(galleryView)
        view.addSubview(contentPanel)
        contentPanel.addSubview(tableView)
        view.addSubview(inputBar)

        galleryView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(galleryView.snp.width)
        }

        contentPanel.snp.makeConstraints { make in
            make.top.equalTo(galleryView.snp.bottom).offset(-20)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBar.snp.top)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        inputBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        galleryView.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        inputBar.onSendTapped = { [weak self] text in
            self?.appendComment(text)
        }
        inputBar.textField.delegate = self
    }

    private func applyGalleryData() {
        if !imageNames.isEmpty {
            galleryView.configure(imageNames: imageNames)
        } else {
            galleryView.configure(imageColors: imageColors)
        }
    }

    private func appendComment(_ text: String) {
        comments.append(CS_PostComment(content: text))
        tableView.reloadSections(IndexSet(integer: Section.comments.rawValue), with: .automatic)
        scrollCommentsToBottom()
    }

    private func scrollCommentsToBottom() {
        guard !comments.isEmpty else { return }
        let indexPath = IndexPath(row: comments.count - 1, section: Section.comments.rawValue)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    private static let defaultComments: [CS_PostComment] = [
        CS_PostComment(content: "You sang so beautifully. I'll learn from you."),
        CS_PostComment(content: "You sang so beautifully. I'll learn from you."),
        CS_PostComment(content: "You sang so beautifully. I'll learn from you.")
    ]
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
            cell.configure(with: comments[indexPath.row])
            return cell
        }
    }

    private func bindPostCellActions(_ cell: CS_PostDetailPostCell) {
        cell.onFollowTapped = { [weak self] in
            guard let self else { return }
            self.post.isFollowing.toggle()
            self.tableView.reloadSections(IndexSet(integer: Section.post.rawValue), with: .none)
        }
        cell.onLikeTapped = { [weak self] in
            guard let self else { return }
            self.post.isLiked.toggle()
            self.tableView.reloadSections(IndexSet(integer: Section.post.rawValue), with: .none)
        }
        cell.onCollectTapped = { [weak self] in
            guard let self else { return }
            self.post.isCollected.toggle()
            self.tableView.reloadSections(IndexSet(integer: Section.post.rawValue), with: .none)
        }
        cell.onReportTapped = { [weak self] in
            self?.navigationController?.pushViewController(CS_ReportVC(), animated: true)
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
