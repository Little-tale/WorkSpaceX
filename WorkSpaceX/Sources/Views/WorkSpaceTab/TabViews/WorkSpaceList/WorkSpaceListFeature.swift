//
//  WorkSpaceListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/12/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct WorkSpaceListFeature {
    
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: UUID
        var currentWorkSpaceId: String?
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
                }
                
            case let .firstRealm(workSpaceId):
                return .run { @MainActor send in
                    let result = try await realmRepo.findModel(workSpaceId, type: WorkSpaceRealmModel.self)
                    print("찾아오기 성공 \(result)")
                }
                
            case let .observerStart(workSpaceID):
                return .run { send in
                    for await currentModel in await workSpaceReader.observeChangeForPrimery(for: WorkSpaceRealmModel.self, primary: workSpaceID) {
                        print("응답 받음 \(String(describing: currentModel))")
                    }
                }
                
            default :
                break
            }
            return .none
        }
        
    }
}
