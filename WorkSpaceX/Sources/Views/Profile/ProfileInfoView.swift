//
//  ProfileInfoView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/3/24.
//

import SwiftUI
import ComposableArchitecture

struct ProfileInfoView: View {
    
    @Perception.Bindable var store: StoreOf<ProfileInfoFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                Spacer()
                
            }
            .onAppear {
                store.send(.onAppaer)
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }
}
