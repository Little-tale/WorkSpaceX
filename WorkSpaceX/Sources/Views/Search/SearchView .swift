//
//  SerachView .swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/5/24.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    
    @Perception.Bindable var store: StoreOf<SearchFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.viewCase {
                case .empty:
                    emptyView()
                    
                case .show:
                    searchResultView()
                    
                case .searchResultEmpty:
                    searchResultEmptyView()
                    
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(store.navigationTitle)
            .searchable(
                text: $store.searchText.sending(\.searchText),
                prompt: store.searchViewPlaceMent
            )
            .alert(
                item: $store.alertCase.sending(\.alertCase)) { item in
                    Text(item.title)
                } actions: { item in
                    Text(item.actionTitle)
                        .asButton {
                            store.send(.alertCase(nil))
                        }
                } message: { item in
                    Text(item.message)
                }
        }
    }
}


extension SearchView {
    
    private func searchResultView() -> some View {
        List {
            if !store.channels.isEmpty {
                channelsView()
            }
            if !store.members.isEmpty {
                membersView()
            }
        }
    }
    
    
    @ViewBuilder
    private func channelsView() -> some View {
        Text(Const.Search.channelSection)
            .font(WSXFont.title15)
            .padding(.bottom, 2)

        ScrollView(.horizontal) {
            LazyHStack(alignment: .center) {
                ForEach(store.channels, id: \.channelID) { model in
                    channelsView(model)
                        .asButton {
                            store.send(.selectedChannel(model))
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private func membersView() -> some View {
        Text(Const.Search.memberSection)
            .font(WSXFont.title15)
            .padding(.bottom, 2)
        
        LazyVStack(alignment: .center) {
            ForEach(store.members, id: \.userID) { model in
                memberView(model)
                    .asButton {
                        store.send(.selectedMember(model))
                    }
            }
        }
    }
    
    private func channelsView(_ model: WorkSpaceChannelEntity) -> some View {
        VStack {
            Group {
                if let image = model.coverImage {
                    DownSamplingImageView(url: URL(string: image), size: ImageResizingCase.middle.size)
                    .frame(width: 80, height: 80)
                } else {
                    WSXImage.logoImage
                        .resizable()
                        .frame(width: 80, height: 80)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.vertical, 4)
               
            Text(attributeString(
                text: model.name,
                filter: store.currentTextFilterText,
                font: WSXFont.title2,
                otherFont: WSXFont.title2,
                backColor: WSXColor.lightGreen.opacity(0.7)
            ))
            .frame(maxWidth: 78)
        }
    }
    
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
                Text(attributeString(
                    text: model.nickname,
                    filter: store.currentTextFilterText,
                    font: WSXFont.title2,
                    otherFont: WSXFont.title2,
                    backColor: WSXColor.lightGreen.opacity(0.7)
                ))
    
                Text(attributeString(
                    text: model.email,
                    filter: store.currentTextFilterText,
                    font: WSXFont.regu1,
                    otherFont: WSXFont.regu1,
                    backColor: WSXColor.lightGreen.opacity(0.7)
                ))
            }
            Spacer()
        }
    }
}

extension SearchView {
    
    func attributeString(
        text: String,
        filter: String,
        font: Font,
        otherFont: Font,
        backColor: Color
    ) -> AttributedString {
        var string = AttributedString(text)
        string.font = otherFont
        
        if let range = string.range(of: filter, options: [.caseInsensitive]) {
            string[range].font = font
            string[range].backgroundColor = backColor
        }

        return string
    }
}

extension SearchView {
    
    private func emptyView() -> some View {
        VStack {
            Spacer()
            
            Text(Const.Search.searchChannelORMember)
                .font(WSXFont.title0)
                .foregroundStyle(WSXColor.black)
                .padding(.bottom, 15)
            
            WSXImage.searchResultEmpty
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func searchResultEmptyView() -> some View {
        VStack {
            Spacer()
            
            Text(Const.Search.noSearchResults)
                .font(WSXFont.title0)
                .foregroundStyle(WSXColor.black)
                .padding(.bottom, 15)
            
            WSXImage.searchEmpty
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
}
