//
//  ShadowModifier.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/22/24.
//

import SwiftUI

struct ShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        WSXColor.black.opacity(0),
                        WSXColor.black.opacity(0.1),
                        WSXColor.black.opacity(0.2),
                        WSXColor.black.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}
