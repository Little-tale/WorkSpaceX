//
//  WorkSpaceSideView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift

struct WorkSpaceSideView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceSideFeature>
    
    @Binding
    var isShowing: Bool
    
    @ObservedResults(WorkSpaceRealmModel.self) 
    var workSpaceModel
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                HStack {
                    WSXImage.logoImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 10)
                        .asButton {
                             // 뒤로가기 액션 줄 예정
                            isShowing.toggle()
                        }
                    
                    Text("WorkSpace X")
                        .font(WSXFont.bigTitle3)
                        .foregroundGrdientTo(gradient: WSXColor.titleGradient)
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.bottom, 10)
                .background ( WSXColor.lightGray)
                Spacer()
            }
            .onAppear {
    //            store.send(.onAppear(workSpaceModel))
            }
            .onChange(of: workSpaceModel) { newValue in
    //            store.send(.onAppear(workSpaceModel))
            }
        }
        
    }
}
