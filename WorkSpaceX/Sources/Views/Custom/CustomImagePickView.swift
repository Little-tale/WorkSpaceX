//
//  CustomImagePickView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture
import Kingfisher

struct CustomImagePickView: View {
    
    @Perception.Bindable var store: StoreOf<CustomImagePickFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.imageState {
                case .profileEmpty:
                    WSXImage.profileEmpty1
                        .resizable()
                case .empty:
                    WSXImage.logoImage.resizable()
                        
                case .loading:
                    ProgressView()
                        
                case let .success(data):
                    Image(uiImage: UIImage(data: data) ?? .remove)
                        .resizable()
                case .failure:
                    WSXImage.logoImage.resizable()
                    
                case let .urlImage(url):
                    DownSamplingImageView(url: url, size: ImageResizingCase.small.size)
                }
            }
            .alert(item: $store.errorMessage) { text in
                Text("에러")
            } actions: { _ in
                Text("확인")
            } message: { text in
                Text(text)
            }
        }
    }
}
