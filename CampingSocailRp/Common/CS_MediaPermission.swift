//
//  CS_MediaPermission.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import AVFoundation
import Photos
import UIKit

/// 相机 / 麦克风权限检查（进入视频通话前调用）
enum CS_MediaPermission {

    static func requestCamera(
        from presenter: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        requestAccess(
            mediaType: .video,
            title: "Camera Access Required",
            message: "Please allow camera access in Settings to start a video call.",
            from: presenter,
            completion: completion
        )
    }

    static func requestMicrophone(
        from presenter: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        requestAccess(
            mediaType: .audio,
            title: "Microphone Access Required",
            message: "Please allow microphone access in Settings to start a video call.",
            from: presenter,
            completion: completion
        )
    }

    /// 相册读取权限（选择头像、发布图片前调用）
    static func requestPhotoLibrary(
        from presenter: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        completion(true)
                    default:
                        showSettingsAlert(
                            title: "Photo Library Access Required",
                            message: "Please allow photo library access in Settings to choose an avatar.",
                            from: presenter,
                            completion: completion
                        )
                    }
                }
            }
        case .denied, .restricted:
            showSettingsAlert(
                title: "Photo Library Access Required",
                message: "Please allow photo library access in Settings to choose an avatar.",
                from: presenter,
                completion: completion
            )
        @unknown default:
            completion(false)
        }
    }

    static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Private

    private static func requestAccess(
        mediaType: AVMediaType,
        title: String,
        message: String,
        from presenter: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                DispatchQueue.main.async {
                    if granted {
                        completion(true)
                    } else {
                        showSettingsAlert(
                            title: title,
                            message: message,
                            from: presenter,
                            completion: completion
                        )
                    }
                }
            }
        case .denied, .restricted:
            showSettingsAlert(
                title: title,
                message: message,
                from: presenter,
                completion: completion
            )
        @unknown default:
            completion(false)
        }
    }

    private static func showSettingsAlert(
        title: String,
        message: String,
        from presenter: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            openAppSettings()
            completion(false)
        })
        presenter.present(alert, animated: true)
    }
}
