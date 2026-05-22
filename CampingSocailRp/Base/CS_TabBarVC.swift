//
//  CS_TabBarVC.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_TabBarVC: UITabBarController {

    private enum Tab: Int, CaseIterable {
        case home
        case discover
        case add
        case chat
        case profile
    }

    var onAddTapped: (() -> Void)?

    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("tab_add".toImage, for: .normal)
        btn.adjustsImageWhenHighlighted = true
        btn.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return btn
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        setValue(CS_TabBar(), forKey: "tabBar")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setValue(CS_TabBar(), forKey: "tabBar")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupViewControllers()
        setupAddButton()
        selectedIndex = Tab.home.rawValue
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutAddButton()
    }

    private func setupViewControllers() {
        let controllers: [UIViewController] = [
            wrap(CS_HomeVC(), normal: "tab_home", selected: "tab_home_sel"),
            wrap(CS_DiscoverVC(), normal: "tab_discover", selected: "tab_discover_sel"),
            wrap(UIViewController(), normal: nil, selected: nil, isPlaceholder: true),
            wrap(CS_ChatVC(), normal: "tab_chat", selected: "tab_chat_sel"),
            wrap(CS_ProfileVC(), normal: "tab_profile", selected: "tab_profile_sel")
        ]
        viewControllers = controllers
    }

    private func setupAddButton() {
        view.addSubview(addButton)
    }

    private func layoutAddButton() {
        view.bringSubviewToFront(addButton)
        addButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(57)
            make.bottom.equalTo(tabBar.snp.top).offset(40)
        }
    }

    private func wrap(
        _ root: UIViewController,
        normal: String?,
        selected: String?,
        isPlaceholder: Bool = false
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.setNavigationBarHidden(true, animated: false)

        if isPlaceholder {
            nav.tabBarItem = UITabBarItem(title: nil, image: Self.clearTabImage(), selectedImage: nil)
        } else if let normal, let selected {
            nav.tabBarItem = makeTabItem(normal: normal, selected: selected)
        }
        return nav
    }

    private func makeTabItem(normal: String, selected: String) -> UITabBarItem {
        let item = UITabBarItem(
            title: nil,
            image: normal.toImage?.withRenderingMode(.alwaysOriginal),
            selectedImage: selected.toImage?.withRenderingMode(.alwaysOriginal)
        )
        item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        return item
    }

    private static func clearTabImage() -> UIImage {
        let size = CGSize(width: 28, height: 28)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }

    @objc private func addButtonTapped() {
        onAddTapped?()
    }
}

extension CS_TabBarVC: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return true }
        if index == Tab.add.rawValue {
            addButtonTapped()
            return false
        }
        return true
    }
}
