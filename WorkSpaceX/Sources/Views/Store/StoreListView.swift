//
//  StoreListView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/6/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView
import iamport_ios

struct StoreListView: View {
    
    @Perception.Bindable var store: StoreOf<StoreListFeature>
    
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                List {
                    currentCoinView()
                    withAnimation {
                        Group {
                            switch store.storeViewState {
                            case .loading:
                                ProgressView()
                            case .show:
                                currentCoinItemView()
                                
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $store.paymentBool.sending(\.paymentBool)) {
                IamportPaymentView(
                    iamPort: $store.paymentModel.sending(\.paymentModel),
                    userCode: store.userCode) { response in
                        store.send(.paymentResponse(response))
                    } onClose: {
                        store.send(.paymentBool(false))
                    }
            }
            .navigationTitle(store.navigationTitle)
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                store.send(.onAppear)
            }
            .alert(item: $store.alertCase.sending(\.alertCase), title: { model in
                Text(model.title)
            }, actions: { model in
                Text("확인")
                    .asButton {
                        store.send(.alertCase(nil))
                    }
            }, message: { model in
                Text(model.message)
            })
            .popup(item: $store.explainState.sending(\.exPlainBind)) { item in
                CustomExPlainView( item: item ) {
                    store.send(.explainShow(false))
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
    
    private func currentCoinItemView() -> some View {
        ForEach(store.currentCoinItems, id: \.self) { item in
            Section {
                currentCoinItemView(item)
            }
        }
    }
    
    private func currentCoinItemView(_ item: StoreItemEntity) -> some View {
        VStack {
            HStack{
                Spacer()
                itemImage(amount: item.amount)
                    .frame(width: 150, height: 150)
                Spacer()
            }
            Text(item.item)
                .font(WSXFont.title1)
                
            Text(item.amount + " 원")
                .font(WSXFont.title2)
                .frame(width: 120, height: 40)
                .background(WSXColor.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(WSXColor.white)
                .onTapGesture {
                    store.send(.selectedItem(item))
                }
      
        }
    }
    
    @ViewBuilder
    private func itemImage(amount: String) -> some View {
        if let amount = Int(amount) {
            if amount < 500 {
                WSXImage.Coin.mini.image
                    .resizable()
            } else if amount > 500 {
                WSXImage.Coin.big.image
                    .resizable()
            } else {
                WSXImage.Coin.middel.image
                    .resizable()
            }
        } else {
            EmptyView()
        }
    }
    
    private func currentCoinView() -> some View {
        Section {
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
                        store.send(.explainShow(true))
                    }
            }
        }
    }
}

