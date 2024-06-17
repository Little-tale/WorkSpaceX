//
//  CustomAlertView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/17/24.
//

import SwiftUI

struct CustomAlertView: View {
    
    enum AlertMode {
        case onlyCheck
        case cancelWith
    }
    
    var alertMode: AlertMode
    
    @Binding var isShowing: Bool
    
    var title: String
    var message: String
    
    var onCancel: () -> Void
    var onAction: () -> Void
    
    var actionTitle: String
    
    
    var body: some View {
        if isShowing {
            ZStack (alignment: .center) {
                WSXColor.black.opacity(0.2)
                    .ignoresSafeArea(edges: .all)
                Spacer()
                
                VStack(spacing: 16) {
                    Text(title)
                        .font(WSXFont.title1)
                        .foregroundColor(.black)
                    Text(message)
                        .font(WSXFont.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    makeAlertView()
                }
                .padding(.all, 20)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 20)
                .padding()
                
                Spacer()
            }
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: isShowing)
            .zIndex(1)
        }
    }
}

extension CustomAlertView {
    
    @ViewBuilder
    func makeAlertView() -> some View {
        
        switch alertMode {
        case .cancelWith:
            HStack {
                Button(action: {
                    withAnimation {
                        CustomAlertWindow.shared.hide()
                        isShowing = false
                        onCancel()
                    }
                }) {
                    Text("취소")
                        .font(WSXFont.title15)
                        .frame(maxWidth: .infinity)
                        .frame(height: 15)
                        .padding()
                        .background(WSXColor.gray)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Button(action: {
                    withAnimation {
                        CustomAlertWindow.shared.hide()
                        isShowing = false
                        onAction()
                    }
                }) {
                    Text(actionTitle)
                        .font(WSXFont.title15)
                        .frame(maxWidth: .infinity)
                        .frame(height: 15)
                        .padding()
                        .background(WSXColor.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        case .onlyCheck:
            Button(action: {
                CustomAlertWindow.shared.hide()
                isShowing = false
                onAction()
            }) {
                Text(actionTitle)
                    .font(WSXFont.title1)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(WSXColor.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

//#Preview {
//    CustomAlertView(alertMode: .cancelWith, title: "테스트", message: "테스트테스트 테스트 테스트 테스트", onCancel: {
//        
//    }, onAction: {
//        
//    }, actionTitle: "액션")
//}
