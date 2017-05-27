//
//  CameraViewController.swift
//  SocialMap
//
//  Created by Richard Melpignano on 4/30/17.
//  Copyright © 2017 J2MFD. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var cancelImageButton: SignInButton!
    @IBOutlet weak var broadcastImageButton: SignInButton!
    @IBOutlet weak var captureImageButton: SignInButton!
    var downloadPicButton: UIButton?
    
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
        addDownloadButton()
        
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
        downloadPicButton?.alpha = 0
        
        if downloadPicButton == nil {
            self.addDownloadButton()
        }
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
            downloadPicButton?.alpha = 1
            
            print(capturedImage.image ?? "nothing here")
            print("captured image")
        }
    }
    
    func download(_ sender: UIButton) {
        
        PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(self.capturedImage.image!, self, #selector(CameraViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            case .restricted:
                print("restricted")
                self.displayDownloadStatus(status: .restricted, error: nil)
            case .denied:
                print("denied")
                self.displayDownloadStatus(status: .denied, error: nil)
            default:
                print("not saving photo")
            }
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            displayDownloadStatus(status: .authorized, error: error)
        } else {
            print("success")
            displayDownloadStatus(status: .authorized, error: nil)
        }
    }
    
    func displayDownloadStatus(status: PHAuthorizationStatus, error: Error?) {
        DispatchQueue.main.async {
            
        var newViews = [UIView]()
    
        let views = Bundle.main.loadNibNamed("SavedPhotoStatusView", owner: nil, options: nil)
        let statusView = views?[0] as! SavedPhotoStatusView
        
        switch status {
        case .authorized:
            if error != nil {
                statusView.label.text = "Error!"
                statusView.label.shadowColor = .red
            } else {
                statusView.label.text = "Photo Saved!"
                statusView.icon.image = UIImage(named: "Check")
                statusView.label.shadowColor = .green
            }
            print("authorized")
        case .restricted, .denied:
            statusView.label.text = "Denied!"
            statusView.icon.image = UIImage(named: "Denied")
            statusView.label.shadowColor = .red
        default:
            statusView.label.text = "Undefined Behavior"
            statusView.icon.image = UIImage(named: "Denied")
            statusView.label.shadowColor = .red
        }
            
        let blurView = UIVisualEffectView(frame: statusView.frame)
        blurView.effect = UIBlurEffect(style: .light)
        self.view.addSubview(blurView)
        newViews.append(blurView)
            
        self.view.addSubview(statusView)
        newViews.append(statusView)
        
        blurView.alpha = 0
        statusView.alpha = 0
        statusView.layer.borderWidth = 0.5
        statusView.layer.borderColor = UIColor.white.cgColor
        statusView.layer.cornerRadius = 4
        
        let width = 500
        let height = 500
        let size = CGSize(width: width, height: height)
        
        statusView.frame = CGRect(origin: CGPoint.zero, size: size)
            
            for view in newViews {
        
                view.translatesAutoresizingMaskIntoConstraints = false
        
                let centerXCon = view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
                let centerYCon = view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
                let leadingCon = view.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor)
                let trailingCon = view.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor)
                let heightCon = view.heightAnchor.constraint(equalToConstant: self.view.bounds.width / 3)
        
                leadingCon.isActive = true
                trailingCon.isActive = true
                centerXCon.isActive = true
                centerYCon.isActive = true
                heightCon.isActive = true
            }
            
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { 
            statusView.alpha = 0.85
            blurView.alpha = 0.85
        }, completion: { (_) in
            UIView.animate(withDuration: 0.7, delay: 1.0, options: .curveEaseIn, animations: { 
                statusView.alpha = 0
                blurView.alpha = 0
                if status == .authorized, error == nil {
                    self.downloadPicButton?.alpha = 0
                }
            }, completion: { (_) in
                statusView.removeFromSuperview()
                blurView.removeFromSuperview()
                if status == .authorized, error == nil {
                    self.downloadPicButton?.removeFromSuperview()
                    self.downloadPicButton = nil
                }
            })
        })
            
        }
        
    }
    
    func addDownloadButton() {
        let buttonFrame = captureImageButton.frame
        downloadPicButton = UIButton(frame: buttonFrame)
        downloadPicButton?.setImage(UIImage(named: "Download"), for: .normal)
        downloadPicButton?.addTarget(self, action: #selector(CameraViewController.download(_:)), for: .touchUpInside)
        downloadPicButton?.alpha = 0
        
        self.view.addSubview(downloadPicButton!)
        
        downloadPicButton?.translatesAutoresizingMaskIntoConstraints = false
        
        let centerConstraint = downloadPicButton?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let yConstraint = downloadPicButton?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60)
        
        centerConstraint?.isActive = true
        yConstraint?.isActive = true
    }
        
}
