//
//  SignUpViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/19/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var passwordCreateField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var errorCode: UILabel!
    @IBOutlet weak var signUpStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Assign delegates of text fields to this view controller.
        emailAddress.delegate = self
        passwordCreateField.delegate = self
        passwordConfirmField.delegate = self
        
        // Hide the errorCode until one is active
        errorCode.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonTapped(_ sender: SignInButton) {
        let email = emailAddress.text
        let password = passwordCreateField.text
        let passwordConfirm = passwordConfirmField.text
        if email != nil, password != nil, passwordConfirm != nil, password == passwordConfirm {
            FIRAuth.auth()?.createUser(withEmail: emailAddress.text!, password: passwordCreateField.text!, completion: {
                (user:FIRUser?, error:Error?) in
                if error == nil {
                    print(user?.email ?? "email address not created")
                    self.errorCode.isHidden = true
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
