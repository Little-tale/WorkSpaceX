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
                ZStack ( alignment: .bottom ) {
                    WSXColor.lightGray
                    VStack {
                        ZStack (alignment: .bottomTrailing) {
                            CustomeImagePickView(
                             store: store.scope(state: \.imagePick, action: \.imagePickFeature)
                            )
                            .modifier(RoudProfileImageModifier(frame: CGSize(width: 80, height: 80)))
                            .asButton {
                                store.send(.showImagePicker)
                            }
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
                        
                    }// VStack
                    .padding(.horizontal, 20)
                    Text("완료")
                        .font(WSXFont.title2)
                        .modifier(CommonButtonModifer())
                        .background(store.regButtonState ? WSXColor.green : WSXColor.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                        .foregroundStyle(WSXColor.white)
                        .asButton {
                            store.send(.regButtonTapped)
                        }
                        .disabled(!store.regButtonState)
                        
                } // ZStack
                .fullScreenCover(isPresented: $store.showImagePicker) {
                    
                        CustomImagePicker(
                            isPresented: $store.showImagePicker,
                            selectedLimit: 1,
                            filter: .images,
                            selectedDataForPNG:  { datas in
                                store.send(.imagePickerData(datas.first))
                            })
                
                }
               
            }
            .navigationTitle("워크스페이스 생성")
            
        }
    }
}

#Preview {
    WorkSpaceInitalView(
        store: Store(initialState: WorkSpaceInitalFeature.State(), reducer: {
            WorkSpaceInitalFeature()
        })
    )
}
