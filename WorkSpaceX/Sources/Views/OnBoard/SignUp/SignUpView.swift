//
//  SignUpView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

struct SignUpView: View {
    
    @State var store: StoreOf<SignUpFeature>
    
    @FocusState var focus: SignUpFeature.Field?
    
    var body: some View {
        
        WithPerceptionTracking {
            NavigationStack {
                ZStack (alignment: .top) {
                    WSXColor.lightGray
                        .ignoresSafeArea(edges: .bottom)
                    
                    contentView()
                    .padding(.top, 30)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            WSXImage.xImage
                                .asButton {
                                    store.send(.cancelButtonTapped)
                                }
                                .foregroundStyle(WSXColor.black)
                        }
                    }
                    .bind($store.focusField, to: $focus)
                }
                .presentationDragIndicator(.visible)
                .navigationTitle(
                    Text(store.signupNavTitle)
                )
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
     
}

extension SignUpView {
    
    private func contentView() -> some View {
        VStack (spacing: 14) {
            
            emailTextField()
            .padding(.horizontal, 30)
            /// nickName
            HeaderTextField(
                headerTitle: Const.SignUpView.nickName.title,
               
                placeHolder: Const.SignUpView.nickName.placeHolder,
                isSecure: false,
                binding: $store.user.nickName.sending(\.nicknameChanged),
                scopeColor: store.scopeAndColorChange == .nickname
                    
            )
            .focused($focus, equals: .nickname)
            .padding(.horizontal, 30)
            /// contact
            HeaderTextField(
                headerTitle: Const.SignUpView.contact.title,
                placeHolder: Const.SignUpView.contact.placeHolder,
                isSecure: false,
                binding: $store.user.contact.sending(\.contactChanged),
                scopeColor: store.scopeAndColorChange == .contact
            )
            .focused($focus, equals: .contact)
            .padding(.horizontal, 30)
            
            /// password
            HeaderTextField(
                headerTitle: Const.SignUpView.password.title,
                placeHolder: Const.SignUpView.password.placeHolder,
                isSecure: true,
                binding: $store.user.password.sending(\.passwordChanged),
                scopeColor: store.scopeAndColorChange == .password
            )
            .focused($focus, equals: .password)
            .padding(.horizontal, 30)
            
            /// passwordCheck
            HeaderTextField(
                headerTitle: Const.SignUpView.passwordCheck.title,
                placeHolder: Const.SignUpView.passwordCheck.placeHolder,
                isSecure: true,
                binding: $store.passwordConfirm.sending(\.passwordConfirmationChanged),
                scopeColor: store.scopeAndColorChange == .passwordConfirm
            )
            .focused($focus, equals: .passwordConfirm)
            .padding(.horizontal, 30)
            
            Spacer()
            // store.testButtonState
            // ifCurrectView(text: nil)
            
            StaticToastColorView(
                text: $store.presentationText.sending(\.returnView),
                color: WSXColor.green,
                duration: 1
            )
            
            regButtonView(bool: store.state.lastButtonState)
                .asButton {
                    store.send(.lastButtonTapped)
                }
                .disabled(!store.lastButtonState)
        }
    }
    
    private func emailTextField() -> some View {
        HStack (alignment: .bottom ,spacing: 15) {
            
            HeaderTextField(
                headerTitle: Const.SignUpView.email.title,
                placeHolder: Const.SignUpView.email.placeHolder,
                isSecure: false,
                binding: $store.user.email.sending(\.emailChanged),
                scopeColor: store.scopeAndColorChange == .email
            )
            .focused($focus, equals: .email)
            
            duplicateButton()
        }
    }
    
    private func duplicateButton() -> some View {
        Text("중복확인")
            .font(WSXFont.title2)
            .padding(.all, 10)
            .frame(width: 70 ,height: 50)
            .background(store.duplicateButtonState ? WSXColor.green : WSXColor.inacitve)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .asButton {
                store.send(.duplicateButtonTapped)
            }
            .disabled(!store.duplicateButtonState)
            .buttonStyle(PlainButtonStyle())
            .foregroundStyle(WSXColor.white)
    }
    
    private func regButtonView(bool: Bool) -> some View {
        Text("가입하기")
            .modifier(CommonButtonModifer())
            .background(bool ? WSXColor.green : WSXColor.gray)
            .foregroundStyle(WSXColor.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
    }
}
