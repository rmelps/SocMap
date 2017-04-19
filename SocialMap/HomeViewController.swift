//
//  HomeViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/18/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "signInSegue":
            
            // Create the sign in window as a popover, anchored to the signInButton
            let vc = segue.destination
            let controller = vc.popoverPresentationController
            let anchor = controller!.sourceView
            
            if controller != nil {
                controller?.delegate = self
                controller?.sourceRect = anchor!.bounds
            }
        case "signUpSegue":
            
            // Create the sign up window as a popover, anchored to the signInButton
            let vc = segue.destination
            let controller = vc.popoverPresentationController
            let anchor = controller!.sourceView
            
            if controller != nil {
                controller?.delegate = self
                controller?.sourceRect = anchor!.bounds
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


}

