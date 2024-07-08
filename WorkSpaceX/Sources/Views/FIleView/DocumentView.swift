//
//  DocumentVIew.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import SwiftUI
import ComposableArchitecture

struct DocumentView: View {

    @Perception.Bindable var store: StoreOf<DocumentFeature>
    
    var body: some View {
        CustomDocumentInteractionController(url: store.url)
            .ignoresSafeArea(.all)
    }
}
