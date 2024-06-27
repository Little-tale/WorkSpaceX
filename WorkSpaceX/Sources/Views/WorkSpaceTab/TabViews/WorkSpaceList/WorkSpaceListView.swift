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
                        teamMemberAddView()
                            .listRowInsets(EdgeInsets())
                            .alignmentGuide(.listRowSeparatorLeading) { vd in
                                print(vd.width)
                                return -vd.width
                            }
                    } header: {
                        chanelHeader()
                    }.background  {
                        WSXColor.white
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
                            DownSamplingImageView(url: image, size: CGSize(width: 40, height: 40))
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
                    if let userProfile = userProfile.first,
                       let image = userProfile.profileImage {
                        
                        let url = URL(string: image)
                        DownSamplingImageView(url: url, size: CGSize(width: 30, height: 30))
                            .clipShape(Circle())
                    } else {
                        WSXImage.profileEmpty1
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                }
            }
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
        }
        .frame(height: 30)
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
