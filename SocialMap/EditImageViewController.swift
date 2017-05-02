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
    
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        capturedImage.image = image

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
