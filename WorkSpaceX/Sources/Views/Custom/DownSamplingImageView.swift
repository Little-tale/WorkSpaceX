//
//  DownSamplingImageView.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 6/13/24.
//

import SwiftUI
import Kingfisher

struct DownSamplingImageView: View {
    
    let url: URL?
    let size: CGSize
    
    var body: some View {
        KFImage(url)
            .resizable()
            .setProcessor(
                DownsamplingImageProcessor(
                    size: size
                )
            )
            .cacheOriginalImage()
    }
}
