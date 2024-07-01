//
//  DMSListView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import SwiftUI
import ComposableArchitecture

struct DMSListView: View {
    
    @Perception.Bindable var store: StoreOf<DMSListFeature>
    
    var body: some View {
        WithPerceptionTracking {
            
        }
    }
}
