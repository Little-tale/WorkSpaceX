//
//  CustomAlertViewWithPopUpView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/4/24.
//

import SwiftUI

struct CustomAlertViewWithPopUpView: View {
    
    var alertMode: AlertMode
    
    var title: String
    var message: String
    
    var onCancel: () -> Void
    var onAction: () -> Void
    
    var actionTitle: String
    
    
    var body: some View {
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
    }
}

extension CustomAlertViewWithPopUpView {
    
    @ViewBuilder
    func makeAlertView() -> some View {
        switch alertMode {
            
        case .cancelWith:
            HStack {
                Text("취소")
                    .font(WSXFont.title15)
                    .frame(maxWidth: .infinity)
                    .frame(height: 15)
                    .padding()
                    .background(WSXColor.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .asButton {
                        onCancel()
                    }
                
                Text(actionTitle)
                    .font(WSXFont.title15)
                    .frame(maxWidth: .infinity)
                    .frame(height: 15)
                    .padding()
                    .background(WSXColor.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .asButton {
                        onAction()
                    }
            }
        case .onlyCheck:
            Text(actionTitle)
                .font(WSXFont.title1)
                .frame(maxWidth: .infinity)
                .padding()
                .background(WSXColor.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .asButton {
                    onAction()
                }
        }
    }
}
