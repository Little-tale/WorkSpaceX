//
//  ProfileInfoEditView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/4/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct ProfileInfoEditView: View {
    
    @Perception.Bindable var store: StoreOf<ProfileInfoEditFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
                WSXColor.lightGray
                
                VStack {
                    HeaderTextField(
                        headerTitle: "",
                        placeHolder: store.state.editType.placeHolder,
                        isSecure: false,
                        binding: $store.currentText.sending(\.currentText),
                        scopeColor: false
                    )
                    .padding(.horizontal, 15)
                    .padding(.top, 15)
                    .font(WSXFont.title2)
                    Spacer()
                }

                SuccessButtonView(action: {
                    store.send(.regButtonTapped)
                }, regButtonState: store.regButtonState)
                
            }
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                store.send(.onAppear)
            }
            .navigationTitle(store.editType.navigationTitle)
            .alert(item: $store.errorMessage.sending(\.errorMessage)) { _ in
                Text("에러")
            } actions: { _ in
                Text("확인")
                    .asButton {
                        store.send(.errorMessage(nil))
                    }
            } message: { item in
                Text(item)
            }
            .popup(isPresented: $store.successTrigger.sending(\.successTrigger)) {
                PopupVIewSmallToColor(
                    text: "등록이 완료되었습니다.",
                    color: WSXColor.lightGreen
                )
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
                    .autohideIn(1.2)
                    .closeOnTap(false)
                    .dismissCallback {
                        store.send(.lastTrigger)
                    }
            }
        }
    }
}
