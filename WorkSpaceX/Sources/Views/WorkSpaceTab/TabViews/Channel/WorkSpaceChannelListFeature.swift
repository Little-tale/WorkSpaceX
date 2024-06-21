//
//  WorkSpcaeChannelListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceChannelListFeature {
    
    @ObservableState
    struct State: Equatable {
        var id: UUID
        var workSpaceID: String
        var errorMessage: String?
        var channelList = [ChanelEntity] ()
        
        
        var ifNeedChannelAlert: Bool = false
        var chaannelAlertMessage = ""
        var selectedModel: ChanelEntity?
    }
    
    enum Action {
        case dismissTapped
        case onAppear
        
        case catchModels([ChanelEntity])
        
        case errorMessage(String?)
        
        case selectedModel(ChanelEntity)
        case channelAlertCancel
        case channelALertConfirm
        case channelAlertBool(Bool)
    }
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            
            switch action {
            case .onAppear :
                let id = state.workSpaceID
                
                return .run { send in
                    let result = try await workSpaceRepo.workSpaceSearchingToChannel(id)
                    await send(.catchModels(result))
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceChannelListAPIError {
                        if error.ifReFreshDead { RefreshTokkenDeadReciver.shared.postRefreshTokenDead() }
                        else if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else { print(error) }
                    } else { print(error) }
                }
                
            case let .selectedModel(model):
                state.selectedModel = model
                state.chaannelAlertMessage = "[\(model.name)] 채널에 참여 하시겠습니까?"
                return .run { send in
                    await send(.channelAlertBool(true))
                }
            case let .channelAlertBool(bool):
                state.ifNeedChannelAlert = bool
                
            case let .catchModels(models):
                state.channelList = models
                
            case let .errorMessage(message):
                state.errorMessage = message
            default :
                break
            }
            
            return .none
        }
    }
}
