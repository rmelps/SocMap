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
import FirebaseStorage

enum MenuWindows {
    case main
    case broadcast
}

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var broadcastImageUploadProgressBar: UIProgressView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet var broadcastView: UIView!
    @IBOutlet weak var broadcastImage: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet var menuView: UIView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var signInButton: SignInButton!
    @IBOutlet weak var signUpButton: SignInButton!
    
    // Database branch references
    var broadcastDBRef: FIRDatabaseReference!
    var userDBRef: FIRDatabaseReference!
    
    // File storage references
    var storage: FIRStorage!
    var storageRef: FIRStorageReference!
    var imagesRef: FIRStorageReference!
    
    var map: MKMapView!
    var timer: Timer?
    var effect: UIVisualEffect!
    var currentUser: User! {
        didSet{
            refreshAnnotationsAsync()
        }
    }
    var initializingLocation = true
    var initializingMapScroll = true
    var currentPopUp: MenuWindows? = nil
    var fromCamera: Bool = false
    
    let borderColor = UIColor(red: 96/255, green: 170/255, blue: 1.0, alpha: 1.0).cgColor
    
    // Constraints dealing with popup windows (main and broadcast)
    var centerX = NSLayoutConstraint()
    var centerY = NSLayoutConstraint()
    
    // Reference to available broadcasts
    var broadcasts = [Broadcast]()
    var annotations = [BroadcastTowerPin]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = nil
        
        // bring navigation bar to front in order for interaction
        self.view.bringSubview(toFront: navBar)
        
        // Create reference to FIRDatabase service
        broadcastDBRef = FIRDatabase.database().reference().child("broadcast-items")
        userDBRef = FIRDatabase.database().reference().child("user-profiles")
        
        // Create reference to FIRStorage service
        storage = FIRStorage.storage()
        storageRef = storage.reference()
        imagesRef = storageRef.child("broadcastImages")
        
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
        broadcastView.layer.cornerRadius = 10
        
        // Configure broadcast menu
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        broadcastView.frame.size.width = screenWidth
        broadcastView.frame.size.height = screenHeight - (navBar.frame.height * 2)
        heightConstraint.constant = broadcastView.frame.height / 2
        descriptionText.layer.cornerRadius = 20
        descriptionText.layer.borderWidth = 3.0
        descriptionText.layer.borderColor = borderColor
        descriptionText.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if fromCamera {
            animateIn(withWindow: .broadcast)
            fromCamera = false
        }
        
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if initializingLocation {
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        
        let reuseIdentifier = "towerPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        if let broadcastAnnotation = annotation as? BroadcastTowerPin {
            let pinImage = UIImage(named: broadcastAnnotation.pinCustomImageName)
            let size = CGSize(width: 50, height: 50)
        
            UIGraphicsBeginImageContext(size)
            pinImage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            annotationView?.image = resizedImage
            
            
            
            
        }
        
        return annotationView
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        
        if let broadcastAnnotation = view.annotation as? BroadcastTowerPin {
            print("broadcast annotation selected")
            
            let views = Bundle.main.loadNibNamed("BroadcastCalloutView", owner: nil, options: nil)
            let calloutView = views?[0] as! BroadcastCalloutView
            calloutView.descriptionText.text = broadcastAnnotation.descriptionText
            calloutView.postedByLabel.text = broadcastAnnotation.postedBy
            calloutView.postTime.text = broadcastAnnotation.postTime
            calloutView.likesLabel.text = String(broadcastAnnotation.likes)
            calloutView.flagsLabel.text = String(broadcastAnnotation.flags)
            
            // Create a reference to the file that will be downloaded
            let reference = storage.reference(forURL: broadcastAnnotation.photoPath)
            
            // Download image at path to local memory with defined maximum size
            reference.data(withMaxSize: 10 * 1024 * 1024) { (data:Data?, error:Error?) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let data = data {
                    calloutView.image.image = UIImage(data: data)!
                }
            }
            
            calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
            view.addSubview(calloutView)
            mapView.setCenter((view.annotation?.coordinate)!, animated: true)
            
            
        }
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
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func signInButtonTapped(_ sender: SignInButton) {
        self.performSegue(withIdentifier: "signInSegue", sender: self)
    }
    @IBAction func signUpButtonTapped(_ sender: SignInButton) {
        self.performSegue(withIdentifier: "signUpSegue", sender: self)
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        
        if currentPopUp != .main {
            self.performSegue(withIdentifier: "showCamera", sender: self)
        }
    }
    @IBAction func refreshButtonTapped(_ sender: Any) {
        
        if currentUser != nil {
        
            map.removeAnnotations(map.annotations)
            storeActiveBroadcasts()
            
            for broadcast in self.broadcasts {
                let lattitude = Double(broadcast.coordinate["lattitude"] ?? "0.0")
                let longitude = Double(broadcast.coordinate["longitude"] ?? "0.0")
                
                let location = CLLocationCoordinate2D(latitude: lattitude!, longitude: longitude!)
                
                let towerAnnotation = BroadcastTowerPin()
                towerAnnotation.pinCustomImageName = "BroadcastTower"
                towerAnnotation.coordinate = location
                
                
                let towerAnnotationView = MKPinAnnotationView(annotation: towerAnnotation,reuseIdentifier: "towerPin")
                self.map.addAnnotation(towerAnnotationView.annotation!)
            }
            
        } else {
            map.removeAnnotations(map.annotations)
        }
        
    }
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        guard currentPopUp != .broadcast else {
            return
        }
        animateIn(withWindow: .main)
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
    @IBAction func broadcastButtonTapped(_ sender: UIButton) {
        
        descriptionText.resignFirstResponder()
        sender.isEnabled = false
        
        // Time&Date related parameters for finding current date at upload
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let nanoSec = calendar.component(.nanosecond, from: date)
        
        let timeStampIdentifier = "\(hour)\(minute)\(second)\(nanoSec)"
        
        let time = ["hour": String(hour), "minute": String(minute), "second": String(second), "nano": String(nanoSec)]
        
        // Create Data object from broadcastImage
        let broadcastImageData = UIImageJPEGRepresentation(broadcastImage.image!, 1.0)
        let imageRef = imagesRef.child("\(currentUser.uid)\(timeStampIdentifier)")
        
        // Create the upload task to handle sending data to FIRStorage
        let uploadTask = imageRef.put(broadcastImageData!, metadata: nil) { (metaData:FIRStorageMetadata?, error:Error?) in
            guard let metaData = metaData else {
                print(error?.localizedDescription ?? "error description not found")
                sender.isEnabled = true
                return
            }
        
            if let coordinate = self.locationManager.location?.coordinate {
                
                let downloadURL = "\(metaData.downloadURL()!)"
            
                let lattitude = "\(coordinate.latitude)"
                let longitude = "\(coordinate.longitude)"
                let coordinateString = ["lattitude": lattitude, "longitude": longitude]
            
                let broadcast = Broadcast(content: self.descriptionText.text, addedByUser: self.currentUser.userName, photoPath: downloadURL, time: time, coordinate: coordinateString)
                let broadcastTopRef = self.broadcastDBRef.child("\(self.currentUser.uid)")
                let broadcastBotRef = broadcastTopRef.child(timeStampIdentifier)
                broadcastBotRef.setValue(broadcast.toAny())
                self.animateOut()
                self.broadcastImageUploadProgressBar.isHidden = true
                self.broadcastImageUploadProgressBar.progress = 0.0
                self.descriptionText.text = ""
                sender.isEnabled = true
                self.refreshAnnotationsAsync()
            }
        }
        
        uploadTask.observe(.progress) { (snapShot:FIRStorageTaskSnapshot) in
            self.broadcastImageUploadProgressBar.isHidden = false
            if let progressFraction = snapShot.progress?.fractionCompleted {
                self.broadcastImageUploadProgressBar.progress = Float(progressFraction)
            }
        }
        
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
    
    func animateIn(withWindow window: MenuWindows) {
        var subView = UIView()
        
        switch window {
        case .main:
            subView = menuView
            currentPopUp = .main
            
        case .broadcast:
            subView = broadcastView
            currentPopUp = .broadcast
        }
        
        self.view.bringSubview(toFront: visualEffectView)
        self.view.bringSubview(toFront: navBar)
        self.view.addSubview(subView)
        subView.layer.borderColor = borderColor
        subView.layer.borderWidth = 3.0
        
        centerX = subView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        centerY = subView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        centerX.isActive = true
        centerY.isActive = true
        
        subView.center = self.view.center
        
        subView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        subView.alpha = 0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.animateOut))
        
        UIView.animate(withDuration: 0.4, animations: { 
            self.visualEffectView.effect = self.effect
            subView.alpha = 1
            subView.transform = CGAffineTransform.identity
        }) { (complete) in
            self.visualEffectView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func animateOut() {
        var subView = UIView()
        switch currentPopUp {
        case MenuWindows.main?:
            subView = menuView
        case MenuWindows.broadcast?:
            subView = broadcastView
        default:
            break
        }
        
        UIView.animate(withDuration: 0.4, animations: { 
            subView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            subView.alpha = 0
            self.visualEffectView.effect = nil
        }) { (_) in
            subView.removeFromSuperview()
            self.view.sendSubview(toBack: self.visualEffectView)
        }
        
        currentPopUp = nil
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.view.bringSubview(toFront: navBar)
        centerY.isActive = false
        UIView.animate(withDuration: 0.3) { 
            self.broadcastView.center.y = self.view.center.y - self.broadcastView.frame.height / 2
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.broadcastView.center.y = self.view.center.y
        }) { (_) in
            self.centerY.isActive = true
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func storeActiveBroadcasts() {
        broadcastDBRef.observe(.value) { (snapShot:FIRDataSnapshot) in
            var newBroadcasts = [Broadcast]()
            var userIDs = [String]()
            
            // First, we need to store each branch corresponding to the each user uid
            // that currently has an active broadcast
            for id in snapShot.children {
                userIDs.append((id as AnyObject).key)
            }
            
            // For each user uid, we will follow the branch associated with that user
            // to iterate over all active broadcasts and store the data locally
            for key in userIDs {
                let childSnapshot = snapShot.childSnapshot(forPath: key)
                
                for child in childSnapshot.children {
                    let broadcastObject = Broadcast(snapShot: child as! FIRDataSnapshot)
                    newBroadcasts.append(broadcastObject)
                }
            }
            
            self.broadcasts = newBroadcasts
        }
    }
    
    func refreshAnnotationsAsync() {
        if currentUser != nil {
            storeActiveBroadcasts()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
                print("firing timer...")
                self.map.removeAnnotations(self.map.annotations)
                
                for broadcast in self.broadcasts {
                    let lattitude = Double(broadcast.coordinate["lattitude"] ?? "0.0")
                    let longitude = Double(broadcast.coordinate["longitude"] ?? "0.0")
                    
                    let location = CLLocationCoordinate2D(latitude: lattitude!, longitude: longitude!)
                    
                    let towerAnnotation = BroadcastTowerPin()
                    towerAnnotation.pinCustomImageName = "BroadcastTower"
                    towerAnnotation.photoPath = broadcast.photoPath
                    towerAnnotation.coordinate = location
                    towerAnnotation.postedBy = broadcast.addedByUser
                    towerAnnotation.postTime = broadcast.uploadTime["hour"]
                    towerAnnotation.likes = 0
                    towerAnnotation.flags = 0
                    towerAnnotation.descriptionText = broadcast.content
                    
                    let towerAnnotationView = MKPinAnnotationView(annotation: towerAnnotation, reuseIdentifier: "towerPin")
                    self.map.addAnnotation(towerAnnotationView.annotation!)
                }
            })
        } else {
            map.removeAnnotations(map.annotations)
        }
    }
}

