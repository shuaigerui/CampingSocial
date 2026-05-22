//
//  CS_TabBar.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

class CS_TabBar: UITabBar {

    private enum Layout {
        static let designWidth: CGFloat = 1170
        static let designHeight: CGFloat = 278
    }

    private let backgroundImageView: UIImageView = {
        let v = UIImageView(image: "tab_bg".toImage)
        v.contentMode = .scaleToFill
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundImage = UIImage()
        shadowImage = UIImage()
        backgroundColor = .clear
        barTintColor = .clear
        isTranslucent = false
        insertSubview(backgroundImageView, at: 0)

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        appearance.stackedLayoutAppearance.normal.iconColor = .clear
        appearance.stackedLayoutAppearance.selected.iconColor = .clear
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.clear]
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.frame = bounds
        sendSubviewToBack(backgroundImageView)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fit = super.sizeThatFits(size)
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        fit.height = width * (Layout.designHeight / Layout.designWidth)
        return fit
    }
}
