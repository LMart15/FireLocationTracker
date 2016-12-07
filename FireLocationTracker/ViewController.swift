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

class MapViewController: UIViewController,CLLocationManagerDelegate, UIApplicationDelegate {
    
    var dbRef:FIRDatabaseReference!
    var locations = [Location]()
    var authUser: String = ""
    var authUserUid:String = ""
    var initialLocation:CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    let myLocMgr = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference().child("location-points")
        
        initLocationManager()
        initFireAuth()

    }
    
    //Signout user to initiate pin removal
    func applicationDidEnterBackground(application: UIApplication) {
        do{
            try FIRAuth.auth()?.signOut()
        }catch{
            print("Error while signing out!")
        }
    }
    
    //get auth user
    func initFireAuth(){
        
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
    
    func initLocationManager(){
    
        myLocMgr.desiredAccuracy = kCLLocationAccuracyBest
        myLocMgr.requestWhenInUseAuthorization()
        myLocMgr.startUpdatingLocation()
        myLocMgr.distanceFilter = 5
        myLocMgr.delegate = self
    
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get the most recent coordinate
        let myCoordinates = locations.last! as CLLocation
        
        // get lat and longit
        let myLat = myCoordinates.coordinate.latitude
        let myLong = myCoordinates.coordinate.longitude
        let myCoordinates2D = CLLocationCoordinate2D(latitude: myLat, longitude: myLong)
        initialLocation = CLLocation(latitude: myLat, longitude: myLong)
        
        //Create location object to store in Firebase
        let currentlocation = Location(title: authUser, coordinate: myCoordinates2D, locationOfUser: authUser)
        
        //create dbref with authuid as key
        let currentlocationRef = self.dbRef.child(self.authUserUid)
        
        //set location value in firebase
        currentlocationRef.setValue(currentlocation.toAnyObject())
        
        //set disconnect listener
        currentlocationRef.onDisconnectRemoveValue()
        
    }
    
    //Zoom on current user location
    @IBAction func findMe(sender: AnyObject) {
    
                let regionRadius: CLLocationDistance = 1000
        
                func centerMapOnLocation(location: CLLocation) {
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                              regionRadius * 2.0, regionRadius * 2.0)
                    mapView.setRegion(coordinateRegion, animated: true)
                }
        
                centerMapOnLocation(initialLocation!)
        
    }
    
    //observe DB function to see changes in location value
    func startObservingDB() {
        dbRef.observeEventType(.Value, withBlock: { (snapshot:FIRDataSnapshot) in
            var newLocations = [Location]()
            
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
           
        
            for location in snapshot.children{
                let locationObject = Location(snapshot: location as! FIRDataSnapshot)
                
                //Filter authenticated user's location out
                if !locationObject.locationOfUser.containsString(self.authUser){
                    newLocations.append(locationObject)
                }
                
            }
            
            self.locations = newLocations
            self.mapView.addAnnotations(self.locations)
            
            //show default user location to get different pin
            self.mapView.showsUserLocation = true
            
            
            }) {(error:NSError) in
                print(error.description)
            }
    
    }

}

