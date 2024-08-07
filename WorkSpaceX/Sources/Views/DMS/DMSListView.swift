//
//  DMSListView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift

struct DMSListView: View {
    
    @Perception.Bindable var store: StoreOf<DMSListFeature>
    
    @ObservedResults(UserRealmModel.self, where: {$0.userID == UserDefaultsManager.userID ?? "" }) var userProfile
    
    var body: some View {
        WithPerceptionTracking {
            VStack{
                switch store.viewState {
                case .loading:
                    ProgressView()
                case .empty:
                    emptyMembersView()
                case .members:
                    List {
                        memberListView()
                            .listRowSeparator(.visible)
                        chatsView()
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear {
                store.send(.onAppaer)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    navigationLeftView()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    navigationTrailingView()
                        .onTapGesture {
                            store.send(.selectedMeProfile)
                        }
                }
            }
            .onDisappear {
                store.send(.onDisappear)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
extension DMSListView {
    
    private func memberListView() -> some View {
        LazyHStack {
            ForEach(store.userList, id: \.userID) { model in
                memberView(model)
                    .onTapGesture {
                        store.send(.selectedOtherUser(model))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal,8)
            }
        }
    }
    
    private func memberView(_ model: WorkSpaceMembersEntity) -> some View {
        VStack {
            Group {
                if let image = model.profileImage {
                    DownSamplingImageView(url: URL(string: image), size: ImageResizingCase.middle.size)
                } else {
                    WSXImage.profileEmpty1
                        .resizable()
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(model.nickname)
                .frame(maxWidth: 50)
                .font(WSXFont.regu2)
        }
    }
    
}
extension DMSListView {
    @ViewBuilder
    private func chatsView() -> some View {
        if store.roomList.count <= 0 {
            EmptyView()
        } else {
            LazyVStack {
                ForEach(store.roomList, id: \.roomId) { model in
                    chatView(model)
                        .onTapGesture {
                            store.send(.selectedChatRoom(model))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal,4)
                }
            }
        }
    }
    
    private func chatView(_ model: DMSRoomEntity) -> some View {
        VStack {
            Spacer()
            HStack (alignment: .top) {
               Group {
                    if let image = model.user.profileImage {
                        DownSamplingImageView(url: URL(string: image), size: ImageResizingCase.middle.size)
                    } else {
                        WSXImage.profileEmpty1
                            .resizable()
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(spacing: 2) {
                    HStack(alignment: .top) {
                        Text(model.user.nickname)
                            .font(WSXFont.title15)
                        
                        Spacer()
                        
                        VStack {
                            Text(DateManager.shared.dateToStringToRoomList(model.lastChatDate))
                                .font(WSXFont.regu1)
                        }
                    }
                    HStack(alignment: .top) {
                        lastChangeView(model.lastChat)
                            
                        Spacer()
                        unReadCountView(num: model.unReadCount)
                    }
                    Spacer()
                }
            }
            .frame(height: 45)
        }
    }
}

extension DMSListView {
    
    private func lastChangeView(_ text: String) -> some View {
        Group {
            if text.hasSuffix(".jpg") || text.hasSuffix(".png") || text.hasSuffix(".jpeg") {
                Text("이미지")
                    .font(WSXFont.regu1)
            } else if text.hasSuffix(".zip") {
                Text("ZIP 파일")
                    .font(WSXFont.regu1)
            } else if text.hasSuffix(".pdf") {
                Text("PDF 파일")
                    .font(WSXFont.regu1)
            } else {
                Text(text)
                    .font(WSXFont.regu1)
            }
        }
        .lineLimit(2)
    }
    
}


extension DMSListView {
    
    @ViewBuilder
    private func unReadCountView(num: Int) -> some View {
        if num != 0 {
            Text(String(num))
                .font(WSXFont.regu1)
                .frame(height: 24)
                .frame(minWidth: 20)
                .padding(.horizontal, 4)
                .background(WSXColor.green)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(WSXColor.white)
        } else {
            EmptyView()
        }
    }
    
}


// 나를 제외한 멤버가 없을때
extension DMSListView {
    
    private func emptyMembersView() -> some View {
        VStack {
            Text("워크 스페이스에\n멤버가 없어요.")
                .font(WSXFont.title1)
                .foregroundStyle(WSXColor.black)
                .padding(.bottom, 8)
            
            Text("새로운 팀원을 초대해 보세요!")
                .font(WSXFont.regu1)
                .foregroundStyle(WSXColor.black)
                .padding(.bottom, 8)
            
            Text("팀원 초대하기")
                .modifier(CommonButtonModifier())
                .background(WSXColor.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(WSXColor.white)
                .padding(.horizontal, 40)
                .asButton {
                    store.send(.clickedAddMember)
                }
        }
    }
    
}

// MARK: NAVIGATION
extension DMSListView {
    
    private func navigationLeftView() -> some View {
        HStack {
            Group {
                if let image = store.navigationImage {
                    DownSamplingImageView(url: URL(string: image), size: ImageResizingCase.small.size)
                } else {
                    WSXImage.logoImage
                        .resizable()
                }
            }
            .frame(width: 35, height: 35)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text("Direct Message")
                .font(WSXFont.title1)
        }
    }
    
    @ViewBuilder
    func navigationTrailingView() -> some View {
        if let userProfile = userProfile.first,
           let image = userProfile.profileImage {
            let url = URL(string: image)
            DownSamplingImageView(url: url, size: ImageResizingCase.small.size)
                .gradientProfile()
            
        } else {
            WSXImage.profileEmpty1
                .resizable()
                .gradientProfile()
        }
    }
    
}
