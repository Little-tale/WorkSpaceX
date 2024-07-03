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
        var myChannelList = [ChanelEntity] ()
        
        var ifNeedChannelAlert: Bool = false
        var onApperTrigger: Bool = false
        var chaannelAlertMessage = ""
        var selectedModel: ChanelEntity?
    }
    
    enum Action {
        case dismissTapped
        case onAppear
        
        case catchModels([ChanelEntity])
        case catchMyChannels([ChanelEntity])
        case errorMessage(String?)
        
        case selectedModel(ChanelEntity)
        case channelAlertCancel
        case channelALertConfirm
        case channelAlertBool(Bool)
        
        // 코디네이터 관찰 내역
        case delegate(Delegate)
        enum Delegate {
            case lastConfirm(ChanelEntity)
            case alreadyToConfirm(ChanelEntity)
        }
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
                    
                    let myResult = try await workSpaceRepo.findWorkSpaceChnnel(id)
                    
                    await send(.catchModels(result))
                    await send(.catchMyChannels(myResult))
                } catch: { error, send in
                    if let error = error as? WorkSpaceChannelListAPIError {
                        if !error.ifDevelopError {
                            await send(.errorMessage(error.message))
                        } else { print(error) }
                    } else { print(error) }
                }
                
            case let .selectedModel(model):
                
                state.selectedModel = model
                
                if state.myChannelList.contains(
                    where: { $0.channelId == model.channelId }
                ) {
                    return .run { send in
                        await send(.delegate(.alreadyToConfirm(model)))
                    }
                } else {
                    state.chaannelAlertMessage = "[\(model.name)] 채널에 참여 하시겠습니까?"
                    return .run { send in
                        await send(.channelAlertBool(true))
                    }
                }
                
            case .channelALertConfirm:
                if let model = state.selectedModel {
                    return .run { send in
                        try await Task.sleep(for: .seconds(0.5))
                        print("채널 조인으로 보내야함.")
                        // 채널 채팅 내역 리스트 조회를 하면 참여 유저로 등록됨.
                         await send(.delegate(.lastConfirm(model)))
                    }
                }
                
            case let .channelAlertBool(bool):
                state.ifNeedChannelAlert = bool
                
            case let .catchModels(models):
                if !state.onApperTrigger {
                    state.channelList = []
                    state.channelList = models
                    state.onApperTrigger = true
                }
                
            case let .errorMessage(message):
                state.errorMessage = message
                
            case let .catchMyChannels(models):
                state.myChannelList = models
            default :
                break
            }
            
            return .none
        }
    }
}
