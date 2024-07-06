//
//  StoreListView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct StoreListView: View {
    
    @Perception.Bindable var store: StoreOf<StoreListFeature>
    
   
    var body: some View {
        WithPerceptionTracking {
            VStack {
                List {
                    currentCoinView()
                    
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .popup(item: $store.explainState.sending(\.exPlainBind)) { item in
                CustomExPlainView( item: item ) {
                    store.send(.explinShow(false))
                    }
            } customize: {
                $0
                    .appearFrom(.centerScale)
                    .closeOnTap(false)
                    .backgroundColor(WSXColor.black.opacity(0.4))
            }

        }
    }
}

extension StoreListView {
    
    private func currentCoinView() -> some View {
        VStack {
            HStack {
                WSXImage.Coin.mini
                    .image
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("현재 보유한 코인")
                    .font(WSXFont.title15)
                Text(String(store.currentCoinCount))
                    .foregroundStyle(WSXColor.green)
                    .font(WSXFont.title15)
                Spacer()
                Text("코인이란?")
                    .font(WSXFont.regu1)
                    .onTapGesture {
                        store.send(.explinShow(true))
                    }
            }
        }
    }
    
}
