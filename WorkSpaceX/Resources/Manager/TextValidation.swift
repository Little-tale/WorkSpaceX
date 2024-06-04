//
//  TextValidation.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import Foundation


enum textValidation: String {
    case isEmpty
    case minCount
    case match
    case noMatch
}



enum RegularExpressionCase {
    
    case email
    case password
    case nickName
    case phoneNumber
   
    
    var pattern: String {
        
        switch self {
        case .email:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        case .password:
            return "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        case .nickName:
            return  "^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\\u1100-\\u11FF\\u3130-\\u318F]{1,30}$"
        case .phoneNumber:
            return "^01([0-9]{1})([0-9]{3,4})([0-9]{4})$"
       
        }
    }
    
    
    func matchesPattern(_ string: String) -> textValidation {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            if regex.firstMatch(in: string, options: [], range: range) != nil {
                return .match
            }
            return .noMatch
        } catch {
            print("Invalid regex pattern: \(error.localizedDescription)")
            return .noMatch
        }
    }
    
    
    func matchesPatternBool(_ string: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            if regex.firstMatch(in: string, options: [], range: range) != nil {
                return true
            }
            return false
        } catch {
            print("Invalid regex pattern: \(error.localizedDescription)")
            return false
        }
    }
    
    func matchesResults(_ string: String) -> [NSTextCheckingResult] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)
            return regex.matches(in: string,options:[] , range: range)
        } catch {
            return []
        }
    }
    
    
    func formatterPhoneNumber(_ number: String) -> String {
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: number.utf16.count)
            guard let match = regex.firstMatch(in: number, options: [], range: range) else {
               return ""
            }
            
            let first = (number as NSString).substring(with: match.range(at: 1))
            let second = (number as NSString).substring(with: match.range(at: 2))
            
            let third = (number as NSString).substring(with: match.range(at: 3))
            
            return "01\(first)-\(second)-\(third)"
        } catch {
            return ""
        }
        
    }
    
    
}
