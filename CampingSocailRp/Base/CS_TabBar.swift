//
//  CS_TabBar.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

/// 完全自定义 Tab 栏，不依赖系统 UITabBar，避免毛玻璃与选中黑底
final class CS_CustomTabBar: UIView {

    private enum Layout {
        static let designWidth: CGFloat = 1170
        static let designHeight: CGFloat = 278
        static let iconSide: CGFloat = 28
    }

    private struct TabConfig {
        let normal: String
        let selected: String
    }

    var onTabSelected: ((Int) -> Void)?

    private let tabConfigs: [TabConfig?] = [
        TabConfig(normal: "tab_home", selected: "tab_home_sel"),
        TabConfig(normal: "tab_discover", selected: "tab_discover_sel"),
        nil,
        TabConfig(normal: "tab_chat", selected: "tab_chat_sel"),
        TabConfig(normal: "tab_profile", selected: "tab_profile_sel")
    ]

    private var tabButtons: [UIButton] = []

    private let bgImageView: UIImageView = {
        let v = UIImageView(image: "tab_bg".toImage)
        v.contentMode = .scaleToFill
        v.isUserInteractionEnabled = false
        return v
    }()

    private let itemsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    static func preferredHeight(for width: CGFloat) -> CGFloat {
        width * (Layout.designHeight / Layout.designWidth)
    }

    private func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        addSubview(bgImageView)
        addSubview(itemsStack)

        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        itemsStack.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-8)
            make.height.equalTo(Layout.iconSide + 12)
        }

        for (index, config) in tabConfigs.enumerated() {
            let column = UIView()
            itemsStack.addArrangedSubview(column)

            guard let config else { continue }

            let btn = UIButton(type: .custom)
            btn.tag = index
            btn.setImage(config.normal.toImage, for: .normal)
            btn.imageView?.contentMode = .scaleAspectFit
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            column.isUserInteractionEnabled = true
            column.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(4)
            }
            tabButtons.append(btn)
        }
    }

    func setSelectedIndex(_ index: Int) {
        for btn in tabButtons {
            guard let config = tabConfigs[btn.tag] else { continue }
            let imageName = btn.tag == index ? config.selected : config.normal
            btn.setImage(imageName.toImage, for: .normal)
        }
    }

    @objc private func tabTapped(_ sender: UIButton) {
        onTabSelected?(sender.tag)
    }
}
