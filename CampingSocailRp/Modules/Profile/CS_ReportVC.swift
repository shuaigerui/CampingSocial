//
//  CS_ReportVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit
import Toast_Swift

class CS_ReportVC: CS_BaseVC {

    private let postId: String?
    var onReportSubmitted: (() -> Void)?

    private let reasons = [
        "Content error",
        "Language violence",
        "Religious discrimination",
        "Pornographic content",
        "Gender discrimination"
    ]

    private var selectedIndex = 0
    private var optionButtons: [UIButton] = []

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "Report"
        v.textColor = .white
        v.font = .systemFont(ofSize: 18, weight: .semibold)
        v.textAlignment = .center
        return v
    }()

    private let optionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        return stack
    }()

    private lazy var submitButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("report_submit".toImage, for: .normal)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
        return btn
    }()

    init(postId: String? = nil) {
        self.postId = postId
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
        updateOptionSelection()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(optionsStack)
        view.addSubview(submitButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        submitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(358)
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        optionsStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backButton.snp.bottom).offset(15)
        }

        reasons.enumerated().forEach { index, title in
            let btn = makeOptionButton(title: title, tag: index)
            optionButtons.append(btn)
            optionsStack.addArrangedSubview(btn)
            btn.snp.makeConstraints { make in
                make.height.equalTo(65)
            }
        }
    }

    private func makeOptionButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tag = tag
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        btn.setTitleColor(UIColor(hex: "#4A3F35"), for: .normal)
        btn.layer.cornerRadius = 24
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
        return btn
    }

    private func updateOptionSelection() {
        optionButtons.enumerated().forEach { index, btn in
            let selected = index == selectedIndex
            btn.backgroundColor = selected
                ? UIColor(hex: "#F9F1C1")
                : UIColor(hex: "#F3F7BB", alpha: 0.45)
        }
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func optionTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateOptionSelection()
    }

    @objc private func onSubmit() {
        let shouldNotify = postId != nil
        if let postId {
            UserData.markPostReported(postId: postId)
            view.makeToast("Report submitted")
        }
        navigationController?.popViewController(animated: true)
        guard shouldNotify else { return }
        DispatchQueue.main.async { [weak self] in
            self?.onReportSubmitted?()
        }
    }
}
