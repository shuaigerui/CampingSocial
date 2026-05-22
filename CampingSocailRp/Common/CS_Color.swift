//
//  CS_Color.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit

/// 项目颜色分类，直接复制 `xxxHex` 到设计稿，或用 `xxx` 设置 UI
enum CS_Color {

    // MARK: - 背景色

    enum Background {
        static let whiteHex = "#FFFFFF"
        static let pageHex = "#F5F5F5"
        static let cardHex = "#FFFFFF"

        static var white: UIColor { UIColor(hex: whiteHex) }
        static var page: UIColor { UIColor(hex: pageHex) }
        static var card: UIColor { UIColor(hex: cardHex) }
    }

    // MARK: - 文字色

    enum Text {
        static let primaryHex = "#333333"
        static let secondaryHex = "#666666"
        static let placeholderHex = "#999999"
        static let inverseHex = "#FFFFFF"

        static var primary: UIColor { UIColor(hex: primaryHex) }
        static var secondary: UIColor { UIColor(hex: secondaryHex) }
        static var placeholder: UIColor { UIColor(hex: placeholderHex) }
        static var inverse: UIColor { UIColor(hex: inverseHex) }
    }

    // MARK: - 品牌色

    enum Brand {
        static let primaryHex = "#2E7D32"
        static let secondaryHex = "#81C784"

        static var primary: UIColor { UIColor(hex: primaryHex) }
        static var secondary: UIColor { UIColor(hex: secondaryHex) }
    }

    // MARK: - 边框 / 分割线

    enum Border {
        static let lightHex = "#EEEEEE"
        static let normalHex = "#DDDDDD"

        static var light: UIColor { UIColor(hex: lightHex) }
        static var normal: UIColor { UIColor(hex: normalHex) }
    }

    // MARK: - 功能色

    enum Functional {
        static let successHex = "#4CAF50"
        static let warningHex = "#FF9800"
        static let errorHex = "#F44336"

        static var success: UIColor { UIColor(hex: successHex) }
        static var warning: UIColor { UIColor(hex: warningHex) }
        static var error: UIColor { UIColor(hex: errorHex) }
    }
}
