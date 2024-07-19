//
//  EmailLoginView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/8/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct EmailLoginView: View {
    
    @State var store: StoreOf<EmailLoginFeature>
    @FocusState var focus: EmailLoginFeature.Field?
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ZStack (alignment: .bottom) {
                    WSXColor.lightGray
                    
                    contentView()
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .font(WSXFont.title2)
                    
                    loginButtonView(buttonState: store.buttonState)
                        .asButton {
                            store.send(.loginButtonTapped)
                        }
                        .disabled(!store.buttonState)
                }
                .navigationTitle(
                    Text(store.emailNavTitle)
                )
                .presentationDragIndicator(.visible)
                .navigationBarTitleDisplayMode(.inline)
                .font(WSXFont.title2)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        WSXImage.xImage
                            .asButton {
                                store.send(.dismiss)
                            }
                            .foregroundStyle(WSXColor.black)
                    }
                }
                .popup(isPresented: $store.logining) {
                    ProgressView()
                        .padding(.all, 60)
                        .background(WSXColor.white)
                        .foregroundStyle(WSXColor.black)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } customize: {
                    $0
                        .closeOnTapOutside(false)
                        .closeOnTap(false)
                        .type(.default)
                        .appearFrom(.centerScale)
                        .animation(.spring)
                }
            }
        }
    }
   
    
}

extension EmailLoginView {
    
    func contentView() -> some View {
        VStack(spacing: 20) {
            HeaderTextField(
                headerTitle: "이메일",
                placeHolder: "이메일을 입력하세요",
                isSecure: false,
                binding: $store.email,
                scopeColor: false
            )
            .focused($focus, equals: .email)
            HeaderTextField(
                headerTitle: "비밀번호",
                placeHolder: "비밀번호를 입력하세요",
                isSecure: true,
                binding: $store.password,
                scopeColor: false
            )
            .focused($focus, equals: .password)
            
            loginIssueView(text: $store.loginBottomMessge)
            
            Spacer()
        }
    }
    
    
    func loginButtonView(buttonState: Bool) -> some View {
        Text("로그인")
            .font(WSXFont.title2)
            .modifier(CommonButtonModifer())
            .background(buttonState ? WSXColor.green : .inactive)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 30)
            .foregroundStyle(WSXColor.white)
            .padding(.bottom, 20)
    }
    
    func loginIssueView(text: Binding<String?>) -> some View {
        withAnimation {
            Group {
                if let string = text.wrappedValue {
                    Text(string)
                        .font(WSXFont.caption)
                        .foregroundStyle(WSXColor.errorRed)
                } else {
                    EmptyView()
                }
            }
        }
    }
}
