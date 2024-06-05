//
//  HeaderTextFied.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/4/24.
//

import SwiftUI


struct HeaderTextField: View {
    
    let headerTitle: String
    let ifValidText: String?
    let placeHolder: String
    let isSecure: Bool
    
    @Binding
    var binding: String
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(headerTitle)
               
            }
            Group{
                if isSecure {
                    SecureField(placeHolder, text: $binding)
                } else {
                    TextField(placeHolder, text: $binding)
                }
            }
            .modifier(DefaultTextFieldViewModifier())
            if let ifValidText {
                Text(ifValidText)
                    .foregroundStyle(WSXColor.errorRed)
                    .padding(.leading, 5)
            }
        }
    }
}
