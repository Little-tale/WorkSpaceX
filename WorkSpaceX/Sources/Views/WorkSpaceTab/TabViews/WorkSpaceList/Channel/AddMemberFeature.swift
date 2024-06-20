//
//  AddMemberFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/20/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AddMemberFeature {
    
    @ObservableState
    struct State: Equatable {
        var id = UUID()
        
        var currentWorkSpaceID: String
        
        var currentEmail = ""
       
        var errorMessage: String? = nil
        var successMessage: String? = nil
        var showPrograssView = false
        
        var regButtonState = false
        var showVaildText = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case regButtonTapped
        
        // 내부용
        case catchTextValid
        case realmRegStart(WorkSpaceMembersEntity)
        // Alert State
        case errorMessage(String?)
        case successMessage(String?)
        // 상위뷰 관찰
        case dismissButtonTapped
        case alertSuccessTapped
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            
            switch action {
            
            case .binding:
                let email = state.currentEmail
                let result = TextValid.TextValidate(email, caseOf: .email)
                switch result {
                case .isEmpty:
                    state.showVaildText = "이메일을 입력해 주세요"
                    state.regButtonState = false
                case .minCount:
                    state.showVaildText = "이메일을 입력해 주세요"
                    state.regButtonState = false
                case .match:
                    state.showVaildText = ""
                    state.regButtonState = true
                case .noMatch:
                    state.showVaildText = "이메일 형식이 아니에요!"
                    state.regButtonState = false
                case .alReady:
                    state.showVaildText = "이메일을 재확인 해주세요"
                    state.regButtonState = false
                }
                
            case .regButtonTapped:
                
                let email = state.currentEmail
                let id = state.currentWorkSpaceID
                
                return .run { send in
                    let result = try await workSpaceRepo.addWorkSpaceMember(id, email)
                    await send(.realmRegStart(result))
                } catch: { error, send in
                    if let error = error as? WorkSpaceAddMemberAPIError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                        } else if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else {
                            print(error)
                        }
                    } else {
                        print(error )
                    }
                }
            case let .realmRegStart(model):
                let id = state.currentWorkSpaceID
                return .run { @MainActor send in
                    try await realmRepo.upsertWorkSpaceInMember(
                        response: model,
                        workSpaceID: id
                    )
                    send(.successMessage("\(model.nickname)님 을 초대 하였습니다."))
                } catch : { error, send in
                    print(error)
                }
                
            case let .errorMessage(string):
                state.errorMessage = string
            case let .successMessage(string):
                state.successMessage = string
                
            default:
                break
            }
            
            return .none
        }
        
    }
}
