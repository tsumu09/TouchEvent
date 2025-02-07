//
//  FirstViewController.swift
//  TouchEvent
//
//  Created by 高橋紬季 on 2025/01/29.
//

import UIKit

class FirstViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet var cameraImageView: UIImageView!
    @IBOutlet weak var textButton: UIButton!
    
    var originalImage: UIImage!
    var filter: CIFilter!
    var isTextModeActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutSideTextView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        textButton.setTitle("Text", for: .normal)
        textButton.setTitle("Text", for: .selected)
        textButton.addTarget(self, action: #selector(toggleTextMode), for: .touchUpInside)
    }
    
    @IBAction func takePhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        } else {
            print("error")
        }
        }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cameraImageView.image = info [.editedImage] as? UIImage
        
        originalImage = cameraImageView.image
        
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func savePhoto() {
        UIImageWriteToSavedPhotosAlbum(cameraImageView.image!, nil, nil, nil)
    }
    
    @IBAction func colorFilter() {
        let filterImage: CIImage = CIImage(image: originalImage)!
        
        filter = CIFilter(name: "CIColorControls")!
        filter.setValue(filterImage, forKey: kCIInputImageKey)
        
        filter.setValue(1.0, forKey: "inputSaturation")
        filter.setValue(0.5, forKey: "inputBrightness")
        filter.setValue(2.5, forKey: "inputContrast")
        
        let ctx = CIContext(options: nil)
        let cgImage = ctx.createCGImage(filter.outputImage!, from: filter.outputImage!.extent)
        cameraImageView.image = UIImage(cgImage: cgImage!)
    }
    
    @IBAction func openAlbum() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            
            picker.allowsEditing = true
            
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func snsPhoto() {
        
        let shareText = "写真加工いえい"
        
        let shareImage = cameraImageView.image!
        
        let activityItems: [Any] = [shareText, shareImage]
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        let excludedActivityTypes = [UIActivity.ActivityType.postToWeibo, .saveToCameraRoll, .print]
        
        activityViewController.excludedActivityTypes = excludedActivityTypes
        
        present(activityViewController, animated: true, completion: nil)
    }

    @objc func toggleTextMode() {
        isTextModeActive.toggle()
        textButton.isSelected = isTextModeActive
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: view)
        
        if isTextModeActive {
            addTextView(at: location)
        }
    }
    
    func addTextView(at location: CGPoint) {
        let textView = UITextView(frame: CGRect(x: location.x, y: location.y, width: 150, height: 50))
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isEditable = true
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.text = "タップして編集"
        
        setActiveTextViewStyle(textView)
        view.addSubview(textView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        textView.addGestureRecognizer(panGesture)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setActiveTextViewStyle(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        setInactiveTextViewStyle(textView)
    }
    
    func setActiveTextViewStyle(_ textView: UITextView) {
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
    }
    
    func setInactiveTextViewStyle(_ textView: UITextView) {
        textView.layer.borderWidth = 0
        textView.backgroundColor = UIColor.clear
    }
    
    @objc func handleTapOutSideTextView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func handleDrag(_ sender: UIPanGestureRecognizer) {
        guard let textView = sender.view as? UITextView else { return }
        
        let translation = sender.translation(in: view)
        textView.center = CGPoint(x: textView.center.x + translation.x, y: textView.center.y + translation.y)
        sender.setTranslation(.zero, in: view)
    }
    
}
