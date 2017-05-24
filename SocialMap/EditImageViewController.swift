//
//  EditImageViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 5/1/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import CoreGraphics

class EditImageViewController: UIViewController {
    
    @IBOutlet var capturedImage: UIImageView!
    
    @IBOutlet weak var doneButton: SignInButton!
    var image: UIImage!
    var editWindow: UIView!
    var cropArea: CGRect {
        
        get {
            let factor = self.capturedImage.image!.size.width / self.view.frame.width;
            let scale: CGFloat = 1.0
            let x = (self.editWindow.frame.origin.x - self.capturedImage.frame.origin.x) * scale * factor
            let y = (self.editWindow.frame.origin.y - self.capturedImage.frame.origin.y) * scale * factor
            let width = self.editWindow.frame.size.width * scale * factor;
            let height = self.editWindow.frame.size.height * scale * factor
            
            return CGRect(x: x, y: y, width: width, height: height);
        }
    }

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
            vc.broadcastImage.image = cropToBounds()
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
    
    func cropToBounds() -> UIImage? {
        
        guard let image = self.capturedImage.image else {
            return nil
        }
        

        let cgImage = image.cgImage
        var x = CGFloat()
        var y = CGFloat()
        
        let factor = self.capturedImage.image!.size.height / self.view.frame.height
        let diff = (self.capturedImage.image!.size.width - (self.capturedImage.bounds.width * factor)) / 2
        
        if self.capturedImage.image!.size.width > self.capturedImage.image!.size.height {
            x = diff
            y = (self.editWindow.frame.origin.y - self.capturedImage.frame.origin.y) * factor
        } else {
            y = diff
            x = (self.editWindow.frame.origin.y - self.capturedImage.frame.origin.y) * factor
        }
        
        
        let width = self.editWindow.frame.size.width * factor
        let height = self.editWindow.frame.size.height * factor
        
        
        let scaledCropArea = CGRect(
            x: x * image.scale,
            y: y * image.scale,
            width: width * image.scale,
            height: height * image.scale
        )
        
        let croppedCGImage = cgImage?.cropping(to: scaledCropArea)
        let croppedImage = UIImage(cgImage: croppedCGImage!, scale: image.scale, orientation: image.imageOrientation)
        
        return croppedImage
    }
    
    

}
