//
//  Place.swift
//  EXITCapstone
//
//  Created by 김민국 on 2018. 7. 18..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import UIKit
import MapKit
class Place{
    var name: String?
    var address: String?
    var realName: String?
    var count: String?
    
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    var location: CLLocation {
        return CLLocation(latitude: self.latitude!, longitude: self.longitude!)
    }
    
    func distance(fromMy: CLLocation) -> CLLocationDistance {
        return self.location.distance(from: fromMy)
    }
}
