//
//  SuccessButtonView .swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/16/24.
//

import SwiftUI

struct SuccessButtonView: View {
    
    var action: () -> Void
    var regButtonState: Bool
    
    var body: some View {
        Text("완료")
            .font(WSXFont.title2)
            .modifier(CommonButtonModifer())
            .background(regButtonState ? WSXColor.green : WSXColor.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
            .padding(.bottom, keyboardPadding + 10)
            .foregroundStyle(WSXColor.white)
            .asButton {
                action()
            }
            .disabled(!regButtonState)
    }
}
