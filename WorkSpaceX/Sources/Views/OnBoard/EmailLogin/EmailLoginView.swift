//
//  EmailLoginView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/8/24.
//

import SwiftUI
import ComposableArchitecture

struct EmailLoginView: View {
    
    @State
    var text: String = ""
    
    @State var store: StoreOf<EmailLoginFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack (alignment: .bottom) {
                WSXColor.lightGray
                VStack(spacing: 20) {
                    HeaderTextField(
                        headerTitle: "이메일",
                        placeHolder: "이메일을 입력하세요",
                        isSecure: false,
                        binding: $text,
                        scopeColor: false
                    )
                    HeaderTextField(
                        headerTitle: "비밀번호",
                        placeHolder: "비밀번호를 입력하세요",
                        isSecure: false,
                        binding: $text,
                        scopeColor: false
                    )
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .font(WSXFont.title2)
                
                Text("로그인")
                    .font(WSXFont.title2)
                    .modifier(CommonButtonModifer())
                    .background(WSXColor.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 30)
                    .foregroundStyle(WSXColor.white)
            }
            .navigationTitle("이메일 로그인")
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
}
