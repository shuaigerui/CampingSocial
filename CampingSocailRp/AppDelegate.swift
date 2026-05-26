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

        return true
    }

    private func initializeWindow() {
        CS_CurrentUser.shared.restore()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = CS_CurrentUser.shared.rootViewController()
        window?.makeKeyAndVisible()
    }
}

