//
//  UserDefaultsWrapper.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/7/24.
//

import Foundation

enum UserDefaultCase {
    case none
    case recentry
}

@propertyWrapper
struct UserDefaultsWrapper<T: Codable> {
    let key: String
    let placeValue: T
    
    private let userDefaults = UserDefaults.standard
    
    var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key),
                  let value = try? WSXCoder.shared.jsonDecoding(model: T.self, from: data) else {
                return placeValue
            }
            return value
        } set {
            guard let data = try? WSXCoder.shared.JSONEncode(from: newValue)
            else {
                return
            }
            userDefaults.setValue(data, forKey: key)
        }
    }
    
}
