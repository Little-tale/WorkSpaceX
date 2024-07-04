//
//  ProfileInfoEditView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/4/24.
//

import SwiftUI
import ComposableArchitecture

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
                Text("완료")
                    .font(WSXFont.title2)
                    .modifier(CommonButtonModifer())
                    .background(store.buttonState ? WSXColor.green : WSXColor.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 20)
                    .padding(.bottom, keyboardPadding + 10)
                    .foregroundStyle(WSXColor.white)
                    .asButton {
                        store.send(.regButtonTapped)
                    }
                    .disabled(!store.buttonState)
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationTitle(store.editType.navigationTitle)
        }
    }
}
