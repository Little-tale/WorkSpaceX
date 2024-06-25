//
//  CustomDataPicker.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/25/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct CustomDataPicker: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    /// selectedLimit
    let selectedLimit: Int
    
    var didSelctedFiles: ([URL]) -> Void
    var ifNeedRemitOver: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.pdf, .zip], asCopy: true
        )
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = true
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        var parent: CustomDataPicker
        
        init(_ parent: CustomDataPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if urls.count > parent.selectedLimit {
                
                let limitedUrls = Array(urls.prefix(parent.selectedLimit))
                parent.didSelctedFiles(limitedUrls)
                parent.isPresented = false
                parent.ifNeedRemitOver()
            } else {
                parent.didSelctedFiles(urls)
                parent.isPresented = false
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isPresented = false
        }
    }
    
}
