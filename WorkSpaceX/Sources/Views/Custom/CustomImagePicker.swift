//
//  CustomImagePicker.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import SwiftUI
import PhotosUI

struct CustomImagePicker: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    /// 선택 가능한 개체 수
    let selectedLimit: Int // 선택 가능 이미지 갯수
    
    /// 미디어 타입 정해주세요
    let filter: PHPickerFilter
    
    var selectedImages: (([UIImage]) -> Void)?
    
    var selectedDataForPNG: (([Data]) -> Void)?
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = selectedLimit
        config.filter = filter
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: CustomImagePicker
        
        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var images: [UIImage] = []
            let dispatchGroup = DispatchGroup()
            
            for result in results {
                dispatchGroup.enter()
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    DispatchQueue.main.async {
                        guard let image = object as? UIImage else {
                            dispatchGroup.leave()
                            return
                        }
                        images.append(image)
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) { [unowned self] in
                parent.selectedImages?(images)
                parent.selectedDataForPNG?(images.compactMap({ $0.pngData() }))
                parent.isPresented = false
            }
        }
    }
}
