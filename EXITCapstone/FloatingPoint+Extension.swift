//
//  FloatingPoint+Extension.swift
//  EXITCapstone
//
//  Created by 김민국 on 2018. 7. 19..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}
