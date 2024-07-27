//
//  ExText.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import SwiftUI

extension Text {
    func foregroundGradient(
        colors: [Color],
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> some View {
        self.overlay {
            LinearGradient(
                colors: colors,
                startPoint: startPoint,
                endPoint: endPoint
            )
            .mask(self)
        }
    }
    
    func foregroundGradientTo(gradient: LinearGradient) -> some View {
        return self.overlay {
            gradient
                .mask(self)
        }
    }
}
