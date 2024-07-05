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
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(store.navigationTitle)
            .searchable(
                text: $store.searchText.sending(\.searchText),
                prompt: store.searchText
            )
            .alert(
                item: $store.alertCase.sending(\.alertCase)) { item in
                    Text(item.title)
                } actions: { item in
                    Text(item.actionTitle)
                        .asButton {
                            store.send(.alertCase(nil))
                        }
                } message: { item in
                    Text(item.message)
                }
        }
    }
}


extension SearchView {
    
    private func searchResultView() -> some View {
        List {
            if !store.channels.isEmpty {
                
            }
            if !store.members.isEmpty {
                
            }
        }
    }
    
}
