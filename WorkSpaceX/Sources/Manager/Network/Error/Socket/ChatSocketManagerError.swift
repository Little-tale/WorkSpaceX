//
//  ChatSocketManagerError.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/10/24.
//

import Foundation

enum ChatSocketManagerError: Error {
    case nilSocket
    case weakError
    case JSONDecodeError
    
    var message: String {
        switch self {
        case .nilSocket:
            return "인터넷 환경을 확인해 주세요"
        case .weakError:
            return "치명적이 에러가 발생했습니다."
        case .JSONDecodeError:
            return "모델을 불러오는중 문제가 발생 했어요!"
        }
    }
}
