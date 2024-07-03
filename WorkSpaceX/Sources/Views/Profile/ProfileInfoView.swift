//
//  ProfileInfoView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/3/24.
//

import SwiftUI
import ComposableArchitecture

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
        }
    }
    
    /// 본인일 경우
    enum MyProfileViewType {
        
        enum TopSection: CaseIterable {
            case myCoinInfo
            case nickName
            case contact
            
            var title: String {
                switch self {
                case .myCoinInfo:
                    return "내 새싹 코인"
                case .nickName:
                    return "닉네임"
                case .contact:
                    return "연락처"
                }
            }
            func detail(from model: UserEntity) -> String? {
                switch self {
                case .myCoinInfo:
                    // 코인 정보를 받으셔야함.
                    return ""
                case .nickName:
                    return model.nickname
                case .contact:
                    return model.phone
                }
            }
        }
        
        enum BottomSection: CaseIterable {
            case email
            case connectedSocial
            case logout
            
            var title: String {
                switch self {
                case .email:
                    return "이메일"
                case .connectedSocial:
                    return "연결된 소셜 계정"
                case .logout:
                    return "로그아웃"
                }
            }
            
            func detail(from model: UserEntity) -> String? {
                
                switch self {
                case .email:
                    return model.email
                case .connectedSocial:
                    return model.provider
                case .logout:
                    return nil
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
    }
    private func meProfileView(model: UserEntity) -> some View {
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
    
    private func myListView(model: UserEntity) -> some View {
        List {
            Section {
                ForEach(MyProfileViewType.TopSection.allCases, id: \.self) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Text(item.detail(from: model) ?? "")
                        Image(systemName: "chevron.right")
                            .foregroundStyle(WSXColor.gray)
                    }
                }
            }
            
            Section {
                ForEach(MyProfileViewType.BottomSection.allCases, id: \.self) { item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Text(item.detail(from: model) ?? "")
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
