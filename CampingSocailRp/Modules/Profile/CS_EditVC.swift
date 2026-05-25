//
//  CS_EditVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import PhotosUI
import Toast_Swift
import UIKit

class CS_EditVC: CS_BaseVC {

    private var pendingAvatarPath: String?

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "Edit Profile"
        v.textColor = .white
        v.font = .systemFont(ofSize: 18, weight: .semibold)
        v.textAlignment = .center
        return v
    }()

    private lazy var avatarButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(onAvatarTapped), for: .touchUpInside)
        return btn
    }()

    private let avatarImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 93 / 2
        v.backgroundColor = UIColor(hex: "#D4C4A8")
        v.isUserInteractionEnabled = false
        return v
    }()

    private let cameraImageView: UIImageView = {
        let v = UIImageView(image: "info_camera".toImage)
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
    }()

    private lazy var nameField = CS_EditVC.makeInputField(placeholder: "Your name")

    private lazy var bioTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = .white
        tv.backgroundColor = UIColor(hex: "#F3F7BB", alpha: 0.5)
        tv.layer.cornerRadius = 16
        tv.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        tv.autocapitalizationType = .sentences
        tv.delegate = self
        return tv
    }()

    private let bioPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Your bio"
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        return label
    }()

    private lazy var saveButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("edit_save".toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(onSave), for: .touchUpInside)
        return btn
    }()

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
        loadCurrentUser()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(avatarButton)
        avatarButton.addSubview(avatarImageView)
        avatarButton.addSubview(cameraImageView)
        view.addSubview(nameField)
        view.addSubview(bioTextView)
        bioTextView.addSubview(bioPlaceholderLabel)
        view.addSubview(saveButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
            make.left.greaterThanOrEqualTo(backButton.snp.right).offset(8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }

        avatarButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(93)
        }

        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cameraImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        nameField.snp.makeConstraints { make in
            make.top.equalTo(avatarButton.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(65)
        }

        bioTextView.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(16)
            make.left.right.equalTo(nameField)
            make.height.equalTo(140)
        }

        bioPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(15)
        }

        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(358)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func loadCurrentUser() {
        guard let user = CS_CurrentUser.shared.user else { return }
        nameField.text = user.userName
        bioTextView.text = user.signature
        pendingAvatarPath = user.avatarURL
        applyAvatarImage()
        updateBioPlaceholder()
    }

    private func applyAvatarImage() {
        if let path = pendingAvatarPath, !path.isEmpty {
            avatarImageView.image = path.resourceFileImage ?? path.toImage
        } else {
            avatarImageView.image = "info_avatar".toImage
        }
        avatarImageView.backgroundColor = avatarImageView.image == nil
            ? UIColor(hex: "#D4C4A8") : .clear
    }

    private func updateBioPlaceholder() {
        bioPlaceholderLabel.isHidden = !bioTextView.text.isEmpty
    }

    private static func makeInputField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = .white
        tf.backgroundColor = UIColor(hex: "#F3F7BB", alpha: 0.5)
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.leftViewMode = .always
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.85)]
        )
        return tf
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onAvatarTapped() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func onSave() {
        let userName = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let signature = bioTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !userName.isEmpty else {
            view.makeToast("Please enter your name")
            return
        }

        guard CS_CurrentUser.shared.updateProfile(
            userName: userName,
            signature: signature.isEmpty ? "Personal signature~" : signature,
            avatarURL: pendingAvatarPath
        ) else {
            view.makeToast("Unable to save profile")
            return
        }

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension CS_EditVC: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        updateBioPlaceholder()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CS_EditVC: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                if let path = CS_CurrentUser.shared.saveAvatarImage(image) {
                    self.pendingAvatarPath = path
                    self.avatarImageView.image = image
                    self.avatarImageView.backgroundColor = .clear
                }
            }
        }
    }
}
