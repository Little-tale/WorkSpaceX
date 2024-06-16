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

    @ObservedResults(WorkSpaceRealmModel.self) 
    var workSpaceModel
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                fakeNavigation()
                contentView()
                    .onAppear{                store.send(.onAppear(workSpaceModel))
                    }
                workSpaceAddView()
                    .asButton {
                        store.send(.sendToMakeWorkSpace)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 10)
                
                workSpaceHelpView()
                    .asButton {
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical, 10)
                    .padding(.bottom, 10)
                
                Spacer()
            }
        }
    }
}

extension WorkSpaceSideView {
    
    @ViewBuilder
    private func contentView() -> some View {
        switch store.currentCase {
        case .loading:
            ProgressView()
        case .empty:
                VStack {
                    Spacer()
                    Text("워크스페이스를\n찾을 수 없어요.")
                        .font(WSXFont.title0)
                    
                    Text("관리자에게 초대를 요청하거나,\n다른이메일로 시도하거나\n새로운 워크스페이스를 생성해주세요.")
                    
                    Text("워크스페이스 생성")
                        .font(WSXFont.title2)
                        .foregroundStyle(WSXColor.white)
                        .modifier(CommonButtonModifer())
                        .background(WSXColor.green)
                        .asButton {
                            store.send(.sendToMakeWorkSpace)
                        }
                        .padding(.horizontal, 20)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
            }
        case .over:
            Text("무언가 있을 예정")
        }
    }
}

extension WorkSpaceSideView {
    
    func workSpaceAddView() -> some View {
        HStack {
            WSXImage.plus
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .padding(.horizontal, 10)
            Text("워크 스페이스 추가")
            Spacer()
        }
    }
    
    func workSpaceHelpView() -> some View {
        HStack {
            WSXImage.help
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .padding(.horizontal, 10)
            Text("도움말")
            Spacer()
        }
    }
    
}

// 가짜 네비
extension WorkSpaceSideView {
    func fakeNavigation() -> some View {
        HStack {
            WSXImage.logoImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 10)
                .asButton {
                    store.send(.goBackToRoot)
                }
            
            Text("WorkSpace X")
                .font(WSXFont.bigTitle3)
                .foregroundGrdientTo(gradient: WSXColor.titleGradient)
            Spacer()
        }
        .padding(.top, 60)
        .padding(.bottom, 10)
        .background ( WSXColor.lightGray)
    }
}
