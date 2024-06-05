//
//  TextValidation.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import Foundation
/*
 중복 확인] 버튼 클릭 | 이메일 유효성 오류 | 이메일 형식이 올바르지 않습니다.

 [중복 확인] 버튼 클릭 | 사용 가능한 이메일 | 사용 가능한 이메일입니다.

 [중복 확인] 버튼 클릭 |. 이미 검증된 상태 | 사용 가능한 이메일입니다.
 
 [가입하기] 버튼 클릭 | 이메일 중복 미 확인 |. 이메일 중복 확인을 진행해주세요.

 [가입하기] 버튼 클릭 | 닉네임 조건 오류 | 닉네임은 1글자 이상 30글자 이내로 부탁드려요.

 [가입하기] 버튼 클릭 | 전화번호 유효성 오류 | 잘못된 전화번호 형식입니다.

 [가입하기] 버튼 클릭 |. 비밀번호 조건 오류 | 비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요.
 
 [가입하기] 버튼 클릭 | 비밀번호 불일치 | 작성하신 비밀번호가 일치하지 않습니다.

 [가입하기] 버튼 클릭 | 이미 가입된 회원 | 이미 가입된 회원입니다. 로그인을 진행해주세요.

 [가입하기] 버튼 클릭 | 기타 오류 | 에러가 발생했어요. 잠시 후 다시 시도해주세요.
 */

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
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+.com"
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
