//
//  WorkSpaceInitalView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceInitalView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceInitalFeature>
    
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ZStack {
                    ZStack ( alignment: .bottom ) {
                        WSXColor.lightGray
                        
                        contentView()
                        .padding(.horizontal, 20)
                    
                        SuccessButtonView(action: {
                            store.send(.regButtonTapped)
                        }, regButtonState: store.regButtonState)
                        
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
                    .navigationTitle(store.navigationTitle)
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
                    .alert($store.scope(state: \.logOutAlertState,action: \.alert))
                    
                    .alert(item: $store.errorMessage) { _ in
                        Text("에러 발생")
                    } actions: { _ in
                        Text("확인")
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

extension WorkSpaceInitalView {
    
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
                headerTitle: store.workSpaceNameFieldType.headerTitle,
                placeHolder: store.workSpaceNameFieldType.placeHolderTitle,
                isSecure: false,
                binding: $store.workSpaceName,
                scopeColor: false
            )
            .padding(.vertical, 10)
            .font(WSXFont.title2)
            HeaderTextField(
                headerTitle: store.workSpaceExplainType.headerTitle,
                placeHolder: store.workSpaceExplainType.placeHolderTitle,
                isSecure: false,
                binding: $store.workSpaceIntroduce,
                scopeColor: false
            )
            .font(WSXFont.title2)
            .padding(.vertical, 10)
            
            Spacer()
            
        }// VStack
    }
}

extension WorkSpaceInitalView {

    private func imagePickView() -> some View {
        CustomeImagePickView(
            store: store.scope(state: \.imagePick, action: \.imagePickFeature)
        )
        .modifier(RoudProfileImageModifier(frame: CGSize(width: 80, height: 80)))
        .asButton {
            store.send(.showImagePicker)
        }
    }
}
