//
//  WSXImage.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI

enum WSXImage {}

extension WSXImage {
    static let splashImage: Image = Image(.rootView).resizable()
    
    static let appleLogin: Image = Image(.applLoginButton).resizable()
    
    static let kakaoLogin: Image =  Image(.kakaoLoginButton).resizable()
        
    static let emailLoginButton: Image = Image(.emailLoginButton).resizable()
    
    static let xImage: Image = Image(systemName: "xmark").resizable().renderingMode(.template)
    static let removeX: Image = Image(.removeX)
    
    static let back: Image = Image(.backCross).renderingMode(.template)
    
    static let logoImage: Image = Image(.workSpaceXLogo)
    
    static let subCamera: Image = Image(.camera)
    
    static let workSpaceStart: Image = Image(.workSpaceinitStart)
    
    static let logoUIImage: UIImage = UIImage(resource: .workSpaceXLogo)
    
    static let homeImage: Image = Image(systemName: "house.fill")
    
    static let emptyImage: Image = Image(.empty)
    
    static let plus: Image = Image(.plus)
    
    static let help: Image = Image(.help)
    
    static let dots: Image = Image(systemName: "ellipsis")
    
    static let profileEmpty1 = Image(.profileEmpty)
    
    static let shapBold = Image(.hashTagBold).renderingMode(.template)
    
    static let shapThin = Image(.shapThin).renderingMode(.template)
    
    static let gallary = Image(systemName: "photo.fill")
    
    static let send = Image(.sendRegular)
    
    static let folder = Image(systemName: "folder.fill")
    
    static let hambergerList = Image(systemName: "list.bullet")
    
    static let dmsTab = Image(systemName: "paperplane.fill")
    
    static let searchImage = Image(systemName: "magnifyingglass")
    
    static let settingImage = Image(systemName: "person.crop.circle.fill")
    
    static let searchEmpty = Image(.searchEmpty)
    
    static let searchResultEmpty = Image(.serachResultEmpty)
    
    
    enum Coin {
        case mini
        case middel
        case big
        
        var image: Image {
            switch self {
            case .mini:
                return Image(.coinMini)
            case .middel:
                return Image(.coinMiddel)
            case .big:
                return Image(.coinBig)
            }
        }
    }
    
}
