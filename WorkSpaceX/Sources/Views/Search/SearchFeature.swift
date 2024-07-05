//
//  SearchFeature.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SerachFeature {
    
    @ObservableState
    struct State: Equatable {
        let id: UUID
        var currentWorkSpaceID: String? = nil
        
        var navigationTitle = "검색"
        var searchViewPlaceMent = "검색어를 입력해 주세요"
        var searchText: String = ""
        var viewCase: SearchViewCase = .empty
        var alertCase: AlertCase? = nil
        
        var channels: [WorkSpaceChannelEntity] = []
        var members: [WorkSpaceMembersEntity] = []
        
        var currentTextFilterText = ""
    }
    
    enum AlertCase: Equatable {
        case error(String)
        
        var title: String {
            switch self {
            case .error:
                return "에러"
            }
        }
        
        var message: String {
            switch self {
            case .error(let string):
                return string
            }
        }
        
        var actionTitle: String {
            switch self {
            case .error:
                return "확인"
            }
        }
    }

    enum Action {
        case onAppear
        case parentAction(ParentAction)
        case delegate(Delegate)
        
        // 검색 하였을때
        case searchTextOnSubmit
        case catchToText(String)
        
        case searchText(String)
        
        case alertCase(AlertCase?)
        
        case selectedChannel(WorkSpaceChannelEntity)
        case selectedMember(WorkSpaceMembersEntity)
        
        case catchResults(
            Channel: [WorkSpaceChannelEntity],
            Member: [WorkSpaceMembersEntity]
        )
        
        enum ParentAction {
            case sendToWorkSpaceID(String)
        }
        enum Delegate {
            case moveToOtherUserProfileView(WorkSpaceMembersEntity)
            case moveToChannelChatView(WorkSpaceChannelEntity)
        }
    }
    enum SearchViewCase {
        case empty
        case show
        case searchResultEmpty
    }
    
    enum ID: Hashable {
        case debounce
    }
    
    @Dependency(\.workspaceDomainRepository) var workSpaceRepo
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
             
            case .onAppear:
                let text = state.currentTextFilterText
                return .run { send in
                    await send(.catchToText(text))
                }
                
            case let .parentAction(.sendToWorkSpaceID(workSpaceID)):
                state.currentWorkSpaceID = workSpaceID
                
            case let .searchText(text):
                state.searchText = text
                if text != "" {
                    return .run { send in
                        await send(.catchToText(text))
                    }
                    .debounce(id: ID.debounce,
                              for: 0.5,
                              scheduler: RunLoop.main
                    )
                } else {
                    state.viewCase = .empty
                }
            case let .catchToText(text):
                guard let workSpaceId = state.currentWorkSpaceID else {
                    break
                }
                guard state.searchText != "" else { break }
                print("쓰로틀 ",text)
                state.currentTextFilterText = text
                return .run { send in
                    let result = try await workSpaceRepo.workSpaceKeywordSearching(
                        workSpaceId,
                        text
                    )
                    await send(.catchResults(Channel: result.Channel, Member: result.Member))
                } catch: { error, send in
                    if let error = error as? WorkSpaceSearchToListAPIError {
                        if !error.ifDevelopError {
                            await send(.alertCase(.error(error.message)))
                        } else { print(error) }
                    } else {
                        print(error)
                    }
                }
                
            case let .catchResults(channel,member):
                state.channels = channel
                state.members = member
                if channel.isEmpty && member.isEmpty {
                    state.viewCase = .searchResultEmpty
                } else {
                    state.viewCase = .show
                }
                
            case .searchTextOnSubmit:
                print("이게 됨 ??? ",state.searchText)
                
            case let .selectedMember(model):
                return .run { send in
                    await send(.delegate(.moveToOtherUserProfileView(model)))
                }
                
            case let .selectedChannel(model):
                return .run { send in
                    await send(.delegate(.moveToChannelChatView(model)))
                }
                
            default:
                break
            }
            return .none
        }
    }
    
}
