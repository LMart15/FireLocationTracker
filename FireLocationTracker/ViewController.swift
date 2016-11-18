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

class MapViewController: UIViewController,CLLocationManagerDelegate {
    
    var dbRef:FIRDatabaseReference!
    var locations = [Location]()
    var authUser: String = ""
    var authUserUid:String = ""
    
    @IBOutlet weak var mapView: MKMapView!
    let myLocMgr = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference().child("location-points")
        
        myLocMgr.desiredAccuracy = kCLLocationAccuracyBest
        myLocMgr.requestWhenInUseAuthorization()
        myLocMgr.startUpdatingLocation()
        myLocMgr.distanceFilter = 5
        myLocMgr.delegate = self
        
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            if let user = user{
                self.authUser = user.email!
                self.authUserUid = user.uid
                print("uid:" + self.authUserUid)
                self.startObservingDB()
            }else{
                print("Unauthorized")
            }
        })
 
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get the most recent coordinate
        let myCoordinates = locations.last! as CLLocation
        
        // get lat and longit
        let myLat = myCoordinates.coordinate.latitude
        let myLong = myCoordinates.coordinate.longitude
        let myCoordinates2D = CLLocationCoordinate2D(latitude: myLat, longitude: myLong)
        
        // set span
        let myLatDelta = 0.05
        let myLongDelta = 0.05
        let mySpan = MKCoordinateSpan(latitudeDelta: myLatDelta, longitudeDelta: myLongDelta)
        let myRegion = MKCoordinateRegion(center: myCoordinates2D, span: mySpan)
        
        //Create location object to store in Firebase
        let currentlocation = Location(title: authUser, coordinate: myCoordinates2D, locationOfUser: authUser)
        
        
        let currentlocationRef = self.dbRef.child(self.authUserUid)
        currentlocationRef.setValue(currentlocation.toAnyObject())
        
    }
    
    @IBAction func findMe(sender: AnyObject) {
        
                //set initial location in Honolulu
                let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
                let regionRadius: CLLocationDistance = 1000
        
                func centerMapOnLocation(location: CLLocation) {
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                              regionRadius * 2.0, regionRadius * 2.0)
                    mapView.setRegion(coordinateRegion, animated: true)
                }
        
                centerMapOnLocation(initialLocation)
        
    }
    
    func startObservingDB() {
        dbRef.observeEventType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
            var newLocations = [Location]()
            
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            
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

