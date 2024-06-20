//
//  WorkSpaceListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift

@Reducer
struct WorkSpaceListFeature {
    
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: UUID
        var currentWorkSpaceId: String?
        var workSpaceCoverImage: URL?
        var workSpaceName: String?
        
        var chanelSection = WorkSpaceChannelsEntity(items: [])
    }
    
    @Dependency(\.workSpaceReader) var workSpaceReader
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    
    enum isCurrent {
        case empty
        case notEmpty
    }
    
    enum Action {
        case currentWorkSpaceIdCatch(String)
       
        case observerStart(String)
        case firstRealm(String)
        case catchToWorkSpaceRealmModel(WorkSpaceRealmModel)
        
        // 워크스페이스 채널 네트워크 요청단
        case workSpaceChnnelUpdate(workSpaceID: String)
        // 채널 추가
        case chnnelAddClicked
        // 팀원 추가
        case addMemberClicked
        
        // 상위뷰 관찰
        case openSideMenu
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .currentWorkSpaceIdCatch(workSpaceId):
                print("전달 받음",workSpaceId)
                return .run { send in
                    await send(.firstRealm(workSpaceId))
                    await send(.observerStart(workSpaceId))
                    await send(.workSpaceChnnelUpdate(workSpaceID: workSpaceId))
                }
                
            case let .firstRealm(workSpaceId):
                return .run { @MainActor send in
                    let result = try await realmRepo.findModel(workSpaceId, type: WorkSpaceRealmModel.self)
                    
                    print("찾아오기 성공 \(result)")
                    
                    if let result {
                        send(.catchToWorkSpaceRealmModel(result))
                    }
                }
            
                
            case let .observerStart(workSpaceID):
                return .run { send in
                    for await currentModel in await workSpaceReader.observeChangeForPrimery(for: WorkSpaceRealmModel.self, primary: workSpaceID) {
                        print("응답 받음 ")
                        if let currentModel{
                            await send(.catchToWorkSpaceRealmModel(currentModel))
                        }
                    }
                    
                }
                
            case let .catchToWorkSpaceRealmModel(model):
                state.currentWorkSpaceId = model.workSpaceID
                let ifImage = model.coverImage
                
                if let ifImage {
                    state.workSpaceCoverImage = URL(string: ifImage)
                }
                state.workSpaceName = model.workSpaceName
                
                state.chanelSection = workSpaceRepo.workSpaceToChannel(model)
                
                
                // 채널 업데이트
            case let .workSpaceChnnelUpdate(workSpaceID):
                print("워크스페이스 채널 네트워크 요청 시작")
                return .run { send in
                   let result = try await workSpaceRepo.findWorkSpaceChnnel(workSpaceID)
                    print("채널의 결말",result)
                    try await realmRepo.upsertToWorkSpaceChannels(workSpaceId: workSpaceID, channels: result)
                } catch: { error, send in
                    if let error = error as? WorkSpaceMyChannelError {
                        if error.ifReFreshDead {
                            RefreshTokkenDeadReciver.shared.postRefreshTokenDead()
                        } else if !error.ifDevelopError {
                            print(error.message) // 알렛 준비
                        } else {
                            print(error)
                        }
                    } else {
                        print(error)
                    }
                }
                
            default :
                break
            }
            return .none
        }
        
    }
}
