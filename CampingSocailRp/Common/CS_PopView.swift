//
//  CS_PopView.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

/// 通用提示弹窗：`common_popBg` 背景 + `common_popOK` 按钮
final class CS_PopView: UIView {

    var onOKTapped: (() -> Void)?

    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    private let cardView: UIImageView = {
        let v = UIImageView(image: "common_popBg".toImage)
        v.contentMode = .scaleToFill
        v.clipsToBounds = true
        v.isUserInteractionEnabled = true
        return v
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 18, weight: .bold)
        v.textColor = UIColor(hex: "#4A3F35")
        v.textAlignment = .center
        v.numberOfLines = 0
        return v
    }()

    private let desLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14, weight: .regular)
        v.textColor = UIColor(hex: "#4A3F35")
        v.textAlignment = .center
        v.numberOfLines = 0
        return v
    }()

    private lazy var okButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_popOK".toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
        return btn
    }()

    private let title: String
    private let des: String

    init(title: String, des: String) {
        self.title = title
        self.des = des
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.text = title
        desLabel.text = des

        addSubview(dimView)
        addSubview(cardView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(desLabel)
        cardView.addSubview(okButton)

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(318)
            make.height.greaterThanOrEqualTo(220)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.left.right.equalToSuperview().inset(28)
        }

        desLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(28)
        }

        okButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(desLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-28)
        }
    }

    // MARK: - Show / Hide

    @discardableResult
    static func show(
        on parent: UIView,
        title: String,
        des: String,
        onOK: (() -> Void)? = nil
    ) -> CS_PopView {
        let pop = CS_PopView(title: title, des: des)
        pop.onOKTapped = onOK
        pop.frame = parent.bounds
        pop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.addSubview(pop)
        pop.show()
        return pop
    }

    func show(animated: Bool = true) {
        isHidden = false
        guard animated else {
            alpha = 1
            return
        }
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        let finish = {
            self.removeFromSuperview()
            completion?()
        }
        guard animated else {
            finish()
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { _ in
            finish()
        })
    }

    @objc private func okTapped() {
        hide { [weak self] in
            self?.onOKTapped?()
        }
    }
}

// MARK: - UIViewController

extension UIViewController {

    @discardableResult
    func showPop(title: String, des: String, onOK: (() -> Void)? = nil) -> CS_PopView {
        let host = view.window ?? view!
        return CS_PopView.show(on: host, title: title, des: des, onOK: onOK)
    }
}
