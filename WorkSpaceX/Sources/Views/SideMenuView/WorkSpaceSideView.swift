//
//  WorkSpaceSideView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/14/24.
//

import SwiftUI
import ComposableArchitecture
import RealmSwift
import Kingfisher

struct WorkSpaceSideView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceSideFeature>
//    @ObservedResults
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                VStack {
                    fakeNavigation()
                    
                    contentView()
                    
                    workSpaceAddView()
                        .asButton {
                            store.send(.sendToMakeWorkSpace)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 10)
                    
                    workSpaceHelpView()
                        .asButton {
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 10)
                        .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .alert("ERROR", isPresented: $store.errorAlertBoll.sending(\.errorAlertBool), actions: {
            })
            .alert("삭제완료", isPresented: $store.successAlertBool.sending(\.successAlertBool), actions: {
                Text("확인")
                    .asButton {
                        store.send(.successAlertTapped)
                    }
            })
            .confirmationDialog($store.scope(state: \.alertSheet, action: \.alertSheetAction))
            .sheet(item: $store.scope(state: \.workSpaceEdit, action: \.workSpaceEditAction), content: { store in
                WorkSpaceEditView(store: store)
            })
            .onChange(of: store.removeAlertBool) { newValue in
                if newValue {
                    CustomAlertWindow.shared.show {
                        CustomAlertView(
                            alertMode: .cancelWith,
                            isShowing: $store.removeAlertBool.sending(\.removeAlertBoolCatch),
                            title: "워크스페이스 삭제",
                            message: "삭제시 채널/멤버/채팅 등의 데이터들이 사라집니다. 삭제 하시겠습니까?",
                            onCancel: {
                                
                            }, onAction: {
                                store.send(.requestRemoveModel)
                            }, actionTitle: "삭제")
                    }
                    
                }
            }
            
            
        }
    }
}

extension WorkSpaceSideView {
    
    @ViewBuilder
    private func contentView() -> some View {
        switch store.currentCase {
        case .loading:
            ProgressView()
        case .empty:
            VStack {
                Spacer()
                Text("워크스페이스를\n찾을 수 없어요.")
                    .font(WSXFont.title0)
                    .multilineTextAlignment(.center)
                
                Text("관리자에게 초대를 요청하거나,\n다른이메일로 시도하거나\n새로운 워크스페이스를 생성해주세요.")
                    .font(WSXFont.body)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                Text("워크스페이스 생성")
                    .font(WSXFont.title2)
                    .foregroundStyle(WSXColor.white)
                    .modifier(CommonButtonModifer())
                    .background(WSXColor.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .asButton {
                        store.send(.sendToMakeWorkSpace)
                    }
                    .padding(.horizontal, 20)
                Spacer()
            }
        case .over:
            List {
                ForEach(store.currentModels, id: \.workSpaceID) { item in
                    makeWorkSpaceListView(item)
                }
            }
            .listStyle(.plain)
        }
    }
}

extension WorkSpaceSideView {
    
    private func makeWorkSpaceListView(_ model: WorkSpaceRealmModel) -> some View {
        HStack {
            Group {
                if let image = model.coverImage,
                   let url = URL(string: image) {
                    DownSamplingImageView(url: url, size: CGSize(width: 50, height: 50))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .asButton {
                store.send(.selectedModel(model))
            }
            
            VStack(alignment: .leading) {
                Text(model.workSpaceName)
                    .font(WSXFont.title2)
                Text(DateManager.shared.asDateToString(model.createdAt))
                    .font(WSXFont.regu1)
                    .foregroundStyle(WSXColor.black)
            }
            
            Spacer()
            
            VStack (alignment: .trailing) {
                WSXImage.dots
                    .renderingMode(.template)
                    .foregroundStyle(WSXColor.black)
                    .padding(.vertical, 20)
                    .padding(.leading, 17)
                    .background(WSXColor.white.opacity(0.2))
            }
            .onTapGesture {
                print("알렛 시트")
                store.send(.openAlertSheet(model))
            }
        }
        .padding(.all, 10)
        .background(store.currentWorkSpaceID == model.workSpaceID ? WSXColor.green.opacity(0.1) : WSXColor.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
}

extension WorkSpaceSideView {
    
    func workSpaceAddView() -> some View {
        HStack {
            WSXImage.plus
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .padding(.horizontal, 10)
                .padding(.leading, 8)
            Text("워크 스페이스 추가")
                .font(WSXFont.body)
            Spacer()
        }
    }
    
    func workSpaceHelpView() -> some View {
        HStack {
            WSXImage.help
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .padding(.horizontal, 10)
                .padding(.leading, 8)
            Text("도움말")
                .font(WSXFont.body)
            Spacer()
        }
    }
    
}

// 가짜 네비
extension WorkSpaceSideView {
    func fakeNavigation() -> some View {
        HStack {
            WSXImage.logoImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 10)
                .asButton {
                    store.send(.goBackToRoot)
                }
            
            Text("WorkSpace X")
                .font(WSXFont.bigTitle3)
                .foregroundGrdientTo(gradient: WSXColor.titleGradient)
            Spacer()
        }
        .padding(.top, 60)
        .padding(.bottom, 10)
        .background ( WSXColor.lightGray)
    }
}
