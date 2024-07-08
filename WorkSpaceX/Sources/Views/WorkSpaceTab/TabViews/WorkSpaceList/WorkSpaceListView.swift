//
//  WorkSpaceListVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift

struct WorkSpaceListView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceListFeature>
    
    @ObservedResults(UserRealmModel.self, where: {$0.userID == UserDefaultsManager.userID ?? "" }) var userProfile
    
    @State var channelToggle: Bool = false
    
    @State var directedToggle: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                List {
                    Section {
                        if channelToggle {
                            ForEach(store.chanelSection.items, id: \.channelID) { item in
                                channelContents(model: item)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                            }
                            channelAddView()
                                .listRowInsets(EdgeInsets())
                                .alignmentGuide(.listRowSeparatorLeading) { vd in
                                    print(vd.width)
                                    return -vd.width
                                }
                        }
                    } header: {
                        chanelHeader()
                    }.background  {
                        WSXColor.white
                    }
                    Section { 
                        if directedToggle {
                            ForEach(store.dmsRoomSection.items, id: \.roomId) { model in
                                directMessgageView(model)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                            }
                            newDMSStartView()
                                .listRowInsets(EdgeInsets())
                                .alignmentGuide(.listRowSeparatorLeading) { vd in
                                    print(vd.width)
                                    return -vd.width
                                }
                        }
                    } header: {
                        dmsHeader()
                    }.background  {
                        WSXColor.white
                    }
                    
                    teamMemberAddView()
                        .listRowInsets(EdgeInsets())
                        .alignmentGuide(.listRowSeparatorLeading) { vd in
                            print(vd.width)
                            return -vd.width
                    }
                    
                }
                .listStyle(.plain)
            }
            .onAppear {
                store.send(.onAppear)
            }
            .confirmationDialog($store.scope(state: \.alert, action: \.alertSheet))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        if let image = store.workSpaceCoverImage {
                            DownSamplingImageView(url: image, size: ImageResizingCase.small.size)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        
                        Text(store.workSpaceName ?? "Loading")
                            .font(WSXFont.title1)
                            .foregroundGrdientTo(gradient: WSXColor.titleGradient)
                            .asButton {
                                store.send(.openSideMenu)
                            }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    navigationTrailingView()
                        .asButton {
                            store.send(.selectedProfileImageView)
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    @ViewBuilder
    func navigationTrailingView() -> some View {
        if let userProfile = userProfile.first,
           let image = userProfile.profileImage {
            
            let url = URL(string: image)
            DownSamplingImageView(url: url, size: ImageResizingCase.small.size)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
        } else {
            WSXImage.profileEmpty1
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
        }
    }
    
    private func chanelHeader() -> some View {
        HStack {
            Text(store.chanelSection.name)
                .font(WSXFont.title15)
                .foregroundStyle(WSXColor.black)
            Spacer()
            Image(systemName: channelToggle ? "chevron.down" : "chevron.right")
                .asButton {
                    withAnimation {
                        channelToggle.toggle()
                    }
                }
        }
        .frame(height: 30)
    }
    
    private func channelContents(model: WorkSpaceChannelEntity) -> some View {
        HStack {
            WSXImage.shapThin
                .resizable()
                .foregroundStyle(WSXColor.gray)
                .frame(width: 14, height: 14)
                .padding(.leading, 10)
            
            Text(model.name)
                .font(WSXFont.title2)
                .foregroundStyle(WSXColor.black)
                .padding(.horizontal, 4)
            
            Spacer()
            
            unReadCountView(num: model.didNotReadCount)
                .padding(.trailing, 5)
            
        }
        .frame(height: 30)
        .asButton {
            store.send(.selectedChannel(model))
        }
    }
    
    private func dmsHeader() -> some View {
        HStack {
            Text(store.dmsRoomSection.name)
                .font(WSXFont.title15)
                .foregroundStyle(WSXColor.black)
            Spacer()
            Image(systemName: directedToggle ? "chevron.down" : "chevron.right")
                .asButton {
                    withAnimation {
                        directedToggle.toggle()
                    }
                }
        }
        .frame(height: 30)
    }
    
    private func directMessgageView (_ model: DMSRoomEntity) -> some View {
        
        HStack {
            if let userProfile = model.user.profileImage {
                DownSamplingImageView(url: URL(string: userProfile), size: ImageResizingCase.small.size)
                    .frame(width: 20, height: 20)
                    .padding(.leading, 10)
            } else {
                WSXImage.profileEmpty1
                    .resizable()
                    .foregroundStyle(WSXColor.gray)
                    .frame(width: 20, height: 20)
                    .padding(.leading, 10)
            }
            
            Text(model.user.nickname)
                .font(WSXFont.title2)
                .foregroundStyle(WSXColor.black)
                .padding(.horizontal, 4)
            
            unReadCountView(num: model.unReadCount)
                .padding(.trailing, 5)
            Spacer()
        }
        .frame(height: 30)
        .asButton {
            store.send(.selectedRoom(model))
        }
    }
    
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
    
    
    private func channelAddView() -> some View {
        HStack {
            WSXImage.plus.renderingMode(.template)
                .resizable()
                .foregroundStyle(WSXColor.gray)
                .frame(width: 14, height: 14)
            Text("채널 추가")
                .font(WSXFont.title2)
                .foregroundStyle(WSXColor.gray)
                .asButton {
                    store.send(.showAlertSheet)
                }
            Spacer()
        }
        .padding(.leading, 10)
        .frame(height: 30)
    }
    
    private func newDMSStartView() -> some View {
        HStack {
            WSXImage.plus.renderingMode(.template)
                .resizable()
                .foregroundStyle(WSXColor.gray)
                .frame(width: 14, height: 14)
            Text("새 메시지 시작")
                .font(WSXFont.title2)
                .foregroundStyle(WSXColor.gray)
                .asButton {
                    // 메시지 추가 로직 구성해야함.
                    store.send(.selectedNewChannel)
                }
            Spacer()
        }
        .padding(.leading, 10)
        .frame(height: 30)
    }
    
    private func teamMemberAddView() -> some View {
        HStack {
            WSXImage.plus
                .resizable()
                .foregroundStyle(WSXColor.gray)
                .frame(width: 14, height: 14)
                .padding(.leading, 10)
            
            Text("팀원 추가")
                .font(WSXFont.title2)
                .foregroundStyle(WSXColor.black)
                .padding(.horizontal, 4)
                .asButton {
                    store.send(.addMemberClicked)
                }
            Spacer()
        }
        .frame(height: 30)
    }
    
}


//#Preview {
//    WorkSpaceListView(store: Store(initialState: WorkSpaceListFeature.State(), reducer: {
//        WorkSpaceListFeature()
//    }))
//}
