//
//  AppDelegate.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/22.
//

import UIKit
import IQKeyboardManager
import Toast_Swift
@_exported import SnapKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        ToastManager.shared.position = .center

        Task { @MainActor in
            _ = CS_IAPManager.shared
        }

        initializeWindow()

        if let url = launchOptions?[.url] as? URL {
            _ = handleIncomingURL(url)
        }

        return true
    }

    private func initializeWindow() {
        CS_CurrentUser.shared.restore()
        window = UIWindow(frame: UIScreen.main.bounds)
        let launchVC = CS_LaunchVC()
        launchVC.completion = {
            self.window?.rootViewController = CS_CurrentUser.shared.rootViewController()
        }
        window?.rootViewController = launchVC
        window?.makeKeyAndVisible()
    }

    // MARK: - URL Scheme（taggoo:// 从外部浏览器打开 App）

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        handleIncomingURL(url)
    }

    private func handleIncomingURL(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "taggoo" else { return false }
        window?.makeKeyAndVisible()
        return true
    }
}

