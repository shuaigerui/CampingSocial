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

    /// 独立容器，始终叠在子页面之上，保证 Tab 可点击
    private let tabBarContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = true
        return v
    }()

    private let customTabBar = CS_CustomTabBar()

    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage("tab_add".toImage, for: .normal)
        btn.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        setupViewControllers()
        setupCustomTabBar()
        selectTab(at: Tab.home.rawValue, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInsets()
        layoutTabBarContainer()
        bringTabBarToFront()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bringTabBarToFront()
    }

    private func setupViewControllers() {
        viewControllers = [
            wrap(CS_HomeVC()),
            wrap(CS_DiscoverVC()),
            wrap(UIViewController()),
            wrap(CS_ChatVC()),
            wrap(CS_ProfileVC())
        ]
    }

    private var tabBarContainerHeightConstraint: Constraint?

    private func setupCustomTabBar() {
        view.addSubview(tabBarContainer)
        tabBarContainer.addSubview(customTabBar)
        tabBarContainer.addSubview(addButton)

        tabBarContainer.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            tabBarContainerHeightConstraint = make.height.equalTo(120).constraint
        }

        customTabBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(customTabBar.snp.width).multipliedBy(278.0 / 1170.0)
        }

        customTabBar.onTabSelected = { [weak self] index in
            self?.selectTab(at: index, animated: true)
        }
    }

    private func layoutTabBarContainer() {
        let barHeight = CS_CustomTabBar.preferredHeight(for: view.bounds.width)
        tabBarContainerHeightConstraint?.update(offset: barHeight + 50)

        addButton.snp.remakeConstraints { make in
            make.centerX.equalTo(tabBarContainer)
            make.width.height.equalTo(57)
            make.bottom.equalTo(customTabBar.snp.top).offset(40)
        }
    }

    /// 子页面 TransitionView 会盖住 TabBar，必须插到它上面
    private func bringTabBarToFront() {
        guard let transitionView = view.subviews.first(where: {
            String(describing: type(of: $0)).contains("Transition")
        }) else {
            view.bringSubviewToFront(tabBarContainer)
            return
        }
        view.insertSubview(tabBarContainer, aboveSubview: transitionView)
    }

    private func updateContentInsets() {
        let height = CS_CustomTabBar.preferredHeight(for: view.bounds.width)
        viewControllers?.forEach { vc in
            vc.additionalSafeAreaInsets.bottom = height
        }
    }

    private func selectTab(at index: Int, animated: Bool) {
        if index == Tab.add.rawValue {
            addButtonTapped()
            return
        }
        guard let vcs = viewControllers, index < vcs.count else { return }
        selectedIndex = index
        customTabBar.setSelectedIndex(index)
        bringTabBarToFront()
    }

    private func wrap(_ root: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }

    @objc private func addButtonTapped() {
        onAddTapped?()
    }
}
