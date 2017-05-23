//
//  DetailViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 5/22/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var photo: UIImage!
    var detailText: String!
    var time: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(DetailViewController.returnToHome))
        
        navigationItem.leftBarButtonItem = backButtonItem
        navigationController?.navigationBar.tintColor = .white
        
        image.image = photo
        textView.text = detailText
        timeLabel.text = time

        // Do any additional setup after loading the view.
    }
    
    func returnToHome() {
        self.navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

}
