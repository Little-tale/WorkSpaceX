//
//  WorkSpaceOwnerChangeView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/8/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct WorkSpaceOwnerChangeView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceOwnerChangeFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationView {
                VStack {
                    Group {
                        if store.currentWorkSpaceMember.isEmpty {
                            memberEmptyView()
                        } else {
                            contentView()
                        }
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .alert(item: $store.errorMessage.sending(\.errorMessage), title: { _ in
                    Text("에러")
                }, actions: { _ in
                    Text("확인")
                        .asButton {
                            store.send(.errorMessage(nil))
                        }
                }, message: { message in
                    Text(message)
                })
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("관리자 변경")
                .listStyle(.plain)
                .padding(.horizontal, 12)
                Spacer()
            }
        }
    }
}
extension WorkSpaceOwnerChangeView {
    
    private func contentView() -> some View {
        VStack {
            List {
                LazyVStack(alignment: .center, spacing: 5) {
                    ForEach(store.currentWorkSpaceMember, id: \.userID) { model in
                        memberView(model)
                            .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .popup(item: $store.selectedModel.sending(\.selectedModel), itemView: { model in
            sureOwncerChangePopView(model: model)
        }) {
            $0
                .appearFrom(.centerScale)
                .closeOnTap(false)
                .closeOnTapOutside(false)
                .dragToDismiss(false)
        }
        
    }
    
    private func memberEmptyView() -> some View {
        VStack {
            Text("저런...\n현재 멤버가 아무도 없어요!\n멤버를 추가한 후 재시도 해주세요!")
                .font(WSXFont.bigTitle3)
                .padding(.bottom, 5)
                .multilineTextAlignment(.center)
            WSXImage
                .memberEmpty
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
        }
       
    }
}

extension WorkSpaceOwnerChangeView {
    
    private func sureOwncerChangePopView(model: WorkSpaceMembersEntity) -> some View {
        VStack {
            if !store.changing {
                CustomAlertViewWithPopUpView(
                    alertMode: .cancelWith,
                    title: "\(model.nickname) 님께 양도",
                    message: """
                    정말 관리자 권한을 양도 하시겠습니까?
                    - 워크스페이스 이름 또는 설명 변경 권한 양도
                    - 워크스페이스 삭제 혹은 수정 권한 양도
                    - 워크스페이스 멤버 초대 권한 양도
                    """,
                    onCancel: {
                        store.send(.selectedModel(nil))
                    },
                    onAction: {
                        store.send(.confirmMember(model))
                    },
                    actionTitle: "수락"
                )
            } else {
                ProgressView()
                    .padding(.all, 80)
                    .background(WSXColor.white)
                    .foregroundStyle(WSXColor.black)
            }
        }
        
    }
    
}


extension WorkSpaceOwnerChangeView {
    
    private func memberView(_ model: WorkSpaceMembersEntity) -> some View {
        HStack {
            Group {
                if let image = model.profileImage {
                    DownSamplingImageView(url: URL(string: image), size: ImageResizingCase.middle.size)
                    .frame(width: 50, height: 50)
                } else {
                    WSXImage.logoImage
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .padding(.vertical, 4)
            
            VStack(alignment: .leading) {
                Text(model.nickname)
                    .font(WSXFont.title2)
                
                Text(model.email)
                    .font(WSXFont.regu1)
            }
            Spacer()
        }
        .onTapGesture {
            store.send(.selectedMember(model))
        }
    }
}
