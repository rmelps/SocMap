//
//  CreateProfileViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/25/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class CreateProfileViewController: UIViewController, UITextFieldDelegate {

    var createdUser: User!
    var userDBRef: FIRDatabaseReference!
    var password: String!
    var homeViewController: HomeViewController!
    var signUpViewController: SignUpViewController!
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor(red: 96/255, green: 170/255, blue: 1.0, alpha: 1.0).cgColor
        view.layer.borderWidth = 3.0
        userNameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func createUserName(_ sender: SignInButton) {
        FIRAuth.auth()?.signIn(withEmail: createdUser.email, password: password, completion: {
            (user:FIRUser?, error:Error?) in
            if error == nil {
                self.userDBRef.child(user!.uid).observeSingleEvent(of: .value, with: { (snapShot) in
                    let uidString = "\(user!.uid)"
                    self.userDBRef.child("\(uidString)/userName").setValue(["userName":self.userNameTextField.text ?? "\(user!.uid)"])
                    
                    var signedUser = User(userData: user!, snapShot: snapShot)
                    signedUser.userName = self.userNameTextField.text ?? "\(user!.uid)"
                    print("Welcome \(signedUser.userName)")
                })
                self.signIn()
            } else {
                print(error?.localizedDescription ?? "error description not found")
            }
        })
    }
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        userNameTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userNameTextField.resignFirstResponder()
        return true
    }
    
    func signIn() {
        homeViewController.signUpButton.isEnabled = false
        homeViewController.signInButton.isEnabled = false
        self.dismiss(animated: true, completion: {
            UIView.animate(withDuration: 0.5, animations: {
                self.homeViewController.signInButton.alpha = 0
                self.homeViewController.signUpButton.alpha = 0
                self.homeViewController.navBar.alpha = 1
            })
            self.signUpViewController.dismiss(animated: false, completion: nil)
            self.homeViewController.timer?.invalidate()
            self.homeViewController.map.showsUserLocation = true
            if let location = self.homeViewController.locationManager.location?.coordinate {
                let span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
                let region = MKCoordinateRegion(center: location, span: span)
                self.homeViewController.map.setRegion(region, animated: true)
            }
            self.homeViewController.map.isUserInteractionEnabled = true
        })
    }
}
