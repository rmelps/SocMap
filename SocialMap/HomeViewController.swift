//
//  HomeViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/18/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager = CLLocationManager()
    
    @IBOutlet var menuView: UIView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var signInButton: SignInButton!
    @IBOutlet weak var signUpButton: SignInButton!
    
    var broadcastDBRef: FIRDatabaseReference!
    var userDBRef: FIRDatabaseReference!
    var map: MKMapView!
    var timer: Timer?
    var effect: UIVisualEffect!
    var currentUser: User!
    var initializingLocation = true
    var initializingMapScroll = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = nil
        
        // bring navigation bar to front in order for interaction
        self.view.bringSubview(toFront: navBar)
        
        // Reference the firebase database where broadcasts & user profiles will be saved
        broadcastDBRef = FIRDatabase.database().reference().child("broadcast-items")
        userDBRef = FIRDatabase.database().reference().child("user-profiles")
        
        // Place buttons in front on mapView
        signInButton.layer.zPosition = 1
        signUpButton.layer.zPosition = 1
        
        
        // Assign the effect property to the visual effect view
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        
        // Slowly pan the mapView by calling setMapCenter every timeInterval
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setMapCenter(_:)), userInfo: nil, repeats: true)
        timer?.fire()
        
        menuView.layer.cornerRadius = 10
    }
    
    override func loadView() {
        super.loadView()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Set up location manager, ask for authorization if not set by user
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        
        // Configure and load the map
        map = MKMapView()
        map.delegate = self
        
        /*
        let location = CLLocationCoordinate2D(latitude: 41.739, longitude: -122.308)
        let span = MKCoordinateSpan(latitudeDelta: 60.0, longitudeDelta: 60.0)
        map.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        map.region = MKCoordinateRegion(center: location, span: span)
        map.mapType = .satellite
        map.layer.zPosition = -2
        map.isUserInteractionEnabled = false
        self.view.addSubview(map)
        
        // Add constraints to the mapView
        map.translatesAutoresizingMaskIntoConstraints = false
        let mapLeadingConstraint = map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let mapTrailingConstraint = map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        let mapTopConstraint = map.topAnchor.constraint(equalTo: self.view.topAnchor)
        let mapBottomConstraint = map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        mapLeadingConstraint.isActive = true
        mapTrailingConstraint.isActive = true
        mapTopConstraint.isActive = true
        mapBottomConstraint.isActive = true
 */
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if initializingLocation {
            print("found location")
            let location = CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 75.0, longitudeDelta: 75.0)
            map.region = MKCoordinateRegion(center: location, span: span)
            map.mapType = .satellite
            map.layer.zPosition = -2
            map.isUserInteractionEnabled = false
            self.view.addSubview(map)
            print(map.region.span)
            
            // bring navigation bar to front in order for interaction
            self.view.bringSubview(toFront: navBar)
            
            initializingLocation = false
            
            // Add constraints to the mapView
            map.translatesAutoresizingMaskIntoConstraints = false
            let mapLeadingConstraint = map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
            let mapTrailingConstraint = map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            let mapTopConstraint = map.topAnchor.constraint(equalTo: self.view.topAnchor)
            let mapBottomConstraint = map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            
            mapLeadingConstraint.isActive = true
            mapTrailingConstraint.isActive = true
            mapTopConstraint.isActive = true
            mapBottomConstraint.isActive = true
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if fullyRendered, initializingMapScroll {
        print("fully rendered")
        
        initializingMapScroll = false
        }
        
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print(error.localizedDescription)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "signInSegue":
            
            // Create the sign in window as a popover, anchored to the signInButton
            let vc = segue.destination as! SignInViewController
            vc.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height / 2)
            
            vc.signInButton = self.signInButton
            vc.signUpButton = self.signUpButton
            vc.map = self.map
            vc.timer = self.timer
            vc.locationManager = self.locationManager
            vc.navBar = self.navBar
            vc.userDBRef = self.userDBRef
            
            let controller = vc.popoverPresentationController
            let anchor = controller!.sourceView
            
            if controller != nil {
                controller?.delegate = self
                controller?.sourceRect = anchor!.bounds
                controller?.canOverlapSourceViewRect = true
            }
        case "signUpSegue":
            
            // Create the sign up window as a popover, anchored to the signInButton
            let vc = segue.destination as! SignUpViewController
            vc.preferredContentSize = CGSize(width: self.view.frame.width, height: 350)
            vc.signInButton = self.signInButton
            vc.signUpButton = self.signUpButton
            vc.homeViewController = self
            vc.userDBRef = self.userDBRef
            let controller = vc.popoverPresentationController
            let anchor = controller!.sourceView
            
            if controller != nil {
                controller?.delegate = self
                controller?.sourceRect = anchor!.bounds
                controller?.canOverlapSourceViewRect = true
            }
        case "showCamera":
            print("showing camera")
        default:
            preconditionFailure("Segue Identifier not found")
        }
    }
    @IBAction func signInButtonTapped(_ sender: SignInButton) {
        self.performSegue(withIdentifier: "signInSegue", sender: self)
    }
    @IBAction func signUpButtonTapped(_ sender: SignInButton) {
        self.performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showCamera", sender: self)
    }
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        animateIn()
    }
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        self.animateOut()
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            fatalError(error.localizedDescription)
        }
        signOut()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func setMapCenter(_ timer: Timer) {
        
        let panSpeed: Double = 0.1
        
        if (map.centerCoordinate.longitude + panSpeed) > 180 {
            map.centerCoordinate.longitude = -180.0
        }
        
        let newCoordinate = CLLocationCoordinate2D(latitude: map.centerCoordinate.latitude, longitude: map.centerCoordinate.longitude + panSpeed)
        let newRegion = MKCoordinateRegion(center: newCoordinate, span: map.region.span)
        map.setRegion(newRegion, animated: false)
    }
    
    func animateIn() {
        self.view.bringSubview(toFront: visualEffectView)
        self.view.bringSubview(toFront: navBar)
        self.view.addSubview(menuView)
        menuView.layer.borderColor = UIColor(red: 96/255, green: 170/255, blue: 1.0, alpha: 1.0).cgColor
        menuView.layer.borderWidth = 3.0
        
        let centerX = menuView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let centerY = menuView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        centerX.isActive = true
        centerY.isActive = true
        
        menuView.center = self.view.center
        
        menuView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        menuView.alpha = 0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.animateOut))
        
        UIView.animate(withDuration: 0.4, animations: { 
            self.visualEffectView.effect = self.effect
            self.menuView.alpha = 1
            self.menuView.transform = CGAffineTransform.identity
        }) { (complete) in
            self.visualEffectView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.4, animations: { 
            self.menuView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.menuView.alpha = 0
            self.visualEffectView.effect = nil
        }) { (_) in
            self.menuView.removeFromSuperview()
            self.view.sendSubview(toBack: self.visualEffectView)
        }
    }
    
    func signOut() {
        currentUser = nil
        signUpButton.isEnabled = true
        signInButton.isEnabled = true
        UIView.animate(withDuration: 0.5, animations: {
            self.signInButton.alpha = 1
            self.signUpButton.alpha = 1
            self.navBar.alpha = 0
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.setMapCenter(_:)), userInfo: nil, repeats: true)
            self.map.showsUserLocation = false
            let centerL = self.map.centerCoordinate
            let span = MKCoordinateSpan(latitudeDelta: 75.0, longitudeDelta: 75.0)
            let region = MKCoordinateRegion(center: centerL, span: span)
            self.map.setRegion(region, animated: false)
            self.timer?.fire()
            self.map.isUserInteractionEnabled = false
        })
    }
}

