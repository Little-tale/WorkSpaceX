//
//  CustomeImagePickView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture
import Kingfisher

struct CustomeImagePickView: View {
    
    @Perception.Bindable var store: StoreOf<CustomImagePickPeature>
    
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
                    DownSamplingImageView(url: url, size: CGSize(width: 100, height: 100))
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
