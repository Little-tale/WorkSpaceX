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
                   
                    .alert(item: $store.alertCase) { alertCase in
                        Text(alertCase.title)
                    } actions: { alertCase in
                        Text(alertCase.action)
                            .asButton {
                                if case .success = alertCase {
                                    store.send(.alertSuccessTapped)
                                }
                            }
                    } message: { alertCase in
                        Text(alertCase.message)
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
