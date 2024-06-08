//
//  EmailLoginView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/8/24.
//

import SwiftUI
import ComposableArchitecture

struct EmailLoginView: View {
    
    @State var store: StoreOf<EmailLoginFeature>
    @FocusState var focus: EmailLoginFeature.Field?
    
    var body: some View {
        WithPerceptionTracking {
            ZStack (alignment: .bottom) {
                WSXColor.lightGray
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
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .font(WSXFont.title2)
                
                loginIssueView(text: $store.loginBottomMessge)
                
                loginButtonView(buttonState: store.buttonState)
                    .asButton {
                        print("버튼")
                    }
                    .disabled(!store.buttonState)
            }
          
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    WSXImage.xImage
                        .asButton {
                            store.send(.dismiss)
                        }
                        .foregroundStyle(WSXColor.black)
                }
            }
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
        Group {
            if let string = text.wrappedValue {
                Text(string)
            } else {
                EmptyView()
            }
        }
    }
    
}
