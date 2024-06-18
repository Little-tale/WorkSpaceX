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
    
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Text("home")
            }
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
}


//#Preview {
//    WorkSpaceListView(store: Store(initialState: WorkSpaceListFeature.State(), reducer: {
//        WorkSpaceListFeature()
//    }))
//}
