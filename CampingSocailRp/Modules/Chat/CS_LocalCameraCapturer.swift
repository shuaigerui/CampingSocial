//
//  CS_LocalCameraCapturer.swift
//  CampingSocailRp
//
//  Created by  mac on 2026/5/25.
//

import AVFoundation
import UIKit

/// 本地前置摄像头预览
final class CS_LocalCameraCapturer: NSObject {

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "cs.local.camera.session")
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private weak var previewView: UIView?
    private var audioInput: AVCaptureDeviceInput?

    private(set) var isRunning = false
    var isMicEnabled = true {
        didSet { applyMicEnabled() }
    }

    func attachPreview(to view: UIView) {
        previewView = view
        DispatchQueue.main.async { [weak self] in
            guard let self, let previewView = self.previewView else { return }
            let layer = AVCaptureVideoPreviewLayer(session: self.session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = previewView.bounds
            previewView.layer.insertSublayer(layer, at: 0)
            self.previewLayer = layer
        }
    }

    func updatePreviewFrame() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.previewView else { return }
            self?.previewLayer?.frame = view.bounds
        }
    }

    func start(completion: ((Bool) -> Void)? = nil) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.configureSession() else {
                DispatchQueue.main.async { completion?(false) }
                return
            }
            self.session.startRunning()
            self.isRunning = self.session.isRunning
            DispatchQueue.main.async { completion?(self.isRunning) }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            self.isRunning = false
        }
    }

    func configureAudioSession(speakerOn: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .videoChat,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try session.setActive(true)
            try session.overrideOutputAudioPort(speakerOn ? .speaker : .none)
        } catch {
            // 音频会话失败时不阻断画面
        }
    }

    // MARK: - Private

    private func configureSession() -> Bool {
        session.beginConfiguration()
        session.sessionPreset = .high

        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        guard
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let videoInput = try? AVCaptureDeviceInput(device: camera),
            session.canAddInput(videoInput)
        else {
            session.commitConfiguration()
            return false
        }
        session.addInput(videoInput)

        if
            let mic = AVCaptureDevice.default(for: .audio),
            let micInput = try? AVCaptureDeviceInput(device: mic),
            session.canAddInput(micInput)
        {
            session.addInput(micInput)
            audioInput = micInput
        }

        session.commitConfiguration()
        return true
    }

    private func applyMicEnabled() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            for connection in self.session.connections {
                for port in connection.inputPorts where port.mediaType == .audio {
                    connection.isEnabled = self.isMicEnabled
                }
            }
        }
    }
}
