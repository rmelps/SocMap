//
//  EditImageViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 5/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

class EditImageViewController: UIViewController {
    
    @IBOutlet var capturedImage: UIImageView!
    
    @IBOutlet weak var doneButton: SignInButton!
    var image: UIImage!
    var editWindow: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        capturedImage.image = image

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(EditImageViewController.handlePan(recognizer:)))
        editWindow.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func loadView() {
        super.loadView()
        
        let screenCenter = self.view.center
        let screenSize = CGSize(width: self.view.frame.width, height: self.view.frame.width)
        let editWindowFrame = CGRect(origin: CGPoint.zero, size: screenSize)
        editWindow = UIView(frame: editWindowFrame)
        editWindow.center = screenCenter
        editWindow.clipsToBounds = true
        editWindow.backgroundColor = UIColor(white: 0.75, alpha: 0.5)
        self.view.addSubview(editWindow)
        self.view.bringSubview(toFront: doneButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "returnToHomeSegue":
            let vc = segue.destination as! HomeViewController
            vc.fromCamera = true
            vc.broadcastImage.image = createCroppedImage()
        default:
            break
        }
    }

    @IBAction func doneEditingButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "returnToHomeSegue", sender: self)
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if let myView = recognizer.view {
            let centerPoint = myView.convert(myView.center, to: self.view)
            let subHeight = myView.frame.height
            let mainHeight = view.frame.maxY
            let adjustedHeight = mainHeight
            
            
            let translation = recognizer.translation(in: self.view)
            
            if centerPoint.y >= centerPoint.x, centerPoint.y <= adjustedHeight {
                
                myView.center = CGPoint(x: self.view.center.x, y: recognizer.view!.center.y + translation.y)
                recognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            if centerPoint.y < centerPoint.x {
                myView.center = CGPoint(x: self.view.center.x, y: centerPoint.x + 0.1)
                recognizer.setTranslation(CGPoint.zero, in: self.view)
            }
            
            if centerPoint.y > adjustedHeight {
                let trans = centerPoint.y - adjustedHeight
                print(trans)
                print(recognizer.view!.center.y)
                myView.center = CGPoint(x: self.view.center.x, y: recognizer.view!.center.y - trans - 1)
                recognizer.setTranslation(CGPoint.zero, in: self.view)
            }

        }
    }
    
    func createCroppedImage() -> UIImage {
        
        return image
    }

}
