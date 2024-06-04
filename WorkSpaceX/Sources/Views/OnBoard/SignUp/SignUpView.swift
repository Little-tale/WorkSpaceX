//
//  SignUpView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

struct SignUpView: View {
    
    @Perception.Bindable var store: StoreOf<SignUpFreature>
    
    var body: some View {
        
        WithPerceptionTracking {
            
            ZStack (alignment: .bottom) {
                WSXColor.lightGray
                    .ignoresSafeArea(edges: .bottom)
                VStack {
                    HStack (alignment: .bottom ,spacing: 15) {
                        
                        VStack (alignment: .leading) {
                            Text(Const.SignUpView.email.title)
                            TextField(
                                Const.SignUpView.email.placeHolder,
                                text: $store.email.sending(\.emailChanged)
                                
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
                        Text(Const.SignUpView.ninkName.title)
                        TextField(Const.SignUpView.ninkName.placeHolder,
                                  text: $store.nickName.sending(\.nicknameChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                    }
                    .padding(.horizontal, 30)
                    
                    VStack (alignment: .leading) {
                        Text(Const.SignUpView.contact.title)
                        TextField(Const.SignUpView.contact.placeHolder,
                                  text: $store.contact.sending(\.phoneNumberChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                    }
                    .padding(.horizontal, 30)
                    
                    
                    VStack (alignment: .leading) {
                        Text(Const.SignUpView.password.title)
                        TextField(Const.SignUpView.password.placeHolder,
                                  text: $store.password.sending(\.passwordChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                    }
                    .padding(.horizontal, 30)
                    
                    
                    VStack (alignment: .leading) {
                        Text(Const.SignUpView.passwordCheck.title)
                        TextField(Const.SignUpView.passwordCheck.placeHolder,
                                  text: $store.passwordConfirmaion.sending(\.passwordRepeatChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
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



