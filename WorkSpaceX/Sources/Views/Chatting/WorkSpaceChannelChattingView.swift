//
//  WorkSpaceChannelChattingView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceChannelChattingView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceChannelChattingFeature>
    
    @State var openKeyboardInfo: Bool = false
    @State var openImagePicker: Bool = false
    
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("채팅뷰 탸다~")
                Spacer()
                chatTextField()
            }
            .onAppear {
                store.send(.onAppear)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    WSXImage.back
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(WSXColor.black)
                        .asButton {
                            store.send(.popClicked)
                        }
                }
                ToolbarItem(placement: .principal) {
                    HStack {
                        WSXImage.shapBold
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(WSXColor.black)
                        
                        Text(store.navigationTitle)
                            .font(WSXFont.title1)
                        
                        Text(store.navigationMemberCount)
                            .font(WSXFont.regu1)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

extension WorkSpaceChannelChattingView {
    
    func chatTextField() -> some View {
        Group {
            workSpaceToolView()
            workSpaceTextField()
        }
    }
    
}
extension WorkSpaceChannelChattingView {
    func workSpaceTextField() -> some View {
        HStack {
            HStack {
                WSXImage.plus
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(WSXColor.black)
                    .padding(.leading, 8)
                    .asButton {
                        openKeyboardInfo.toggle()
                    }
                TextField("메시지를 입력하세요", text: $store.userFeildText.sending(\.userFeildText))
                WSXImage.send
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .asButton {
                        store.send(.sendTapped)
                    }
                    .padding(.trailing, 5)
            }
            .frame(height: 50)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(WSXColor.black.opacity(0.1))
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
    }
}


extension WorkSpaceChannelChattingView {
    
    private func workSpaceToolView() -> some View {
        withAnimation {
            HStack {
                HStack(spacing: 10) {
                    // 이미지 먼저 후 -> PDF, 등의 파일 처리 
                    if openKeyboardInfo {
                        WSXImage.gallary
                            .sideImage()
                            .asButton {
                                openImagePicker.toggle()
                            }
                            .padding(.leading, 10)
                            .padding(.vertical, 5)
                    }
                    Spacer()
                }
                .background(WSXColor.white)
            }
            .transition(.scale)
            .animation(.easeInOut,value: openKeyboardInfo)
        }
    }
    
    
}
