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

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorCode: UILabel!
    
    // Properties grabbed from HomeViewController
    var signInButton: SignInButton!
    var signUpButton: SignInButton!
    var map: MKMapView!
    var timer: Timer!
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        errorCode.isHidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func signInButtonTapped(_ sender: SignInButton) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
                (user:FIRUser?, error:Error?) in
                if error == nil {
                    print(user?.email ?? "email address not created")
                    self.errorCode.isHidden = true
                    self.signUpButton.isEnabled = false
                    self.signInButton.isEnabled = false
                    self.dismiss(animated: true, completion: {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.signInButton.alpha = 0
                            self.signUpButton.alpha = 0
                        })
                        self.timer.invalidate()
                        self.map.showsUserLocation = true
                        if let location = self.locationManager.location?.coordinate {
                            let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                            let region = MKCoordinateRegion(center: location, span: span)
                            self.map.setRegion(region, animated: true)
                        }
                        self.map.isUserInteractionEnabled = true
                    })
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
}
