//
//  CustomDocumentInteractionController.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import SwiftUI
import QuickLook

struct QuickLookPreview: UIViewControllerRepresentable {
    
    var url: URL
    var onDismiss: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onDismiss: onDismiss)
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        uiViewController.reloadData()
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        var parent: QuickLookPreview
        var onDismiss: () -> Void

        init(_ parent: QuickLookPreview, onDismiss: @escaping () -> Void) {
            self.parent = parent
            self.onDismiss = onDismiss
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as NSURL
        }

        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            DispatchQueue.main.async { [weak self] in
                self?.onDismiss()
            }
        }
    }
}
