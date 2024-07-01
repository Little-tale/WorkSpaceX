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
                List {
                    memberListView()
                    
                }
                .listStyle(.plain)
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
                }
            }
        }
    }
}
extension DMSListView {
    
    private func memberListView() -> some View {
        LazyHStack {
            ForEach(store.userList, id: \.userID) { model in
                memberView(model)
                    .padding(.vertical, 6)
                    .padding(.horizontal,8)
            }
        }
    }
    
    private func memberView(_ model: WorkSpaceMembersEntity) -> some View {
        VStack {
            Group {
                if let image = model.profileImage {
                    DownSamplingImageView(url: URL(string: image), size: CGSize(width: 50, height: 50))
                } else {
                    WSXImage.profileEmpty1
                        .resizable()
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(model.nickname)
                .frame(maxWidth: 50)
                .font(WSXFont.regu1)
        }
    }
    
}

// NAVIGATION
extension DMSListView {
    
    private func navigationLeftView() -> some View {
        HStack {
            Group {
                if let image = store.navigationImage {
                    DownSamplingImageView(url: URL(string: image), size: CGSize(
                        width: 50,
                        height: 50
                    ))
                } else {
                    WSXImage.logoImage
                        .resizable()
                }
            }
            .frame(width: 30, height: 30)
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
