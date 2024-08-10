//
//  WorkSpaceSideFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift
import Combine

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
        
        
        var removeAlertBool = false
        
        var currentSheetSelectModel: WorkSpaceRealmModel? = nil
        
        var errorAlertBoll = false
        var successAlertBool = false
        var alertMessage = ""
        var errorMessage: String? = nil
        @Presents var workSpaceEdit: WorkSpaceEditFeature.State? = nil
        
        @Presents var workSpaceOwnerChange: WorkSpaceOwnerChangeFeature.State? = nil
    }
    
//    static let realmRepo = RealmRepository()
    @Dependency(\.workspaceDomainRepository ) var workSpaceRepo
    
    @Dependency(\.realmRepository ) var realmRepo

    private let justReader = WorkSpaceReader.shared
    
    enum Action {
        case onAppear
        case subscribe
        case goBackToRoot
        case checkCount
        case sendToMakeWorkSpace
        case currentModelCatch([WorkSpaceRealmModel])
        case selectedModel(WorkSpaceRealmModel)
        
        case selectedModeltoPresent(WorkSpaceRealmModel)
        
        case openAlertSheet(WorkSpaceRealmModel)
        
        case alertSheetAction(PresentationAction<actionSheetAction>)
        
        case workSpaceEditAction(PresentationAction<WorkSpaceEditFeature.Action>)
        
        case workSpaceOwnerChange(PresentationAction<WorkSpaceOwnerChangeFeature.Action>)
        
        @CasePathable
        enum actionSheetAction {
            case workSpaceEdit
            case workSpaceOut
            case workSpaceOwnerChange
            case workSpaceRemove
        }
        
        case showWorkSpaceEditSheet(WorkSpaceRealmModel)
        
        // 삭제 알렛 전달
        case removeAlertBoolCatch(Bool)
        case requestRemoveModel
        // 최종 삭제
        case confirmRemoveModelID(String)
        
        // 에러 알렛
        case errorMessage(String?)
        case errorAlertBool(Bool)
        // 성공 알렛
        case successMessage(String)
        case successAlertBool(Bool)
        case removeSuccessAlertTapped
        
        case delegate(Delegate)
        
        case workSpaceExitTry(workSpaceID: String)
        
        enum Delegate {
            case changedWorkSpaceID(String?)
        }
    }
    
    enum viewCase {
        case loading
        case empty
        case over
    }
    
    
    var body: some ReducerOf<Self> {
        
        core()
        .ifLet(\.$alertSheet, action: \.alertSheetAction)
        .ifLet(\.$workSpaceEdit, action: \.workSpaceEditAction) {
            WorkSpaceEditFeature()
        }
        .ifLet(\.$workSpaceOwnerChange, action: \.workSpaceOwnerChange) {
            WorkSpaceOwnerChangeFeature()
        }
    }
}

extension WorkSpaceSideFeature {
    
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
            case .onAppear:
                return onAppearSideEffect(state: &state)
                
            case .subscribe:
                return .run { send in
                    for await models in await justReader.observeChanges(for: WorkSpaceRealmModel.self, sorted: "createdAt", ascending: true) {
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
                openAlertSheetSetting(state: &state, model: model)
                
            case .alertSheetAction(.presented(.workSpaceRemove)):
                return .run { send in
                    await send(.removeAlertBoolCatch(true))
                }
                
            case let .removeAlertBoolCatch(bool):
                state.removeAlertBool = bool
                
            case .requestRemoveModel:
                return removeModelSideEffect(state: &state)
                
            case .alertSheetAction(.presented(.workSpaceEdit)):
                if let model = state.currentSheetSelectModel {
                    return .send(.showWorkSpaceEditSheet(model))
                }
                
            case .alertSheetAction(.presented(.workSpaceOwnerChange)):
                if let model = state.currentSheetSelectModel {
                    let id = model.workSpaceID
                    state.workSpaceOwnerChange = WorkSpaceOwnerChangeFeature.State(
                        workSpaceID: id
                    )
                }
                
            case .alertSheetAction(.presented(.workSpaceOut)):
                if let model = state.currentSheetSelectModel,
                   let userId = UserDefaultsManager.userID {
                    let workSpaceID = model.workSpaceID
                    let ownerID = model.ownerID
                    
                    if ownerID == userId {
                        return .run { send in
                            await send(.errorMessage("관리자 권한을 양도하셔야 방을 나가실수 있어요!"))
                        }
                    } else {
                        return .run { send in
                            await send(.workSpaceExitTry(workSpaceID: workSpaceID))
                        }
                    }
                }
                
            case let .workSpaceExitTry(workSpaceID):
                return .run { send in
                    let _ = try await workSpaceRepo.workSpaceExit(workSpaceID: workSpaceID)
                        
                    await send(.confirmRemoveModelID(workSpaceID))
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceExitError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .showWorkSpaceEditSheet(model):
                state.workSpaceEdit = WorkSpaceEditFeature.State()
                return .send(.workSpaceEditAction(.presented(.getModel(model))))
                
            case let .confirmRemoveModelID(removeModelID):
                print("삭제하러 가기전")
                print(removeModelID)
                state.currentWorkSpaceID = ""
                state.currentModels = []

                return .run { send in
                    
                    try await RealmRepository.mainActorRemove(removeModelID, type: WorkSpaceRealmModel.self)
                    
                    await send(.successMessage("삭제 완료되었습니다."))
                    
                } catch: { error, send in
                    await send(.errorMessage("삭제중 에러가 발생 했습니다."))
                }
                
            case let .successMessage(messgage):
                state.alertMessage = messgage
                state.successAlertBool = true
                
            case let .successAlertBool(bool):
                state.successAlertBool = bool
                
            case let .errorMessage(message):
                state.errorMessage = message
                
            case let .errorAlertBool(bool):
                state.errorAlertBoll = bool
                
            case .removeSuccessAlertTapped:
                return removeAlertTappedSideEffect(state: &state)
                
            case  .workSpaceOwnerChange(.presented(.delegate(.successForChanged))):
                return .run { send in
                    await send(.workSpaceOwnerChange(.dismiss))
                    await send(.onAppear)
                }
                
            default:
                break
            }
            return .none
        }
    }
    
}

extension WorkSpaceSideFeature {
    
    private func openAlertSheetSetting(state: inout State, model: WorkSpaceRealmModel) {
        state.currentWorkSpaceID = model.workSpaceID
        
        state.currentSheetSelectModel = model
        
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
    }
    
    private func onAppearSideEffect(state: inout State) -> Effect<Action> {
        state.currentWorkSpaceID = UserDefaultsManager.workSpaceSelectedID
        
        return .run { send in
            let result = try await workSpaceRepo.findMyWordSpace()
            try await realmRepo.upsertWorkSpaces(responses: result)
            await send(.subscribe)
        } catch: { error, send in
           print(error)
        }
    }
    
    private func removeModelSideEffect(state: inout State) -> Effect<Action> {
        if let model = state.currentSheetSelectModel {
            
            let id = model.workSpaceID
            
            return .run { send in
                print( "지우기 시작" )
                try await workSpaceRepo.workSpaceRemove(id)
                
                await send(.confirmRemoveModelID(id))
                
            } catch: { error, send in
                if let error = error as? WorkSpaceRemoveAPIError {
                    if !error.ifDevelopError {
                        await send(.errorMessage(error.message))
                    } else {
                        print(error)
                    }
                } else { print(error) }
            }
        }
        return .none
    }
    
    private func removeAlertTappedSideEffect(state: inout State) -> Effect<Action> {
        if let model = state.currentModels.first {
            let id = model.workSpaceID
            
            UserDefaultsManager.workSpaceSelectedID = id
            state.currentWorkSpaceID = id
            return .run { send in
                await send(.delegate(.changedWorkSpaceID(id)))
            }
        } else {
            UserDefaultsManager.workSpaceSelectedID = ""
            return .run { send in
                await send(.delegate(.changedWorkSpaceID(nil)))
            }
        }
    }
}
