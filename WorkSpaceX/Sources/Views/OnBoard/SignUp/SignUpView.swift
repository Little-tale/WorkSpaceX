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
                VStack (spacing: 16) {
                    HStack (alignment: .bottom ,spacing: 15) {
                        VStack (alignment: .leading) {
                            Text(Const.SignUpView.email.title)
                            TextField(
                                Const.SignUpView.email.placeHolder,
                                text: $store.user.email.sending(\.emailChanged)
                                
                            )
                            .modifier(DefaultTextFieldViewModifier())
                        }
                        
                        Text("중복확인")
                            .font(WSXFont.title2)
                            .padding(.all, 10)
                            .frame(width: 70 ,height: 50)
                            .background(WSXColor.inacitve)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .asButton {
                                
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundStyle(WSXColor.white)
                    }
                    .padding(.horizontal, 30)
                    
                    VStack (alignment: .leading) {
                        Text(Const.SignUpView.nickName.title)
                        TextField(
                            Const.SignUpView.nickName.placeHolder,
                            text: $store.user.nickName.sending(\.nicknameChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                    }
                    .padding(.horizontal, 30)
                    
                    VStack (alignment: .leading) {
                        Text(Const.SignUpView.contact.title)
                        TextField(
                            Const.SignUpView.contact.placeHolder,
                            text:
                                $store.user.contact.sending(\.contactChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                    }
                    .padding(.horizontal, 30)
                    
                    VStack (alignment: .leading) {
                        Text(Const.SignUpView.password.title)
                        SecureField(
                            Const.SignUpView.password.placeHolder,
                            text: $store.user.password.sending(\.passwordChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                        
                    }
                    .padding(.horizontal, 30)
                    
                    VStack (alignment: .leading) {
                        Text(Const.SignUpView.passwordCheck.title)
                        SecureField(
                            Const.SignUpView.passwordCheck.placeHolder,
                            text: $store.passwordConfirm.sending(\.passwordConfirmationChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                        
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Text("사용 가능한 이메일 입니다.")
                        .frame(height: 40)
                        .padding(.horizontal, 60)
                        .background(.green)
                    Text("가입하기")
                        .modifier(CommonButtonModifer())
                        .background(WSXColor.gray)
                        .foregroundStyle(WSXColor.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
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
}
