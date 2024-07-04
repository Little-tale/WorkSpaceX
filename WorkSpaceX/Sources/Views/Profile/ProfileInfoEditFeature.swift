//
//  ProfileInfoEditFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/4/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileInfoEditFeature {
    
    @ObservableState
    struct State: Equatable {
        let id = UUID()
        let editType: EditType
        var model: UserInfoEntity
        var currentText: String = ""
        var buttonState = false
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        
        case currentText(String)
        case textTester
        case regButtonTapped
        enum Delegate {
            
        }
    }
    
    enum EditType {
        case nickName
        case contact
        
        var navigationTitle: String {
            switch self {
            case .nickName:
                return "닉네임 수정"
            case .contact:
                return "연락처 수정"
            }
        }
        
        var placeHolder: String {
            switch self {
            case .nickName:
                return "닉네임을 입력해 주세요"
            case .contact:
                return "전화번호를 입력해 주세요"
            }
        }
    }
    
    @Dependency(\.textValidtor) var textValid
    
    var body: some ReducerOf<Self> {
    
        
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                let model = state.model
                switch state.editType {
                case .nickName:
                    state.currentText = model.nickname
                case .contact:
                    state.currentText = model.phone ?? ""
                }
                return .run { send in
                    await send(.textTester)
                }
                
            case let .currentText(text):
                state.currentText = text
                return .run { send in
                    await send(.textTester)
                }
            case .textTester:
                let text = state.currentText
                
                switch state.editType {
                case .nickName:
                    let result = TextValid.TextValidate(text, caseOf: .nickName)
                    let bool = result == .match
                    state.buttonState = bool
                    
                case .contact:
                    let clean = text.filter { $0.isNumber }
                    let result = TextValid.TextValidate(clean, caseOf: .phoneNumber)
                    state.currentText = clean.formatPhoneNumber
                    let bool = result == .match
                    state.buttonState = bool
                }
            default:
                break
            }
            return .none
        }
    }
}
