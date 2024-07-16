//
//  WorkSpaceEditView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/18/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift

struct WorkSpaceEditView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceEditFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ZStack {
                    ZStack ( alignment: .bottom ) {
                        WSXColor.lightGray
                        contentView()
                        .padding(.horizontal, 20)
                        compliteButton()
                        
                    } // ZStack
                    .fullScreenCover(isPresented: $store.showImagePicker) {
    
                        CustomImagePicker(
                            isPresented: $store.showImagePicker,
                            selectedLimit: 1,
                            filter: .images,
                            selectedDataForJPEG:  { datas in
                                store.send(.imagePickerData(datas.first))
                            })
                        
                    }
                    .navigationTitle("워크스페이스 편집")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            WSXImage.xImage
                                .asButton {
                                    store.send(.dismissButtonTapped)
                                }
                                .foregroundStyle(WSXColor.black)
                        }
                    }
                    .alert(item: $store.errorMessage) { _ in
                        Text("에러 발생")
                    } actions: { _ in
                        Text("확인")
                    } message: { message in
                        Text(message)
                    }
                    .alert(item: $store.successMessage) { _ in
                        Text("수정 완료")
                    } actions: { _ in
                        Text("확인").asButton {
                            store.send(.alertSuccessTapped)
                        }
                    } message: { message in
                        Text(message)
                    }
                    
                    if store.showPrograssView {
                        ProgressView()
                            .centerOverlay(size: CGSize(width: 120, height: 120))
                    }
                }
            }
            
        }
    }
}


extension WorkSpaceEditView {
    
    
    private func contentView() -> some View {
        VStack {
            ZStack (alignment: .bottomTrailing) {
                imagePickView()
                WSXImage.subCamera
                    .resizable()
                    .frame(width: 25, height: 25)
            } // ZStack
            .padding(.top, 25)
            
            HeaderTextField(
                headerTitle: "워크스페이스 이름",
                placeHolder: "워크스페이스 이름을 입력하세요 (필수)",
                isSecure: false,
                binding: $store.workSpaceName,
                scopeColor: false
            )
            .padding(.vertical, 10)
            .font(WSXFont.title2)
            HeaderTextField(
                headerTitle: "워크스페이스 설명",
                placeHolder: "워크스페이스 설명를 설명하세요 (옵션)",
                isSecure: false,
                binding: $store.workSpaceIntroduce,
                scopeColor: false
            )
            .font(WSXFont.title2)
            .padding(.vertical, 10)
            
            Spacer()
            
        }
    }
    
    private func imagePickView() -> some View {
        CustomeImagePickView(
            store: store.scope(state: \.imagePick, action: \.imagePickFeature)
        )
        .modifier(RoudProfileImageModifier(frame: CGSize(width: 80, height: 80)))
        .asButton {
            store.send(.showImagePicker)
        }
    }
    
    private func compliteButton() -> some View {
        SuccessButtonView(action: {
            store.send(.regButtonTapped)
        }, regButtonState: store.regButtonState)
    }
    
}
