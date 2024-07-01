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
                
            }
            .onAppear {
                store.send(.onAppaer)
            }
            .toolbar {
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
