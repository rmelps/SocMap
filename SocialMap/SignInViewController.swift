//
//  SignInViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/19/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorCode: UILabel!

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
        
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: {
                (user:FIRUser?, error:Error?) in
                if error == nil {
                    print(user?.email ?? "email address not created")
                    self.errorCode.isHidden = true
                    self.performSegue(withIdentifier: "existingLogInSegue", sender: self)
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
