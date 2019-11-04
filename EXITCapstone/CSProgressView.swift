//
//  CSProgressView.swift
//  EXITCapstone
//
//  Created by 김민국 on 2018. 7. 18..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit

@IBDesignable class CSProgressView: UIProgressView {

    @IBInspectable var barHeight: CGFloat {
        get{
            return transform.d * 2.0
        }
        set{
            let heightScalse = newValue / 2.0
            let c = center
            transform = CGAffineTransform(scaleX: 1.0, y: heightScalse)
            center = c
        }
    }
    
    override func draw(_ rect: CGRect) {
        
    }
 

}
