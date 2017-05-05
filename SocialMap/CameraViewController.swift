//
//  CameraViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/30/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cancelImageButton: SignInButton!
    @IBOutlet weak var broadcastImageButton: SignInButton!
    @IBOutlet weak var captureImageButton: SignInButton!
    
    @IBOutlet var cameraView: UIView!
    @IBOutlet var capturedImage: UIImageView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraView.backgroundColor = UIColor(red: 96/255, green: 170/255, blue: 1.0, alpha: 1.0)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var input = AVCaptureDeviceInput()
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch {
            print("Can not access back camera")
        }
        
        if captureSession!.canAddInput(input) {
            
            captureSession?.addInput(input)
            
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession?.addOutput(stillImageOutput)
                
                let bounds = UIScreen.main.bounds
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                previewLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY)
                cameraView.layer.addSublayer(previewLayer!)
                previewLayer?.frame = bounds
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession?.startRunning()
        
        UIView.animate(withDuration: 0.5) { 
            self.cameraView.alpha = 1
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "editImageSegue":
            let vc = segue.destination as! EditImageViewController
            vc.image = self.capturedImage.image!
        default:
            preconditionFailure("segue identifier not configured")
        }
    }
    @IBAction func dismissCapturedImage(_ sender: Any) {
        capturedImage.isHidden = true
        
        captureImageButton.alpha = 1
        cancelImageButton.alpha = 0
        broadcastImageButton.alpha = 0
    }
    @IBAction func broadcastImage(_ sender: Any) {
        self.performSegue(withIdentifier: "editImageSegue", sender: self)
    }
    
    @IBAction func captureStillImage(_ sender: Any) {
        
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                 kCVPixelBufferWidthKey as String: 160,
                                 kCVPixelBufferHeightKey as String: 160]
            settings.previewPhotoFormat = previewFormat
            settings.flashMode = .auto
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
    
            capturedImage.isHidden = false
            capturedImage.image = UIImage(data: dataImage)
            
            
            captureImageButton.alpha = 0
            cancelImageButton.alpha = 1
            broadcastImageButton.alpha = 1
            
            print(capturedImage.image ?? "nothing here")
            print("captured image")
        }
    }
}
