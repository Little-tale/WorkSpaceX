//
//  AddMemberView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/20/24.
//

import SwiftUI
import ComposableArchitecture

struct AddMemberView: View {
    
    @Perception.Bindable var store: StoreOf<AddMemberFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                ZStack ( alignment: .bottom ) {
                    WSXColor.lightGray
                    VStack {
                        HeaderTextField(
                            headerTitle: "이메일",
                            placeHolder: "초대하려는 팀원의 이름을 입력해주세요",
                            isSecure: false,
                            binding: $store.currentEmail,
                            scopeColor: false
                        )
                        .padding(.vertical, 10)
                        .font(WSXFont.title2)
                        
                        Text(store.showVaildText)
                            .font(WSXFont.caption)
                            .foregroundStyle(WSXColor.errorRed)
                            .padding(.vertical, 4)
                        
                        Spacer()
                        
                    }// VStack
                    .padding(.horizontal, 20)
                    
                    Text("초대 하기")
                        .font(WSXFont.title2)
                        .modifier(CommonButtonModifer())
                        .background(store.regButtonState ? WSXColor.green : WSXColor.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 20)
                        .padding(.bottom, keyboardPadding + 10)
                        .foregroundStyle(WSXColor.white)
                        .asButton {
                            store.send(.regButtonTapped)
                        }
                        .disabled(!store.regButtonState)
                } // ZStack
                .navigationTitle("팀원 초대")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        WSXImage.xImage
                            .asButton {
                                store.send(.dismissButtonTapped)
                            }
                            .foregroundStyle(WSXColor.black)
                    }
                }
                .alert(item: $store.errorMessage) { _ in
                    Text("에러 발생")
                } actions: { _ in
                    Text("확인")
                        .asButton {
                            store.send(.errorMessage(nil))
                        }
                } message: { message in
                    Text(message)
                }
                .alert(item: $store.successMessage) { _ in
                    Text("성공")
                } actions: { _ in
                    Text("확인")
                        .asButton {
                            store.send(.successMessage(nil))
                            store.send(.alertSuccessTapped)
                        }
                } message: { message in
                    Text(message)
                }
                
                
                
                if store.showPrograssView {
                    ProgressView()
                        .centerOverlay(size: CGSize(width: 120, height: 120))
                }
            }
        }
    }
}

