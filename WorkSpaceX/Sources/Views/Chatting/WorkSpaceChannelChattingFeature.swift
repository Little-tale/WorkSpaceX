//
//  WorkSpaceChannelChattingFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceChannelChattingFeature {
    
    @ObservableState
    struct State: Equatable {
        let id: UUID = UUID()
        let channelID: String
        let workSpaceID: String
        let userID : String
        
        var navigationTitle: String
        var navigationMemberCount: String = "0"
    }
    
    enum Action {
        case popClicked
        
        // 채팅 분기점
        case chatDate(Date?)
        case channelInfoRequest
        case networkResult([WorkSpaceChatEntity])
        case channelResult(ChanelEntity)
        
        case navigationTitle(String) // 전뷰에서 받아왔지만 한번더
        case navigationMemberCount(Int)
        
        case onAppear
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.workSpaceReader) var reader
    
    var body: some ReducerOf<Self> {
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                let channelID = state.channelID
                
                let workSpaceID = state.workSpaceID
                
                // 1. 채팅 데이터가 존재하는지 최소한 한번은 확인해야함.
                // 1.1 채팅 존재한다면 바로 렘 옵저버 걸기
                // 2. 없다면 커서 데이트를 빈값으로 보내야함.
                // 1.2 없다면 네트워크 먼저 수행후 렘 옵저버 걸기
                // + 렘 멤버 도 꼭 확인
                return .run { send in
                
                    let date = try await realmRepo.findChatsForChannel(channelId: channelID)
                    await send(.chatDate(date))
                }
            case let .chatDate(date) :
                let channelId = state.channelID
                let workSpaceId = state.workSpaceID
                
                if let date {
                    // 1.1 채팅 존재한다면 바로 렘 옵저버 걸기
                    // 렘옵저버 선 후 -> 통신
                    
                } else {
                    // 2. 없다면 커서 데이트를 빈값으로 보내야함.
                    // 1.2 없다면 네트워크 먼저 수행후 렘 옵저버 걸기
                    return .run { send in
                        let result = try await workSpaceRepo.workSpaceChattingList(workSpaceId, channelId, nil)
                        print("받기 \(result)")
                        await send(.networkResult(result))
                        await send(.channelInfoRequest)
                    } catch: { error, send in
                        if let error = error as? WorkSpaceChannelListAPIError {
                            if error.ifReFreshDead { RefreshTokkenDeadReciver.shared.postRefreshTokenDead() }
                            else if error.errorCode == "E13" {
                                print("존재하지 않는 워크 스페이스..?")
                            }
                        } else {
                            print(error)
                        }
                    }
                }
            case let .networkResult(results):
                print(results)
                
                //채널 정보 조회
            case .channelInfoRequest:
                let workSpaceID = state.workSpaceID
                let channelID = state.channelID
                return .run { send in
                    let result = try await workSpaceRepo.channelInfoRequest(workSpaceID, channelID)
                    await send(.channelResult(result))
                    // 이때 렘 업뎃
                    try await  realmRepo.upsertToWorkSpaceChannelAppend(workSpaceID: workSpaceID, chanel: result, userBool: true)
                    
                } catch: { error, send in
                    if let error = error as? WorkSpaceChannelListAPIError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            case let .channelResult(channel):
                state.navigationMemberCount = String(channel.users.count)
                
                break
                
            default:
                break
            }
            return .none
        }
        
    }
    
}


// 3. 있다면 커서 데이트를 쿼리 스트링으로 보내야함.
// 확인하면서 채널을 생성해버림과 동시에 워크스페이스에 연결
// 이유는 간단. 해당 뷰로 오면 이미 사용자는 해당 멤버
// print("네트워크 요청해야함...")
