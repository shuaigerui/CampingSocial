//
//  CS_PostDetailGalleryView.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

/// 帖子详情顶部图片轮播（横向分页 + 返回 + 页码指示）
final class CS_PostDetailGalleryView: UIView {

    var onBackTapped: (() -> Void)?
    var onGalleryTapped: (() -> Void)?

    private var showsPlayButton = false
    private var videoPath: String?
    private var imagePaths: [String] = []
    private var imageColors: [UIColor] = []
    private var imageNames: [String] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.bounces = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(CS_PostDetailImageCell.self, forCellWithReuseIdentifier: CS_PostDetailImageCell.reuseID)
        return cv
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return btn
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .white
        pc.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.45)
        pc.hidesForSinglePage = true
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    private lazy var playView: UIImageView = {
        let v = UIImageView()
        v.image = "detail_play".toImage
        v.contentMode = .scaleAspectFill
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
        layer.cornerRadius = 24
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.masksToBounds = true
        clipsToBounds = true
        backgroundColor = .clear

        addSubview(collectionView)
        addSubview(backButton)
        addSubview(pageControl)
        addSubview(playView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(galleryTapped))
        addGestureRecognizer(tap)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        pageControl.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        playView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
        }
    }

    func configure(imagePaths paths: [String], isVideo: Bool = false, videoPath path: String? = nil) {
        imagePaths = paths
        imageNames = []
        imageColors = []
        showsPlayButton = isVideo
        videoPath = isVideo ? path : nil
        reloadGallery()
    }

    func configure(imageNames names: [String]) {
        imageNames = names
        imagePaths = []
        imageColors = []
        reloadGallery()
    }

    func configure(imageColors: [UIColor]) {
        self.imageColors = imageColors
        imagePaths = []
        imageNames = []
        reloadGallery()
    }

    private func reloadGallery() {
        let count = max(imagePaths.count, max(imageNames.count, imageColors.count))
        pageControl.numberOfPages = count
        pageControl.currentPage = 0
        pageControl.isHidden = count <= 1
        playView.isHidden = !showsPlayButton
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }

    private func itemCount() -> Int {
        max(imagePaths.count, max(imageNames.count, imageColors.count))
    }

    @objc private func backTapped() {
        onBackTapped?()
    }

    @objc private func galleryTapped() {
        guard showsPlayButton else { return }
        onGalleryTapped?()
    }

    private func updateCurrentPage() {
        let width = collectionView.bounds.width
        guard width > 0 else { return }
        let page = Int(round(collectionView.contentOffset.x / width))
        pageControl.currentPage = min(max(page, 0), itemCount() - 1)
    }
}

// MARK: - UICollectionView

extension CS_PostDetailGalleryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemCount()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CS_PostDetailImageCell.reuseID,
            for: indexPath
        ) as? CS_PostDetailImageCell else {
            return UICollectionViewCell()
        }

        if showsPlayButton, let videoPath, !videoPath.isEmpty {
            if let image = CS_VideoThumbnail.cachedImage(forVideoPath: videoPath) {
                cell.configure(image: image)
            } else {
                cell.configure(image: nil)
            }
        } else if indexPath.item < imagePaths.count {
            cell.configure(image: imagePaths[indexPath.item].resourceFileImage)
        } else if indexPath.item < imageNames.count {
            cell.configure(image: imageNames[indexPath.item].toImage)
        } else if indexPath.item < imageColors.count {
            cell.configure(backgroundColor: imageColors[indexPath.item])
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard showsPlayButton,
              let videoPath,
              !videoPath.isEmpty,
              CS_VideoThumbnail.cachedImage(forVideoPath: videoPath) == nil,
              let cell = cell as? CS_PostDetailImageCell else { return }

        CS_VideoThumbnail.loadFirstFrame(forVideoPath: videoPath) { [weak collectionView] image in
            guard let collectionView,
                  let visible = collectionView.cellForItem(at: indexPath) as? CS_PostDetailImageCell else {
                return
            }
            visible.configure(image: image)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentPage()
    }
}
