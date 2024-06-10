//
//  WorkSpaceFirstStartView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceFirstStartView: View {
    
    
    var body: some View {
        NavigationStack {
            
            Text("출시 준비 완료!")
                .font(WSXFont.title1)
            
            WSXImage.workSpaceStart
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                
                
            
        }
    }
}

#Preview {
    WorkSpaceFirstStartView()
}
