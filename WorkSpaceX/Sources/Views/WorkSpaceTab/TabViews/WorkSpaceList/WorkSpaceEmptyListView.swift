//
//  WorkSpaceEmptyListView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift

struct WorkSpaceEmptyListView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceEmptyListFeature>
    
    @ObservedResults(UserRealmModel.self, where: {$0.userID == UserDefaultsManager.userID ?? "" }) var userProfile
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                contentView()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("No WorkSpace")
                            .font(WSXFont.title1)
                            .foregroundGrdientTo(gradient: WSXColor.titleGradient)
                            .asButton {
                                store.send(.openSideMenu)
                            }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if let userProfile = userProfile.first,
                           let image = userProfile.profileImage {
                            
                            let url = URL(string: image)
                            DownSamplingImageView(url: url, size: ImageResizingCase.small.size)
                                .clipShape(Circle())
                        } else {
                            WSXImage.profileEmpty1
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        }
                        // 여기에 이미지 추가
                    }
                }
                
            }
        }
    }
}

extension WorkSpaceEmptyListView {
    
    private func contentView() -> some View {
        VStack {
            Text(store.state.title)
                .font(WSXFont.title0)
                .padding(.top, 20)
            Text(store.state.message)
                .font(WSXFont.bodyBold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
            WSXImage.emptyImage
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .centered()
            
            Spacer()
            
            workSpaceMakeButton()
                .sheet(item: $store.scope(state: \.worSpaceIniter, action: \.sendWorkSpaceInit)) { store in
                    WorkSpaceInitalView(store: store)
                }
        }
    }
    
    private func workSpaceMakeButton() -> some View {
        Text("워크 스페이스 생성")
            .font(WSXFont.title2)
            .modifier(CommonButtonModifer())
            .background(WSXColor.green)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 20)
            .padding(.horizontal, 30)
            .foregroundStyle(WSXColor.white)
            .asButton {
                store.send(.startButtonTapped)
            }
            .buttonStyle(PlainButtonStyle())
    }
    
   
}

