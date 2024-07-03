//
//  UserDefaultsManager.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation


enum UserDefaultsManager {
    
    enum Key: String {
        case deviceToken
        case userID
        case accessToken
        case refreshToken
        case appleLoginNickName
        case isfirstUser
        case userName
        case ifNeedChecked
        case workSpaceSelectedID
        case ifEmaliLogin
        var value: String {
            return self.rawValue
        }
    }
    
    @UserDefaultsWrapper(key: Key.userID.value, placeValue: nil)
    static var userID: String?
    
    @UserDefaultsWrapper(key: Key.deviceToken.value, placeValue: nil)
    static var deviceToken: String?
    
    @UserDefaultsWrapper(key: Key.accessToken.value, placeValue: nil)
    static var accessToken: String?
    
    @UserDefaultsWrapper(key: Key.refreshToken.value, placeValue: nil)
    static var refreshToken: String?
    
    @UserDefaultsWrapper(key: Key.appleLoginNickName.value, placeValue: nil)
    static var appleLoginNickName: String?
    
    @UserDefaultsWrapper(key: Key.isfirstUser.value, placeValue: true)
    static var isFirstUser: Bool
    
    @UserDefaultsWrapper(key: Key.userName.value, placeValue: nil)
    static var userName: String?
    
    @UserDefaultsWrapper(key: Key.ifNeedChecked.value, placeValue: false)
    static var ifNeedChecked: Bool
    @UserDefaultsWrapper(key: Key.workSpaceSelectedID.value, placeValue: "")
    static var workSpaceSelectedID: String
    
    @UserDefaultsWrapper(key: Key.ifEmaliLogin.value, placeValue: false)
    static var ifEmailLogin: Bool
}
