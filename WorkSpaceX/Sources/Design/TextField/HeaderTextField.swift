//
//  HeaderTextFied.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI


struct HeaderTextField: View {
    
    let headerTitle: String
    let placeHolder: String
    let isSecure: Bool
    
    @Binding
    var binding: String

    var scopeColor: Bool
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(headerTitle)
                    .foregroundStyle(scopeColor ? WSXColor.errorRed : WSXColor.black)
            }
            Group{
                if isSecure {
                    SecureField(placeHolder, text: $binding)
                } else {
                    TextField(placeHolder, text: $binding)
                }
            }
            .modifier(DefaultTextFieldViewModifier())
            
        }
    }
}
