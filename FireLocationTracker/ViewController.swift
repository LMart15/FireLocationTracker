//
//  ViewController.swift
//  FireLocationTracker
//
//  Created by Lawrence Martin on 2016-11-16.
//  Copyright © 2016 centennial. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class MapViewController: UIViewController {
    
    var dbRef:FIRDatabaseReference!
    var locations = [Location]()
    var authUser: String = ""
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference().child("location-points")
        
        
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        let regionRadius: CLLocationDistance = 1000
        
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                      regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        centerMapOnLocation(initialLocation)
        
        mapView.delegate = self
        
        
        //let location1 = Location(title: "Hilton", coordinate: CLLocationCoordinate2D(latitude: 21.2789, longitude: -157.8250), locationOfUser: "lawqm1@gmail.com")
        //let location2 = Location(title: "King", coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661), locationOfUser: "lawrenceqmartin@gmail.com")
        
        //let location1Ref = self.dbRef.child("hilton")
        //let location2Ref = self.dbRef.child("King")
        //location1Ref.setValue(location1.toAnyObject())
        //location2Ref.setValue(location2.toAnyObject())
        
    
        startObservingDB()
 
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            if let user = user{
                self.authUser = user.email!
                print(self.authUser)
                self.startObservingDB()
            }else{
                print("Unauthorized")
            }
        })
        
    }
    
    func startObservingDB() {
        dbRef.observeEventType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
            var newLocations = [Location]()
            
            for location in snapshot.children{
                let locationObject = Location(snapshot: location as! FIRDataSnapshot)
                newLocations.append(locationObject)
            }
            
                self.locations = newLocations
                self.mapView.addAnnotations(self.locations)
            
            }) {(error:NSError) in
                print(error.description)
            }
    
    }

}

