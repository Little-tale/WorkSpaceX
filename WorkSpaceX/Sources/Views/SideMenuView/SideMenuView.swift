//
//  SideMenu.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import SwiftUI

struct SideMenuView<RenderView: View> : View {
    
    @Binding 
    var isShowing: Bool
    
    var direction: Edge
    
    @ViewBuilder 
    var content: RenderView
    
    var body: some View {
        ZStack(alignment: .leading) {
            if isShowing {
                WSXColor.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                content
                    .transition(.move(edge: direction))
                    .background(
                        WSXColor.white
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}
