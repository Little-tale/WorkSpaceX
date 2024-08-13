//
//  Const.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import Foundation

enum Const {
    enum SplashView {
        static let bennerTitel = "WorkSpaceX와 함께라면,\n일의 효율이 올라가요!"
        static let startText = "시작하기"
    }
    
    
    enum SignUpView: String, CaseIterable {
        case email = "이메일"
        case nickName = "닉네임"
        case contact = "연락처"
        case password = "비밀번호"
        case passwordCheck = "비밀번호 확인"
        
        var title: String {
            return self.rawValue
        }
        
        var placeHolder: String {
            return switch self {
             case .email:
                "이메일을 입력하세요"
             case .nickName:
                "닉네임을 입력하세요"
             case .contact:
                "연락처를 입력하세요"
             case .password:
                "비밀번호를 입력하세요"
             case .passwordCheck:
                "비밀번호를 한번더 입력하세요"
             }
        }
    }
    
    enum ChannelSetting {
        static let exitChannel = "채널에서 나가기"
        static let deleteChannel = "채널 삭제"
        static let ownerChangeChannel = "채널 관리자 변경"
        static let editChannel = "채널 편집"
        
        static let memberSection = "멤버"
        static let navigationTitle = "채널 설정"
        
        static let changedOwnerMessage = "채널 관리자가 변경되었습니다."
    }
}
