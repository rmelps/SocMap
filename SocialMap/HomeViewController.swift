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

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet weak var signInButton: SignInButton!
    @IBOutlet weak var signUpButton: SignInButton!
    
    var map = MKMapView()
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure and load the map
        let location = CLLocationCoordinate2D(latitude: 42, longitude: -71)
        let span = MKCoordinateSpan(latitudeDelta: 150, longitudeDelta: 75)
        map.region = MKCoordinateRegion(center: location, span: span)
        map.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        map.mapType = .satellite
        map.layer.zPosition = -2
        map.isUserInteractionEnabled = false
        self.view.addSubview(map)
        
    
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setMapCenter(_:)), userInfo: nil, repeats: true)
        timer.fire()
        
        signInButton.layer.zPosition = 1
        signUpButton.layer.zPosition = 1
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
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
            let controller = vc.popoverPresentationController
            let anchor = controller!.sourceView
            
            if controller != nil {
                controller?.delegate = self
                controller?.sourceRect = anchor!.bounds
                controller?.canOverlapSourceViewRect = true
            }
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
}

