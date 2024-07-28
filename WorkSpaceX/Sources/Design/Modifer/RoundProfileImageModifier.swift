//
//  RoundProfileImageModifier.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//


import SwiftUI

struct RoundProfileImageModifier: ViewModifier {
    
    var frame: CGSize
   
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .frame(width: frame.width, height: frame.height)
            .clipShape(RoundedRectangle(cornerRadius: frame.width / 4))
    }
}
