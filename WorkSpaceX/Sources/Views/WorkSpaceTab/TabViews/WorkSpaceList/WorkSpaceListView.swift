//
//  WorkSpaceListVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceListView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceListFeature>
    
    var body: some View {
        Text("home")
    }
}
