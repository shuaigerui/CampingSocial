//
//  CS_PostDetailInputBar.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

final class CS_PostDetailInputBar: UIView {

    var onSendTapped: ((String) -> Void)?

    private let fieldContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Say something"
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = UIColor(hex: "#4A3F35")
        tf.returnKeyType = .send
        tf.attributedPlaceholder = NSAttributedString(
            string: "Say something",
            attributes: [.foregroundColor: UIColor(hex: "#4A3F35").withAlphaComponent(0.35)]
        )
        return tf
    }()

    private lazy var sendButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("post_send".toImage, for: .normal)
        btn.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(fieldContainer)
        fieldContainer.addSubview(textField)
        fieldContainer.addSubview(sendButton)

        fieldContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(52)
        }

        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.width.equalTo(59)
            make.height.equalTo(40)
        }

        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    @objc private func sendTapped() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        onSendTapped?(text)
        textField.text = nil
    }
}
