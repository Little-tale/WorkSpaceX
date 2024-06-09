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
        
        var value: String {
            return self.rawValue
        }
    }
    
    @UserDefaultsWrapper(key: Key.userID.value, placeValue: "")
    static var userID: String
    
    @UserDefaultsWrapper(key: Key.deviceToken.value, placeValue: "")
    static var deviceToken: String
    
    @UserDefaultsWrapper(key: Key.accessToken.value, placeValue: "")
    static var accessToken: String
    
    @UserDefaultsWrapper(key: Key.refreshToken.value, placeValue: "")
    static var refreshToken: String
    
    @UserDefaultsWrapper(key: Key.appleLoginNickName.value, placeValue: nil)
    static var appleLoginNickName: String?
}
