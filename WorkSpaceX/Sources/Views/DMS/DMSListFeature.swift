//
//  DMSListFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/1/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DMSListFeature {
    
    @ObservableState
    struct State: Equatable {
        var id: UUID
        var currentWorkSpaceID: String = ""
        var onAppearTrigger: Bool = true
        var navigationImage: String? = nil
        
        var errorMessage: String? = nil
        
        var userList: [WorkSpaceMembersEntity] = []
        var roomList: [DMSRoomEntity] = []
        
        var viewState: DmViewState = .loading
    }
    enum DmViewState {
        case loading
        case empty
        case members
    }
    
    enum Action {
        case onAppaer
        
        case parentAction(ParentAction)
        case delegate(Delegate)
        
        case workSpaceInfoObserver(workSpaceID: String)
        case listDMSInfoObserver(WorkSpaceID: String)
        
        case catchToWorkSpaceRealmModel(WorkSpaceRealmModel)
        case requestWorkSpaceMember(WorkSpaceID: String)
        case realmToUpdateMember([WorkSpaceMembersEntity])
        case justReqeustRealmMember(WorkSpaceID: String)
        
        case roomEntityCatch([DMSRoomEntity])
        case users([WorkSpaceMembersEntity])
        case dmsListReqeust(WorkSpaceID: String)
        
        case unReadReqeust([DMSRoomEntity])
        case unReadResults([DMSUnReadEntity])
        
        // 타 사용자 클릭시
        case selectedOtherUser(WorkSpaceMembersEntity)
        
        enum ParentAction {
            case getWorkSpaceId(String)
        }
        enum Delegate {
            case clickedAddMember
            case moveToDMS(model: WorkSpaceMembersEntity, workSpaceID: String)
        }
        case clickedAddMember
        case errorMessage(String?)
    }
    
    @Dependency(\.workSpaceReader) var workSpaceReader
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    @Dependency(\.realmRepository) var realmRepo
    @Dependency(\.dmsRepository) var dmsRepo
    
    
    
}
