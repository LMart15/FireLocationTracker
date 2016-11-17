//
//  Locations.swift
//  FireLocationTracker
//
//  Created by Lawrence Martin on 2016-11-17.
//  Copyright © 2016 centennial. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MapKit

class Location: NSObject, MKAnnotation {
    let key:String!
    var title: String?
    let coordinate: CLLocationCoordinate2D
    let locationOfUser:String!
    let itemRef:FIRDatabaseReference?
    
    init(title: String, coordinate: CLLocationCoordinate2D, locationOfUser:String, key:String = "") {
        self.key = key
        self.title = title
        self.coordinate = coordinate
        self.locationOfUser = locationOfUser
        self.itemRef = nil
        
    }
    
    init(snapshot:FIRDataSnapshot){
        key = snapshot.key
        itemRef = snapshot.ref
        
        let MomentaryLatitude = (snapshot.value!["latitude"] as! NSString).doubleValue
        let MomentaryLongitude = (snapshot.value!["longitude"] as! NSString).doubleValue
        
        coordinate = CLLocationCoordinate2D(latitude: MomentaryLatitude as
            CLLocationDegrees, longitude: MomentaryLongitude as CLLocationDegrees)
        
        if let locationTitle = snapshot.value!["title"] as? String{
            title = locationTitle
        }else{
            title = ""
        }
        
        if let locationUser = snapshot.value!["locationOfUser"] as? String{
            locationOfUser = locationUser
        }else{
            locationOfUser = ""
        }
        
    }
    
    func toAnyObject() -> AnyObject {
        
        let lat : String = String(stringInterpolationSegment: coordinate.latitude)
        let lng : String = String(stringInterpolationSegment: coordinate.longitude)
        
        return ["title":title, "locationOfUser":locationOfUser, "latitude":lat, "longitude": lng]
    }
    
}


