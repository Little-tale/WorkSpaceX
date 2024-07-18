//
//  WorkSpaceFirstStartView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/10/24.
//

import SwiftUI
import ComposableArchitecture

struct WorkSpaceFirstStartView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceFirstStartFeature>
    
    
    var body: some View {
        WithPerceptionTracking { 
            NavigationStack {
                
                contentView()
                .navigationTitle(store.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        WSXImage.xImage
                            .asButton {
                                store.send(.cancelButtonTapped)
                            }
                            .foregroundStyle(WSXColor.black)
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .sheet(item: $store.scope(state: \.workSpaceIniter, action: \.sendWorkSpaceInit)) { store in
                    WorkSpaceInitalView(store: store)
                }
                
            }
        }
    }
}

extension WorkSpaceFirstStartView {
    
    private func contentView() -> some View {
        VStack {
            Text(store.readyText)
                .font(WSXFont.title0)
                .padding(.top, 20)
            Text(store.state.introText)
                .font(WSXFont.bodyBold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 5)
            WSXImage.workSpaceStart
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
            
            Spacer()
            workSpaceMakeButton()
        }
    }
    
    private func workSpaceMakeButton() -> some View {
        Text(store.workSpaceMakeText)
            .font(WSXFont.title2)
            .modifier(CommonButtonModifer())
            .background(WSXColor.green)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 20)
            .padding(.horizontal, 30)
            .foregroundStyle(WSXColor.white)
            .asButton {
                store.send(.startButtonTapped)
            }
            .buttonStyle(PlainButtonStyle())
    }
}
