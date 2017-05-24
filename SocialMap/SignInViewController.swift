//
//  SignInViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/19/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseAuth
import MapKit
import CoreLocation
import FirebaseDatabase

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorCode: UILabel!
    
    // Properties grabbed from HomeViewController
    var signInButton: SignInButton!
    var signUpButton: SignInButton!
    var navBar: UINavigationBar!
    var map: MKMapView!
    var timer: Timer!
    var locationManager: CLLocationManager!
    var userDBRef: FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor(red: 96/255, green: 170/255, blue: 1.0, alpha: 1.0).cgColor
        view.layer.borderWidth = 3.0
        emailField.delegate = self
        passwordField.delegate = self
        errorCode.isHidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonTapped(_ sender: SignInButton) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
                (user:FIRUser?, error:Error?) in
                if error == nil {
                    self.userDBRef.child("\(user!.uid)").observeSingleEvent(of: .value, with: { (snapShot) in
                        print(user!.uid)
                        let signedUser = User(userData: user!, snapShot: snapShot)
                        print("Welcome \(signedUser.userName)")
                        let homeController = UIApplication.shared.keyWindow?.rootViewController as! HomeViewController
                        homeController.currentUser = signedUser
                    })
                    self.signIn()
                } else {
                    print(error?.localizedDescription ?? "error description not found")
                    self.errorCode.text = error?.localizedDescription
                    self.errorCode.isHidden = false
                }
            })
        }
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func signIn() {
        errorCode.isHidden = true
        signUpButton.isEnabled = false
        signInButton.isEnabled = false
        self.dismiss(animated: true, completion: {
            UIView.animate(withDuration: 0.5, animations: {
                self.signInButton.alpha = 0
                self.signUpButton.alpha = 0
                self.navBar.alpha = 1
            })
            if let location = self.locationManager.location?.coordinate {
                self.map.showsUserLocation = true
                let span = MKCoordinateSpan(latitudeDelta: 3, longitudeDelta: 3)
                let region = MKCoordinateRegion(center: location, span: span)
                self.map.setRegion(region, animated: true)
                self.map.isUserInteractionEnabled = true
                self.timer?.invalidate()
            }
        })
    }
}
