//
//  WorkSpaceSideFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift

@Reducer
struct WorkSpaceSideFeature {
    
    @ObservableState
    struct State: Equatable {
        var id = UUID()
        var currentCase: viewCase = .loading
        var currentCount = 0
        var currentModels:[WorkSpaceRealmModel] = []
        var currentWorkSpaceID: String = "EMPTY"
        @Presents var alertSheet: ConfirmationDialogState<Action.actionSheetAction>?
    }
    
    @Dependency(\.realmRepository) var realmRepo
    
    enum Action {
        case onAppear
        case goBackToRoot
        case checkCount
        case sendToMakeWorkSpace
        case currentModelCatch([WorkSpaceRealmModel])
        case selectedModel(WorkSpaceRealmModel)
        
        case selectedModeltoPresent(WorkSpaceRealmModel)
        
        case openAlertSheet(WorkSpaceRealmModel)
        
        case alertSheetAction(PresentationAction<actionSheetAction>)
        
        @CasePathable
        enum actionSheetAction {
            case workSpaceEdit
            case workSpaceOut
            case workSpaceOwnerChange
            case workSpaceRemove
        }
    }
    
    enum viewCase {
        case loading
        case empty
        case over
    }
   
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            
            switch action {
            case .onAppear:
                state.currentWorkSpaceID =    UserDefaultsManager.workSpaceSelectedID
                
                return .run { send in
                    for await models in  realmRepo.observeChanges(for: WorkSpaceRealmModel.self, sorted: "createdAt", ascending: true) {
                        await send(.currentModelCatch(models))
                    }
                }
                
            case .checkCount:
                if state.currentCount == 0 {
                    state.currentCase = .empty
                } else {
                    state.currentCase = .over
                }
                
            case let .currentModelCatch(models):
                state.currentCount = models.count
                state.currentModels = models
                
                return .run { send in
                    try await Task.sleep(for: .seconds(0.4))
                    await send(.checkCount)
                }
                
            case let .selectedModel(model):
                UserDefaultsManager.workSpaceSelectedID = model.workSpaceID
                return .run { send in
                    await send(.selectedModeltoPresent(model))
                }
                
            case let .openAlertSheet(model):
                
                state.currentWorkSpaceID = model.workSpaceID
                
                state.alertSheet = ConfirmationDialogState {
                    TextState("워크 스페이스 설정")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                    
                    if let userId = UserDefaultsManager.userID,
                       model.ownerID == userId {
                        
                        ButtonState(role: .none, action: .workSpaceEdit) {
                            TextState("워크스페이스 편집")
                        }
                        
                        ButtonState(action: .workSpaceOut) {
                            TextState("워크스페이스 나가기")
                        }
                        
                        ButtonState(action: .workSpaceOwnerChange) {
                            TextState("워크스페이스 관리자 변경")
                        }
                        ButtonState(
                            role:.destructive,
                            action: .workSpaceRemove
                        ) {
                            TextState("워크스페이스 삭제")
                        }
                        
                    } else {
                        ButtonState(action: .workSpaceOut) {
                            TextState("워크 스페이스 나가기")
                        }
                    }
                }
    
            default:
                break
            }
            return .none
        }
        .ifLet(\.$alertSheet, action: \.alertSheetAction)
        
    }
}
/*
 case let .workSpaceModelsChanged(models):
     print("사이드 매뉴 입장")
     state.currentModels = Array(models)
     if state.currentCount != models.count {
         state.currentCount = models.count
         return .run { send in
             try await Task.sleep(for: .seconds(0.44))
             await send(.checkCount)
         }
     }
 */
