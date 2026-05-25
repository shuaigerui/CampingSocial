//
//  CS_SettingVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import UIKit

private enum CS_SettingRowStyle {
    case normal
    case logout
}

class CS_SettingVC: CS_BaseVC {

    private struct SettingItem {
        let title: String
        let style: CS_SettingRowStyle
    }

    private let items: [SettingItem] = [
        SettingItem(title: "Blacklist", style: .normal),
        SettingItem(title: "Privacy agreement", style: .normal),
        SettingItem(title: "User agreement", style: .normal),
        SettingItem(title: "Community Guidelines", style: .normal),
        SettingItem(title: "Contact Us", style: .normal),
        SettingItem(title: "Delete of account", style: .normal),
        SettingItem(title: "Log out", style: .logout)
    ]

    private let rowHeight: CGFloat = 52

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("common_back".toImage, for: .normal)
        btn.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        return btn
    }()

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "Settings"
        v.textColor = .white
        v.font = .systemFont(ofSize: 18, weight: .semibold)
        v.textAlignment = .center
        return v
    }()

    private let panelView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#F3F7BB").withAlphaComponent(0.5)
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.isScrollEnabled = false
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(CS_SettingCell.self, forCellReuseIdentifier: CS_SettingCell.reuseID)
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(panelView)
        panelView.addSubview(tableView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        panelView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(rowHeight * CGFloat(items.count))
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func onBack() {
        navigationController?.popViewController(animated: true)
    }

    private func handleItem(at index: Int) {
        guard index < items.count else { return }
        if items[index].style == .logout {
            confirmLogout()
        }
    }

    private func confirmLogout() {
        let alert = UIAlertController(
            title: "Log out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        CS_CurrentUser.shared.logout()
        CS_CurrentUser.shared.switchRoot(on: view.window)
    }
}

// MARK: - UITableView

extension CS_SettingVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CS_SettingCell.reuseID,
            for: indexPath
        ) as? CS_SettingCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configure(title: item.title, style: item.style)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleItem(at: indexPath.row)
    }
}

// MARK: - Cell

private final class CS_SettingCell: UITableViewCell {

    static let reuseID = "CS_SettingCell"

    private let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 16, weight: .medium)
        return v
    }()

    private let arrowView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let img = UIImage(systemName: "chevron.right", withConfiguration: config)
        let v = UIImageView(image: img)
        v.tintColor = UIColor(hex: "#4A3F35")
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let rowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        rowStack.addArrangedSubview(titleLabel)
        rowStack.addArrangedSubview(arrowView)
        contentView.addSubview(rowStack)

        arrowView.snp.makeConstraints { make in
            make.width.equalTo(8)
            make.height.equalTo(14)
        }

        rowStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        titleLabel.attributedText = nil
        arrowView.isHidden = false
    }

    func configure(title: String, style: CS_SettingRowStyle) {
        titleLabel.text = nil
        titleLabel.attributedText = nil

        switch style {
        case .normal:
            titleLabel.text = title
            titleLabel.textColor = UIColor(hex: "#4A3F35")
            arrowView.isHidden = false
        case .logout:
            titleLabel.attributedText = NSAttributedString(
                string: title,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                    .foregroundColor: UIColor(hex: "#E53935"),
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            )
            arrowView.isHidden = true
        }
    }
}
