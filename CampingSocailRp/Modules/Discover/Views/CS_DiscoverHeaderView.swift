//
//  CS_DiscoverHeaderView.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_DiscoverHeaderView: UIView {

    static let preferredHeight: CGFloat = 340

    private enum Layout {
        static let cellWidth: CGFloat = 140
        static let cellHeight: CGFloat = 190
        static let lineSpacing: CGFloat = 12
    }

    var onSegmentChanged: ((Int) -> Void)?
    var onLiveItemTapped: ((CS_DiscoverLiveItem) -> Void)?

    private var liveItems: [CS_DiscoverLiveItem] = []

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "Discover"
        v.textColor = .white
        v.font = .systemFont(ofSize: 25, weight: .semibold)
        return v
    }()

    private let liveNowLabel: UILabel = {
        let v = UILabel()
        v.text = "Live Now"
        v.textColor = .white
        v.font = .systemFont(ofSize: 15, weight: .medium)
        return v
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: Layout.cellWidth, height: Layout.cellHeight)
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(CS_DiscoverLiveCell.self, forCellWithReuseIdentifier: CS_DiscoverLiveCell.reuseID)
        return cv
    }()

    private lazy var forYouButton = makeSegmentButton(title: "For you", tag: 0)
    private lazy var followingButton = makeSegmentButton(title: "Following", tag: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadMockData()
        updateSegment(selectedTag: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(liveNowLabel)
        addSubview(collectionView)
        addSubview(forYouButton)
        addSubview(followingButton)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }

        liveNowLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }

        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(liveNowLabel.snp.bottom).offset(12)
            make.height.equalTo(Layout.cellHeight)
        }

        forYouButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.height.equalTo(36)
            make.width.equalTo(100)
            make.bottom.equalToSuperview().offset(-12)
        }

        followingButton.snp.makeConstraints { make in
            make.leading.equalTo(forYouButton.snp.trailing).offset(12)
            make.centerY.height.equalTo(forYouButton)
            make.width.equalTo(110)
        }
    }

    private func loadMockData() {
        liveItems = Self.makeLiveItems()
        collectionView.reloadData()
    }

    /// Live 区 6 条数据（`Video/Live` 目录现有 4 个视频，后 2 条复用并配不同标题）
    private static func makeLiveItems() -> [CS_DiscoverLiveItem] {
        let sources: [(video: String, title: String)] = [
            ("live_01", "Mountain forest adventure"),
            ("live_02", "Riverside sunset camping"),
            ("live_03", "Friends in the orange tent"),
            ("live_04", "Wilderness creek morning")
        ]
        return sources.map { source in
            CS_DiscoverLiveItem(
                themeKey: source.video,
                videoPath: CS_ResourcePath.liveVideo(source.video),
                viewerCount: Int.random(in: 1...15),
                title: source.title
            )
        }
    }

    private func makeSegmentButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tag = tag
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.layer.cornerRadius = 18
        btn.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        return btn
    }

    private func updateSegment(selectedTag: Int) {
        let selectedBg = UIColor(hex: "#F9F1C1")
        let selectedText = UIColor(hex: "#4A3F35")
        let normalBg = UIColor.white.withAlphaComponent(0.25)
        let normalText = UIColor.white

        forYouButton.backgroundColor = selectedTag == 0 ? selectedBg : normalBg
        forYouButton.setTitleColor(selectedTag == 0 ? selectedText : normalText, for: .normal)

        followingButton.backgroundColor = selectedTag == 1 ? selectedBg : normalBg
        followingButton.setTitleColor(selectedTag == 1 ? selectedText : normalText, for: .normal)
    }

    @objc private func segmentTapped(_ sender: UIButton) {
        updateSegment(selectedTag: sender.tag)
        onSegmentChanged?(sender.tag)
    }
}

extension CS_DiscoverHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        liveItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CS_DiscoverLiveCell.reuseID,
            for: indexPath
        ) as? CS_DiscoverLiveCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: liveItems[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard liveItems.indices.contains(indexPath.item) else { return }
        onLiveItemTapped?(liveItems[indexPath.item])
    }
}
