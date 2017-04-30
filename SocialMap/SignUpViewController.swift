//
//  SignUpViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/19/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var passwordCreateField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var errorCode: UILabel!
    @IBOutlet weak var signUpStackView: UIStackView!
    var signInButton: SignInButton!
    var signUpButton: SignInButton!
    var homeViewController: HomeViewController!
    var createdUser: User?
    var userDBRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor(red: 96/255, green: 170/255, blue: 1.0, alpha: 1.0).cgColor
        view.layer.borderWidth = 3.0
        // Assign delegates of text fields to this view controller.
        emailAddress.delegate = self
        passwordCreateField.delegate = self
        passwordConfirmField.delegate = self
        
        // Hide the errorCode until one is active
        errorCode.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "customizeSignUpSegue":
            let vc = segue.destination as! CreateProfileViewController
            vc.createdUser = self.createdUser
            vc.userDBRef = self.userDBRef
            vc.password = self.passwordCreateField.text
            vc.homeViewController = self.homeViewController
            vc.signUpViewController = self
        default:
            preconditionFailure("Segue identifier does not exist")
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: SignInButton) {
        let email = emailAddress.text
        let password = passwordCreateField.text
        let passwordConfirm = passwordConfirmField.text
        if email != nil, password != nil, passwordConfirm != nil, password == passwordConfirm {
            FIRAuth.auth()?.createUser(withEmail: emailAddress.text!, password: passwordCreateField.text!, completion: {
                (user:FIRUser?, error:Error?) in
                if error == nil {
                    self.errorCode.isHidden = true
                    self.createdUser = User(uid: user!.uid, email: user!.email!, userName: "User \(user!.uid)")
                    let userRef = self.userDBRef.child("\(user!.uid)")
                    userRef.setValue(self.createdUser?.toAny())
                    self.performSegue(withIdentifier: "customizeSignUpSegue", sender: self)
                } else {
                    print(error?.localizedDescription ?? "error description not found")
                    self.errorCode.text = error?.localizedDescription
                    self.errorCode.isHidden = false
                }
            })
        } else {
            self.errorCode.isHidden = false
            self.errorCode.text = "couldn't create account: unknown reason"
            print(errorCode.text!)
        }
        if password != passwordConfirm {
            self.errorCode.isHidden = false
            self.errorCode.text = "Passwords are not the same!"
        }
    }
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        emailAddress.resignFirstResponder()
        passwordCreateField.resignFirstResponder()
        passwordConfirmField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
