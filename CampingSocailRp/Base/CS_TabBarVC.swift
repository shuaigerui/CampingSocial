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
    var onPhotoTapped: (() -> Void)?
    var onVideoTapped: (() -> Void)?

    private var isAddMenuVisible = false
    private var isTabBarChromeHidden = false

    /// 独立容器，始终叠在子页面之上，保证 Tab 可点击
    private let tabBarContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = true
        return v
    }()

    private let customTabBar = CS_CustomTabBar()

    private lazy var addMenuView: CS_AddMenuView = {
        let v = CS_AddMenuView()
        v.isHidden = true
        v.onDismiss = { [weak self] in
            self?.hideAddMenu()
        }
        v.onPhotoTapped = { [weak self] in
            self?.hideAddMenu {
                self?.onPhotoTapped?()
            }
        }
        v.onVideoTapped = { [weak self] in
            self?.hideAddMenu {
                self?.onVideoTapped?()
            }
        }
        return v
    }()

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
        setupAddMenu()
        setupPushPostHandlers()
        selectTab(at: Tab.home.rawValue, animated: false)
    }

    private func setupPushPostHandlers() {
        onPhotoTapped = { [weak self] in
            self?.pushPostPage(mode: .photos)
        }
        onVideoTapped = { [weak self] in
            self?.pushPostPage(mode: .video)
        }
    }

    private func pushPostPage(mode: CS_PushPostMediaMode) {
        guard let nav = selectedViewController as? UINavigationController else { return }
        nav.pushViewController(CS_PushPostVC(mediaMode: mode), animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInsets()
        layoutTabBarContainer()
        bringChromeToFront()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bringChromeToFront()
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
            self?.hideAddMenu()
            self?.selectTab(at: index, animated: true)
        }
    }

    private func setupAddMenu() {
        view.addSubview(addMenuView)
        addMenuView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

    /// 子页面 TransitionView 会盖住 TabBar；Add 菜单在内容之上、TabBar 之下
    private func bringChromeToFront() {
        guard let transitionView = view.subviews.first(where: {
            String(describing: type(of: $0)).contains("Transition")
        }) else {
            view.bringSubviewToFront(addMenuView)
            view.bringSubviewToFront(tabBarContainer)
            return
        }
        view.insertSubview(addMenuView, aboveSubview: transitionView)
        view.insertSubview(tabBarContainer, aboveSubview: addMenuView)
    }

    /// 隐藏/显示自定义 TabBar（发帖页等全屏子页使用）
    func setCustomTabBarHidden(_ hidden: Bool, animated: Bool = true) {
        guard isTabBarChromeHidden != hidden else { return }
        isTabBarChromeHidden = hidden
        hideAddMenu()

        let apply = {
            self.tabBarContainer.isHidden = hidden
            self.tabBarContainer.alpha = hidden ? 0 : 1
            self.updateContentInsets()
        }

        if animated {
            if !hidden {
                tabBarContainer.isHidden = false
            }
            UIView.animate(withDuration: 0.25, animations: apply)
        } else {
            apply()
        }
    }

    private func updateContentInsets() {
        let height = isTabBarChromeHidden
            ? 0
            : CS_CustomTabBar.preferredHeight(for: view.bounds.width)
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
        bringChromeToFront()
    }

    private func wrap(_ root: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.setNavigationBarHidden(true, animated: false)
        return nav
    }

    @objc private func addButtonTapped() {
        if isAddMenuVisible {
            hideAddMenu()
        } else {
            showAddMenu()
        }
    }

    private func showAddMenu() {
        isAddMenuVisible = true
        bringChromeToFront()
        addMenuView.show()
        onAddTapped?()
    }

    private func hideAddMenu(completion: (() -> Void)? = nil) {
        guard isAddMenuVisible else {
            completion?()
            return
        }
        isAddMenuVisible = false
        addMenuView.hide {
            completion?()
        }
    }
}
