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
            ZStack {
                VStack {
                    switch store.state.userType {
                    case .me:
                        meProfileView()
                    case .other:
                        otherProfileView()
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
                .popup(item: $store.logOutViewState.sending(\.logOutViewState)) { model in
                    CustomAlertViewWithPopUpView(
                        alertMode: .cancelWith,
                        title: model.title,
                        message: model.message,
                        onCancel: {
                            store.send(.logOutViewState(nil))
                        },
                        onAction: {
                            store.send(.logOutConfirm)
                        },
                        actionTitle: model.action
                    )
                    .padding(.horizontal, 20)
                } customize: {
                    $0
                        .appearFrom(.centerScale)
                        .animation(.easeInOut)
                        .position(.center)
                        .closeOnTap(false)
                        .backgroundColor(.black.opacity(0.4))
                }
                
                if store.progress {
                    ProgressView()
                        .frame(width: 70, height: 70)
                }
                
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
        .navigationTitle("내 정보 수정")
    }
    private func meProfileView(model: UserInfoEntity) -> some View {
        VStack {
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
            HStack {
                Spacer()
                imagePickView()
                Spacer()
            }
            .listRowBackground(Color.clear)
            Section {
                topSectionView(model)
            }
            Section {
                bottomSectionView(model)
            }
        }
        .scrollDisabled(true)
    }
    
    private func imagePickView() -> some View {
        ZStack(alignment: .bottomTrailing) {
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

extension ProfileInfoView {
    private func topSectionView(_ model: UserInfoEntity) -> some View {
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
    @ViewBuilder
    private func bottomSectionView(_ model: UserInfoEntity) -> some View {
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
/// 본인이 아닐 경우의 뷰
extension ProfileInfoView {
    private func otherProfileView() -> some View {
        VStack {
            if let model = store.otherEntity {
                otherProfileView(model: model)
                    .navigationTitle(model.nickName)
            } else {
                ProgressView()
            }
        }
       
    }
    
    private func otherProfileView(model: WorkSpaceMemberEntity) -> some View {
        List {
            HStack {
                Spacer()
                otherProfileImageView(model)
                Spacer()
            }
            .listRowBackground(Color.clear)
            Section {
                otherProfileSectionView(model)
            }
        }
        .scrollDisabled(true)
    }
    
    private func otherProfileImageView(_ model: WorkSpaceMemberEntity) -> some View {
        Group {
            if let image = model.profileImage {
                DownSamplingImageView(
                    url: URL(string: image),
                    size: CGSize(width: 150, height: 150)
                )
                .frame(width: 150, height: 150)
            } else {
                WSXImage.profileEmpty1
                    .resizable()
                    .frame(width: 100, height: 100)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
   
    private func otherProfileSectionView(_ model: WorkSpaceMemberEntity) -> some View {
        ForEach(ProfileInfoFeature.OtherViewType.section, id: \.self) { caseOf in
            HStack {
                Text(caseOf.title)
                    .font(WSXFont.title2)
                Spacer()
                Text(caseOf.detail(model))
                    .font(WSXFont.regu1)
                    .foregroundStyle(WSXColor.black.opacity(0.8))
            }
        }
    }
}
