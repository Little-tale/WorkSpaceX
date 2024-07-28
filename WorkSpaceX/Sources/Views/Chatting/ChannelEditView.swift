//
//  ChannelEditView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/28/24.
//

import SwiftUI
import ComposableArchitecture

struct ChannelEditView: View {
    
    @Perception.Bindable var store: StoreOf<ChannelEditFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                channelEditContentView() // ZStack
                .fullScreenCover(isPresented: $store.showImagePicker) {
                    
                    CustomImagePicker(
                        isPresented: $store.showImagePicker,
                        selectedLimit: 1,
                        filter: .images,
                        selectedDataForJPEG:  { datas in
                            store.send(.imagePickerData(datas.first))
                        })
                    
                }
                .navigationTitle("채널 편집")
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
                        .asButton {
                            store.send(.errorMessage(nil))
                        }
                } message: { message in
                    Text(message)
                }
                .alert(item: $store.successMessage) { _ in
                    Text("성공")
                } actions: { _ in
                    Text("확인")
                        .asButton {
                            store.send(.successMessage(nil))
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
            .onAppear  {
                store.send(.onAppear)
            }
        }
    }
}

extension ChannelEditView {
    private func channelEditContentView() -> some View {
        ZStack ( alignment: .bottom ) {
            WSXColor.lightGray
            VStack {
                // imagePick
                imagePickView()
                .padding(.top, 25)
                
                HeaderTextField(
                    headerTitle: "채널 이름",
                    placeHolder: "채널 이름을 입력하세요 (필수)",
                    isSecure: false,
                    binding: $store.channelName,
                    scopeColor: false
                )
                .padding(.vertical, 10)
                .font(WSXFont.title2)
                
                HeaderTextField(
                    headerTitle: "채널 설명",
                    placeHolder: "채널을 설명하세요. (옵션)",
                    isSecure: false,
                    binding: $store.channelIntro,
                    scopeColor: false
                )
                .font(WSXFont.title2)
                .padding(.vertical, 10)
                
                Spacer()
                
            }// VStack
            .padding(.horizontal, 20)
            
          
            SuccessButtonView(action: {
                store.send(.regButtonTapped)
            }, regButtonState: store.regButtonState)
        }
    }
}

extension ChannelEditView {
    
    private func imagePickView() -> some View {
        ZStack (alignment: .bottomTrailing) {
            CustomImagePickView(
                store: store.scope(state: \.imagePick, action: \.imagePickFeature)
            )
            .modifier(RoundProfileImageModifier(frame: CGSize(width: 80, height: 80)))
            .asButton {
                store.send(.showImagePicker)
            }
            WSXImage.subCamera
                .resizable()
                .frame(width: 25, height: 25)
        }
    }
}
