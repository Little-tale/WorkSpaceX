//
//  WorkSpaceChannelChattingView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import SwiftUI
import ComposableArchitecture

/*
 proxy 이슈가 있음. 여전히 원인은 알수가 없음
 */

struct WorkSpaceChannelChattingView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceChannelChattingFeature>
    
//    @State var scrollTo: String = ""
    @State var keyboardTool: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            
            VStack {
                ScrollViewReader { proxy in
                    WithPerceptionTracking {
                        ScrollView {
                            LazyVStack {
                                
                                ForEach(store.currentModels, id: \.testID) { send in
                                    ChatModeView(
                                        setModel: send,
                                        profileClicked: { reModel in
                                            
                                        },
                                        fileClicked: { urlString in
                                            
                                        }
                                    )
                                }
                            }
                            .rotationEffect(.radians(.pi))
                            .scaleEffect(x: -1, y: 1, anchor: .center)
                        }
                    }
                    .rotationEffect(.radians(.pi))
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                    
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
                ToolbarItem(placement: .topBarTrailing) {
                    WSXImage.hambergerList
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(WSXColor.black)
                        .asButton {
                            store.send(.listButtonTapped)
                        }
                }
            }
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
            .alert(item: $store.errorMessage.sending(\.errorMessage), title: { _ in
                Text("경고")
            }, actions: { _ in
                Text("확인")
                    .font(WSXFont.title15)
                    .asButton {
                        store.send(.errorMessage(nil))
                    }
            }, message: { message in
                Text(message)
                    .font(WSXFont.title15)
            })
            .fullScreenCover(isPresented: $store.imagePickerTrigger.sending(\.imagePickerBool)){
                CustomImagePicker(
                    isPresented: $store.imagePickerTrigger.sending(\.imagePickerBool),
                    selectedLimit: store.dataCanCount,
                    filter: .images,
                    selectedDataForJPEG:  { datas in
                        store.send(.imageDataPicks(datas))
                    })
            }
            .sheet(isPresented: $store.filePickerTrigger.sending(\.filePickerBool)) {
                CustomDataPicker(
                    isPresented: $store.filePickerTrigger.sending(\.filePickerBool),
                    selectedLimit: store.dataCanCount) { dataURLs in
                        store.send(.filePickerResults(dataURLs))
                    } ifNeedRemitOver: {
                        store.send(.filePickOver)
                    }
                EmptyView()
                    .presentationDetents([.large])
            }

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
                        TextField("메시지를 입력하세요", text: $store.userFeildText.sending(\.userFeildText), axis: .vertical)
                            .lineLimit(4)
                            .padding(.vertical, 2)
                    }
                    .frame(minHeight: 50)
                    
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

/// 데이터에 따른 스택 뷰 준비
extension WorkSpaceChannelChattingView {
    
    private func workSpaceChatBottomItemView() -> some View {
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
    @ViewBuilder
    private func workSpaceChatFileCaseView(file: ChatMultipart.File) -> some View {
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


extension WorkSpaceChannelChattingView {
    
    private func workSpaceToolView() -> some View {
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
                        VStack(alignment: .center) {
                            WSXImage.folder
                                .sideImage()
                            Text("파일")
                                .font(WSXFont.regu1)
                        }
                        .padding(.leading, 10)
                        .padding(.vertical, 5)
                        .asButton {
                            keyboardTool.toggle()
                            store.send(.showFilePicker)
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
//                            ForEachStore(store.scope(state: \.chatStates, action: \.chats)) { store in
//                                ChatModeView(store: store)
////                                    .id(store.model.chatID)
//                            }
//                            ForEach(store.currentModels,  id: \.chatId ) { model in
//                                EmptyView()
//                            }
// 확실히 이것이 문제가 맞음
//                        .onChange(of: scrollTo) { new in
//                            proxy.scrollTo(new)
//
//                        }
//                        .onChange(of: store.scrollTo) { new in
//                            proxy.scrollTo(new)
//                        }
// 해당 것도 추적이 안된다는 것으로 나옴...
//                        .bind($store.scrollTo.sending(\.onChangeForScroll), to: $scrollTo)
