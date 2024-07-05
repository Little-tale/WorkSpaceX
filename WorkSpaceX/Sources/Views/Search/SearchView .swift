//
//  SerachView .swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    
    @Perception.Bindable var store: StoreOf<SerachFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                
            }
            .navigationTitle(store.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}
