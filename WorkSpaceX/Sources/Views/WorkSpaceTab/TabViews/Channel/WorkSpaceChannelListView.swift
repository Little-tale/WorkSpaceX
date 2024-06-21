//
//  WorkSpaceChannelLiistView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/21/24.
//

import SwiftUI
import ComposableArchitecture


struct WorkSpaceChannelListView: View {
    
    @Perception.Bindable var store: StoreOf<WorkSpaceChannelListFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                VStack {
                    List {
                        ForEach(store.channelList, id: \.channelId) { model in
                            channelView(model: model)
                                .onTapGesture {
                                    store.send(.selectedModel(model))
                                }
                        }
                    }
                    .listStyle(.plain)
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .navigationTitle("채널 탐색")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        WSXImage.xImage
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .asButton {
                                store.send(.dismissTapped)
                            }
                    }
                }
                .navigationBarBackButtonHidden()
                .toolbar(.hidden, for: .tabBar)
                CustomAlertView(
                    alertMode: .cancelWith,
                    isShowing: $store.ifNeedChannelAlert.sending(\.channelAlertBool),
                    title: "채널 참여",
                    message: store.chaannelAlertMessage,
                    onCancel: {
                        store.send(.channelAlertCancel)
                    },
                    onAction: {
                        store.send(.channelALertConfirm)
                    },
                    actionTitle: "확인"
                )
            }
        }
    }
}

extension WorkSpaceChannelListView {
    
    private func channelView(model: ChanelEntity) -> some View {
        HStack {
            if let image = model.coverImage {
                DownSamplingImageView(url: URL(string: image), size: CGSize(width: 30, height: 30))
                    .frame(width: 30, height: 30)
            } else {
                WSXImage.shapBold
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            VStack(alignment: .leading) {
                Text(model.name)
                    .font(WSXFont.title1)
                if model.description != "" {
                    Text(model.description)
                        .font(WSXFont.caption)
                }
            }
        }
    }
}

//#Preview {
//    WorkSpaceChannelListView(store: Store(initialState: {
//        WorkSpaceChannelListFeature.State(id: UUID(), workSpaceID: "e655f5f4-dee7-4703-a9c4-8409e9f11f10")
//    }(), reducer: {
//        WorkSpaceChannelListFeature()
//    }))
//}
