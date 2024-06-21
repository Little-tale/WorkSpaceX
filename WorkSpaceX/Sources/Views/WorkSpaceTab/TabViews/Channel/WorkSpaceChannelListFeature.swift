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
    }
    
    enum Action {
        case dismissTapped
        case onAppear
        
        case catchModels([ChanelEntity])
        
        case errorMessage(String?)
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
