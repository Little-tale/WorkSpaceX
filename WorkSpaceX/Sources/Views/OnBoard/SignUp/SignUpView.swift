//
//  SignUpView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI
import ComposableArchitecture

struct SignUpView: View {
    
    @Perception.Bindable var store: StoreOf<SignUpFreature>
    
    var body: some View {
        
        WithPerceptionTracking {
            VStack {
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    WSXImage.xImage
                        .asButton {
                            print("asas")
                            store.send(.cancelButtonTapped)
                        }
                        .foregroundStyle(WSXColor.black)
                }
            }
        }
    }
}


