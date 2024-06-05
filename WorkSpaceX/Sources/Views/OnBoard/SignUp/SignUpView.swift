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
            ZStack (alignment: .bottom) {
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
                        Text(Const.SignUpView.contact.title)
                        TextField(
                            Const.SignUpView.contact.placeHolder,
                            text: $store.user.contact.sending(\.contactChanged)
                        )
                        .modifier(DefaultTextFieldViewModifier())
                    }
                    .padding(.horizontal, 30)
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



/*
 HStack (alignment: .bottom ,spacing: 15) {
 
 VStack (alignment: .leading) {
 Text(field.title)
 TextField(
 field.placeHolder,
 text: viewStore.binding(
 get: {$0.userInfo.email},
 send: field.action
 )
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
 */
