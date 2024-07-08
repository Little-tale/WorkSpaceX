//
//  CustomDocumentInteractionController.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import SwiftUI

struct CustomDocumentInteractionController: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        DispatchQueue.main.async {
            let document = UIDocumentInteractionController(url: self.url)
            document.delegate = context.coordinator
            document.presentPreview(animated: true)
        }
        
        return viewController
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentInteractionControllerDelegate {
        var parent: CustomDocumentInteractionController
        
        init(_ parent: CustomDocumentInteractionController) {
            self.parent = parent
        }
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = window.windows.first?.rootViewController else {
                return UIViewController()
            }
            return rootVC
        }
    }
}
