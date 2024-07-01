//
//  DMSListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DMSListFeature {
    
    @ObservableState
    struct State: Equatable {
        var id: UUID
        var currentWorkSpaceID: String = ""
        var onAppearTrigger: Bool = true
        var navigationImage: String? = nil
    }
    
    enum Action {
        case onAppaer
        
        case parentAction(ParentAction)
        case workSpaceInfoObserver(workSpaceID: String)
        
        case catchToWorkSpaceRealmModel(WorkSpaceRealmModel)
        enum ParentAction {
            case getWorkSpaceId(String)
        }
    }
    @Dependency(\.workSpaceReader) var workSpaceReader
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppaer:
                print(state.currentWorkSpaceID)
                let id = state.currentWorkSpaceID
                let bool = state.onAppearTrigger
                return .run { send in
                    if id != "", bool {
                        await send(.workSpaceInfoObserver(workSpaceID: id))
                    }
                    
                }
            case let .parentAction(.getWorkSpaceId(id)):
                state.currentWorkSpaceID = id
                
            case let .workSpaceInfoObserver(workSpaceID):
                if state.onAppearTrigger {
                    state.onAppearTrigger = false
                    return .run { @MainActor send in
                        for await currentModel in workSpaceReader.observeChangeForPrimery(for: WorkSpaceRealmModel.self, primary: workSpaceID) {
                            print("응답 받음 ")
                            if let currentModel{
                                send(.catchToWorkSpaceRealmModel(currentModel))
                            }
                        }
                    }
                }
            case let .catchToWorkSpaceRealmModel(model):
                state.navigationImage = model.coverImage
                
            default:
                break
            }
            return .none
        }
    }
    
}
