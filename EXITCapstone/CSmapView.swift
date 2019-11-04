//
//  CSmapView.swift
//  EXITCapstone
//
//  Created by 김민국 on 2018. 7. 18..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit
import MapKit

@IBDesignable class CSmapView: MKMapView {

    var fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        fillColor.setFill()
        path.fill()
        self.layer.mask = maskLayer
    }


}
