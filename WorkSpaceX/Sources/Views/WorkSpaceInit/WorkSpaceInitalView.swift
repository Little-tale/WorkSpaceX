//
//  WorkSpaceInitalView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceInitalView: View {
        
    @Perception.Bindable var store: StoreOf<WorkSpaceInitalFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    CustomeImagePickView(
                     store: store.scope(state: \.imagePick, action: \.imagePickFeature)
                    )
                    .asButton {
                        
                    }
                }
               
            }
            .navigationTitle("워크스페이스 생성")
            
        }
    }
}

#Preview {
    WorkSpaceInitalView(
        store: Store(initialState: WorkSpaceInitalFeature.State(), reducer: {
            WorkSpaceInitalFeature()
        })
    )
}
