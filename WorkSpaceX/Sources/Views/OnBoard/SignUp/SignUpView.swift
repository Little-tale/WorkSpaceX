//
//  SignUpView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

struct SignUpView: View {
    
    @Perception.Bindable var store: StoreOf<SignUpFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            ZStack (alignment: .top) {
                WSXColor.lightGray
                    .ignoresSafeArea(edges: .bottom)
                VStack (spacing: 14) {
                    
                    HStack (alignment: .bottom ,spacing: 15) {
                        
                        HeaderTextField(
                            headerTitle: Const.SignUpView.email.title,
                            ifValidText: nil,
                            placeHolder: Const.SignUpView.email.placeHolder,
                            isSecure: false,
                            binding: $store.user.email.sending(\.emailChanged)
                        )
                        
                        Text("중복확인")
                            .font(WSXFont.title2)
                            .padding(.all, 10)
                            .frame(width: 70 ,height: 50)
                            .background(store.duplicateButtonState ? WSXColor.green : WSXColor.inacitve)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .asButton {
                                
                            }
                            .disabled(!store.duplicateButtonState)
                            .buttonStyle(PlainButtonStyle())
                            .foregroundStyle(WSXColor.white)
                    }
                    .padding(.horizontal, 30)
                    
                    HeaderTextField(
                        headerTitle: Const.SignUpView.nickName.title,
                        ifValidText: nil,
                        placeHolder: Const.SignUpView.nickName.placeHolder,
                        isSecure: false,
                        binding: $store.user.nickName.sending(\.nicknameChanged)
                    )
                    .padding(.horizontal, 30)
                    
                    HeaderTextField(
                        headerTitle: Const.SignUpView.contact.title,
                        ifValidText: nil,
                        placeHolder: Const.SignUpView.contact.placeHolder,
                        isSecure: false,
                        binding: $store.user.contact.sending(\.contactChanged)
                    )
                    .padding(.horizontal, 30)
                    
                    
                    HeaderTextField(
                        headerTitle: Const.SignUpView.password.title,
                        ifValidText: nil,
                        placeHolder: Const.SignUpView.password.placeHolder,
                        isSecure: true,
                        binding: $store.user.password.sending(\.passwordChanged)
                    )
                    .padding(.horizontal, 30)
                    
                    HeaderTextField(
                        headerTitle: Const.SignUpView.passwordCheck.title,
                        ifValidText: "비밀번호 양식이 맞지 않아요",
                        placeHolder: Const.SignUpView.passwordCheck.placeHolder,
                        isSecure: true,
                        binding: $store.passwordConfirm.sending(\.passwordConfirmationChanged)
                    )
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    // store.testButtonState
                    ifCurrectView(text: nil)
                    
                    regButtonView(bool: store.state.testButtonState)
                        .asButton {
                            
                        }
                        .disabled(!store.testButtonState)
                }
                .padding(.top, 30)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        WSXImage.xImage
                            .asButton {
                                print("asas")
                                store.send(.cancelButtonTapped)
                            }
                            .foregroundStyle(WSXColor.black)
                    }
                }
            }
        }
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
    
    private func ifCurrectView(text: String?) -> some View {
        // 각 버튼별로 로직이 다름을 생각해야함.
        // 이친구는 Text를 받아야 할것 같음
        withAnimation {
            Group {
                if let text {
                    Text(text)
                        .padding(.horizontal, 10)
                        .frame(height: 40)
                        .foregroundStyle(WSXColor.white)
                        .font(WSXFont.bodyBold)
                        .background(WSXColor.green)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    EmptyView()
                }
            }
        }
    }
    
}
