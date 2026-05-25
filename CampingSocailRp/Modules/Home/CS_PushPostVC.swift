//
//  CS_PushPostVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

/// 从发布菜单进入：发多图 / 发单视频（互斥）
enum CS_PushPostMediaMode {
    case photos
    case video
}

class CS_PushPostVC: CS_BaseVC {

    private enum ContentState {
        case empty
        case images([UIImage])
        case video(thumbnail: UIImage, url: URL?)
    }

    private enum CollectionItem {
        case add
        case image(UIImage, index: Int)
        case video(UIImage)
    }

    private static let maxImageCount = 9
    private static let itemSide: CGFloat = 88
    private static let itemSpacing: CGFloat = 10

    private let mediaMode: CS_PushPostMediaMode
    private var contentState: ContentState = .empty

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "Post"
        v.textColor = .white
        v.font = .systemFont(ofSize: 18, weight: .semibold)
        v.textAlignment = .center
        return v
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Self.itemSpacing
        layout.minimumInteritemSpacing = Self.itemSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(CS_PushPostAddCell.self, forCellWithReuseIdentifier: CS_PushPostAddCell.reuseID)
        cv.register(CS_PushPostThumbCell.self, forCellWithReuseIdentifier: CS_PushPostThumbCell.reuseID)
        return cv
    }()

    private lazy var descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = UIColor(hex: "#4A3F35")
        tv.backgroundColor = UIColor(hex: "#E9DC8A")
        tv.layer.cornerRadius = 24
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        tv.delegate = self
        return tv
    }()

    private let descriptionPlaceholder: UILabel = {
        let v = UILabel()
        v.text = "Add Description"
        v.font = .systemFont(ofSize: 15)
        v.textColor = UIColor(hex: "#4A3F35").withAlphaComponent(0.35)
        return v
    }()

    private lazy var postButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("push_push".toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(onPost), for: .touchUpInside)
        return btn
    }()

    init(mediaMode: CS_PushPostMediaMode) {
        self.mediaMode = mediaMode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDescriptionPlaceholder()
        reloadCollection()
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

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(descriptionTextView)
        descriptionTextView.addSubview(descriptionPlaceholder)
        view.addSubview(postButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(Self.itemSide)
        }

        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(160)
        }

        descriptionPlaceholder.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
        }

        postButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func collectionItems() -> [CollectionItem] {
        switch contentState {
        case .empty:
            return [.add]
        case .images(let images):
            var items = images.enumerated().map { CollectionItem.image($1, index: $0) }
            if images.count < Self.maxImageCount {
                items.append(.add)
            }
            return items
        case .video(let thumbnail, _):
            return [.video(thumbnail)]
        }
    }

    private func reloadCollection() {
        collectionView.reloadData()
    }

    private func updateDescriptionPlaceholder() {
        descriptionPlaceholder.isHidden = !descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func presentMediaPicker() {
        switch mediaMode {
        case .photos:
            guard case .empty = contentState else {
                presentPhotoPickerIfNeeded()
                return
            }
            presentPhotoPickerIfNeeded()
        case .video:
            guard case .empty = contentState else { return }
            presentVideoPicker()
        }
    }

    private func presentPhotoPickerIfNeeded() {
        let currentCount: Int
        if case .images(let imgs) = contentState {
            currentCount = imgs.count
        } else if case .empty = contentState {
            currentCount = 0
        } else {
            return
        }

        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = Self.maxImageCount - currentCount

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentVideoPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .videos
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func appendImages(_ images: [UIImage]) {
        switch contentState {
        case .empty:
            contentState = .images(Array(images.prefix(Self.maxImageCount)))
        case .images(var existing):
            existing.append(contentsOf: images)
            contentState = .images(Array(existing.prefix(Self.maxImageCount)))
        case .video:
            break
        }
        reloadCollection()
    }

    private func setVideo(thumbnail: UIImage, url: URL?) {
        contentState = .video(thumbnail: thumbnail, url: url)
        reloadCollection()
    }

    private func removeImage(at index: Int) {
        guard case .images(var images) = contentState, images.indices.contains(index) else { return }
        images.remove(at: index)
        contentState = images.isEmpty ? .empty : .images(images)
        reloadCollection()
    }

    private func removeVideo() {
        contentState = .empty
        reloadCollection()
    }

    private static func thumbnail(for videoURL: URL) -> UIImage? {
        CS_VideoThumbnail.firstFrameImage(forVideoPath: videoURL.path)
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onPost() {
        showPop(
            title: "Friendly Reminder",
            des: "Published successfully.\nIt will be reviewed shortly."
        ) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UICollectionView

extension CS_PushPostVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionItems().count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let item = collectionItems()[indexPath.item]

        switch item {
        case .add:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CS_PushPostAddCell.reuseID,
                for: indexPath
            ) as? CS_PushPostAddCell else {
                return UICollectionViewCell()
            }
            cell.onTapped = { [weak self] in
                self?.presentMediaPicker()
            }
            return cell

        case .image(let image, let index):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CS_PushPostThumbCell.reuseID,
                for: indexPath
            ) as? CS_PushPostThumbCell else {
                return UICollectionViewCell()
            }
            cell.configure(image: image)
            cell.onDeleteTapped = { [weak self] in
                self?.removeImage(at: index)
            }
            return cell

        case .video(let image):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CS_PushPostThumbCell.reuseID,
                for: indexPath
            ) as? CS_PushPostThumbCell else {
                return UICollectionViewCell()
            }
            cell.configure(image: image)
            cell.onDeleteTapped = { [weak self] in
                self?.removeVideo()
            }
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: Self.itemSide, height: Self.itemSide)
    }
}

// MARK: - PHPicker

extension CS_PushPostVC: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        switch mediaMode {
        case .photos:
            loadImages(from: results)
        case .video:
            loadVideo(from: results.first)
        }
    }

    private func loadImages(from results: [PHPickerResult]) {
        var images: [UIImage] = []
        let group = DispatchGroup()

        for result in results {
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                if let image = object as? UIImage {
                    images.append(image)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self, !images.isEmpty else { return }
            self.appendImages(images)
        }
    }

    private func loadVideo(from result: PHPickerResult?) {
        guard let result else { return }
        let provider = result.itemProvider
        let movieType = UTType.movie.identifier

        if provider.hasItemConformingToTypeIdentifier(movieType) {
            provider.loadFileRepresentation(forTypeIdentifier: movieType) { [weak self] url, _ in
                guard let self, let url else { return }
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString + ".mov")
                try? FileManager.default.copyItem(at: url, to: tempURL)
                let thumb = Self.thumbnail(for: tempURL) ?? UIImage()
                DispatchQueue.main.async {
                    self.setVideo(thumbnail: thumb, url: tempURL)
                }
            }
            return
        }

        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
                guard let self, let image = object as? UIImage else { return }
                DispatchQueue.main.async {
                    self.setVideo(thumbnail: image, url: nil)
                }
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension CS_PushPostVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updateDescriptionPlaceholder()
    }
}
