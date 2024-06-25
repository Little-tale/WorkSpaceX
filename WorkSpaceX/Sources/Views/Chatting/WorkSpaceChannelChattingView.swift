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
    
    @State var scrollTo: String = ""
    @State var keyboardTool: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEachStore(store.scope(state: \.chatStates, action: \.chats)) { store in
                                ChatModeView(store: store)
                                    .id(store.model.chatID)
                            }
                        }
                        .rotationEffect(.degrees(180))
                        // 확실히 이것이 문제가 맞음
                        .onChange(of: scrollTo) { new in
                            proxy.scrollTo(new)
                        }
                        .bind($store.scrollTo.sending(\.onChangeForScroll), to: $scrollTo)
                    }
                    .rotationEffect(.degrees(180))
                }
                
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
            .fullScreenCover(isPresented: $store.imagePickerTrigger.sending(\.imagePickerBool)){
                CustomImagePicker(
                    isPresented: $store.imagePickerTrigger.sending(\.imagePickerBool),
                    selectedLimit: store.dataCanCount,
                    filter: .images,
                    selectedDataForJPEG:  { datas in
                        store.send(.imageDataPicks(datas))
                    })
            }
        }
    }
}

extension WorkSpaceChannelChattingView {
    
    func chatTextField() -> some View {
        WithPerceptionTracking {
            Group {
                workSpaceToolView()
                workSpaceTextField()
            }
        }
    }
    
}
extension WorkSpaceChannelChattingView {
    
    func workSpaceTextField() -> some View {
        WithPerceptionTracking {
            VStack {
                VStack {
                    HStack {
                        WSXImage.plus
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(WSXColor.black)
                            .padding(.leading, 8)
                            .asButton {
                                keyboardTool.toggle()
                            }
                        VStack {
                            TextField("메시지를 입력하세요", text: $store.userFeildText.sending(\.userFeildText))
                        }
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
                    if store.showChatBottom {
                        workSpaceChatBottomItemView()
                            .padding(.bottom, 4)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(WSXColor.black.opacity(0.1))
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            }
        }
    }
}

/// 데이터에 따른 스택 뷰 준비
extension WorkSpaceChannelChattingView {
    
    private func workSpaceChatBottomItemView() -> some View {
        WithPerceptionTracking {
            withAnimation {
                HStack {
                    ForEach(Array(store.currentDatas.enumerated()), id: \.element.fileName) { index, item in
                        ZStack(alignment: .topTrailing) {
                            workSpaceChatFileCaseView(file: item)
                                .frame(width: 45, height: 45)
                            
                            WSXImage.xImage
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 10, height: 10)
                                .padding(.all, 4)
                                .background {
                                    WSXColor.white
                                }
                                .clipShape(
                                    Circle()
                                )
                                .overlay(
                                    Circle()
                                        .stroke(WSXColor.black.opacity(0.8), lineWidth: 1)
                                )
                                .padding(.top, -4)
                                .padding(.trailing, -4)
                                .asButton {
                                    store.send(.dataRemoveToIndex(index))
                                }
                        }
                        
                    }
                }
                .frame(height: 50)
            }
            .transition(.scale)
            .animation(.easeInOut, value: store.showChatBottom)
        }
    }
    private func workSpaceChatFileCaseView(file: ChatMultipart.File) -> some View {
        WithPerceptionTracking {
            switch file.fileType {
            case .image:
                Image(uiImage: UIImage(data: file.data) ?? UIImage(systemName: "questionmark")!)
                    .resizable()
            case .pdf:
                VStack {
                    Image(systemName: "doc.richtext")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .background(WSXColor.white)
                    Text(file.fileName)
                }
                .font(WSXFont.caption)
            case .zip:
                VStack {
                    Image(systemName: "doc.zipper")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .background(WSXColor.white)
                    Text(file.fileName)
                }
                .font(WSXFont.caption)
            default:
                Image(systemName: "questionmark")
                    .resizable()
            }
        }
    }
    
    
}


extension WorkSpaceChannelChattingView {
    
    private func workSpaceToolView() -> some View {
        WithPerceptionTracking {
            withAnimation {
                HStack {
                    HStack(spacing: 10) {
                        // 이미지 먼저 후 -> PDF, 등의 파일 처리
                        if keyboardTool {
                            VStack(alignment: .center) {
                                WSXImage.gallary
                                    .sideImage()
                                Text("이미지")
                                    .font(WSXFont.regu1)
                            }
                            .padding(.leading, 10)
                            .padding(.vertical, 5)
                            .asButton {
                                keyboardTool.toggle()
                                store.send(.showImagePicker)
                            }
                        }
                        Spacer()
                    }
                    .background(WSXColor.white)
                }
                .transition(.scale)
                .animation(.easeInOut, value: keyboardTool)
            }
        }
        
    }
}
