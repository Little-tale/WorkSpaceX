//
//  ExIamportPayment.swift
//  WorkSpaceX
//
//  Created by Jae hyung Kim on 7/16/24.
//

import Foundation
import iamport_ios

extension IamportPayment: Identifiable {
    public var id: UUID {
        return UUID()
    }
}
