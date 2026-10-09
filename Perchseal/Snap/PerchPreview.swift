@preconcurrency import AVFoundation
import SwiftUI
import UIKit

/// The one custom surface: an edge-to-edge video preview for band scan and gap snap.
struct PerchPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PerchPreviewHost {
        let host = PerchPreviewHost()
        host.preview.session = session
        host.preview.videoGravity = .resizeAspectFill
        return host
    }

    func updateUIView(_ host: PerchPreviewHost, context: Context) {
        host.preview.session = session
    }
}

final class PerchPreviewHost: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var preview: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

/// Owns the capture session. Scan reads QR. Snap writes a JPEG for GapMark.
@MainActor
final class PerchLens: NSObject, ObservableObject {
    enum Gate: Equatable {
        case checking
        case ask
        case live
        case denied
        case unavailable
    }

    @Published private(set) var gate: Gate = .checking
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var configured = false
    private var photoWait: CheckedContinuation<Data?, Never>?
    var onPayload: ((String) -> Void)?

    func refresh() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            begin()
        case .notDetermined:
            gate = .ask
        case .denied, .restricted:
            gate = .denied
        @unknown default:
            gate = .denied
        }
    }

    func proceed() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            Task { @MainActor in
                if granted {
                    self.begin()
                } else {
                    self.gate = .denied
                }
            }
        }
    }

    func halt() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func snapJPEG() async -> Data? {
        if gate == .live, configured {
            return await withCheckedContinuation { continuation in
                photoWait = continuation
                let settings = AVCapturePhotoSettings()
                photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
        return PerchLens.stillPlate()
    }

    private func begin() {
        if !configured {
            configured = configure()
        }
        guard configured else {
            gate = .unavailable
            return
        }
        gate = .live
        if !session.isRunning {
            session.startRunning()
        }
    }

    private func configure() -> Bool {
        session.beginConfiguration()
        session.sessionPreset = .high
        defer { session.commitConfiguration() }
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            return false
        }
        session.addInput(input)
        let metadata = AVCaptureMetadataOutput()
        if session.canAddOutput(metadata) {
            session.addOutput(metadata)
            metadata.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadata.metadataObjectTypes = [.qr]
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        return true
    }

    private static func stillPlate() -> Data? {
        let side = WingSpace.x12 * 4
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        let image = renderer.image { context in
            UIColor(white: 0.12, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: side, height: side))
        }
        return image.jpegData(compressionQuality: 0.82)
    }
}

extension PerchLens: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        let payload = metadataObjects
            .compactMap { $0 as? AVMetadataMachineReadableCodeObject }
            .first?
            .stringValue
        guard let payload, !payload.isEmpty else { return }
        Task { @MainActor in
            self.onPayload?(payload)
        }
    }
}

extension PerchLens: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let data = photo.fileDataRepresentation()
        Task { @MainActor in
            self.photoWait?.resume(returning: data)
            self.photoWait = nil
        }
    }
}
