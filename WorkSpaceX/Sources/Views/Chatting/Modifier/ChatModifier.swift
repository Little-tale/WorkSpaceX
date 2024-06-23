//
//  ChatModifier.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/23/24.
//

import SwiftUI

struct ChatModifier: ViewModifier {
    
    let isMe: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.all, 15)
            .background(isMe ? WSXColor.lightGreen : WSXColor.lightGray)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundStyle( isMe ? WSXColor.white : WSXColor.black)
            
    }
}
