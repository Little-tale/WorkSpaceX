//
//  ProfileInfoView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/3/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct ProfileInfoView: View {
    
    @Perception.Bindable var store: StoreOf<ProfileInfoFeature>
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                switch store.state.userType {
                case .me:
                    meProfileView()
                case .other:
                    EmptyView()
                }
            }
            .onAppear {
                store.send(.onAppaer)
            }
            .toolbar(.hidden, for: .tabBar)
            .popup(item: $store.popUpViewState.sending(\.popUpViewState)) { text in
                PopupVIewSmallToColor(text: text, color: WSXColor.lightGreen)
            } customize: {
                $0
                    .type(.floater())
                    .position(.bottom)
                    .animation(.spring())
                    .autohideIn(1)
                    .closeOnTap(true)
            }

        }
    }
}
/// 본인일 경우의 뷰
extension ProfileInfoView {
    private func meProfileView() -> some View {
        VStack {
            if let model = store.userEntity {
                meProfileView(model: model)
            } else {
                ProgressView()
            }
        }
    }
    private func meProfileView(model: UserInfoEntity) -> some View {
        VStack {
            imagePickView()
            myListView(model: model)
            Spacer()
        }
        .fullScreenCover(isPresented: $store.showImagePicker.sending(\.imagePick)) {
            
            CustomImagePicker(
                isPresented: $store.showImagePicker.sending(\.imagePick),
                selectedLimit: 1,
                filter: .images,
                selectedDataForJPEG: { datas in
                    store.send(.imagePickerData(datas.first))
                })
        }
    }
    
    private func myListView(model: UserInfoEntity) -> some View {
        List {
            Section {
                ForEach(ProfileInfoFeature.MyProfileViewType.topSectionCases, id: \.self) { item in
                    HStack {
                        Text(item.title)
                            .font(WSXFont.title2)
                        if item == .myCoinInfo {
                            Text(item.detail(from: model) ?? "")
                                .foregroundStyle(WSXColor.green)
                            Spacer()
                            Text("충전하기")
                                .foregroundStyle(WSXColor.black.opacity(0.8))
                                .font(WSXFont.regu1)
                        } else {
                            Spacer()
                            Text(item.detail(from: model) ?? "")
                                .foregroundStyle(WSXColor.black.opacity(0.8))
                                .font(WSXFont.regu1)
                        }
                        Image(systemName: "chevron.right")
                            .foregroundStyle(WSXColor.gray)
                    }
                    .asButton {
                        store.send(.selectedMECase(item))
                    }
                }
            }
            
            Section {
                if !UserDefaultsManager.ifEmailLogin {
                    ForEach(ProfileInfoFeature.MyProfileViewType.bottomSectionCases, id: \.self) { item in
                        Group {
                            HStack {
                                Text(item.title)
                                Spacer()
                                Text(item.detail(from: model) ?? "")
                            }
                        }
                        .asButton {
                            store.send(.selectedMECase(item))
                        }
                    }
                } else {
                    ForEach(ProfileInfoFeature.MyProfileViewType.emalilLogginBottomSection, id: \.self) { item in
                        Group {
                            HStack {
                                Text(item.title)
                                Spacer()
                                Text(item.detail(from: model) ?? "")
                            }
                        }
                        .asButton {
                            store.send(.selectedMECase(item))
                        }
                    }
                }
            }
        }
    }
    
    private func imagePickView() -> some View {
        ZStack (alignment: .bottomTrailing) {
            CustomeImagePickView(
                store: store.scope(state: \.imagePick, action: \.imagePickFeature)
            )
            .modifier(RoudProfileImageModifier(frame: CGSize(width: 80, height: 80)))
            .asButton {
                store.send(.showImagePicker)
            }
            WSXImage.subCamera
                .resizable()
                .frame(width: 25, height: 25)
        }
    }
}
/// 본인이 아닐 경우의 뷰
extension ProfileInfoView {
    
}
