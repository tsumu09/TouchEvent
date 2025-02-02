//
//  ViewController.swift
//  TouchEvent
//
//  Created by 高橋紬季 on 2024/11/13.
//

import UIKit
import PhotosUI

class ViewController: UIViewController, PHPickerViewControllerDelegate {

    @IBOutlet var backgroundImageView: UIImageView!
    
    var selectedImageName: String = "flower"
    
    var ImageViewArray: [UIImageView] = []
    var redoArray: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        let location: CGPoint = touch.location(in: view)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        imageView.image = UIImage(named: selectedImageName)
        imageView.center = CGPoint(x: location.x, y: location.y)
        
        view.addSubview(imageView)
        
        ImageViewArray.append(imageView)
        
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImage1() {
        selectedImageName = "flower"
    }

    @IBAction func selectImage2() {
        selectedImageName = "cloud"
    }

    @IBAction func selectImage3() {
        selectedImageName = "heart"
    }

    @IBAction func selectImage4() {
        selectedImageName = "star"
    }
    
    @IBAction func changeBackground() {
        var configuration = PHPickerConfiguration()
        
        let filter = PHPickerFilter.images
        configuration.filter = filter
        let picker = PHPickerViewController(configuration: configuration)
        
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func save() {
        UIGraphicsBeginImageContextWithOptions(backgroundImageView.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: -backgroundImageView.frame.origin.x, y: -backgroundImageView.frame.origin.y)
        view.layer.render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
    }
    
    @IBAction func undo() {
        if ImageViewArray.isEmpty { return }
        ImageViewArray.last!.removeFromSuperview()
        let lastImageView = ImageViewArray.last!
        redoArray.append(lastImageView)
        lastImageView.removeFromSuperview()
        ImageViewArray.removeLast()
    }
    
    @IBAction func redo() {
        if redoArray.isEmpty { return }
        let lastRedoImageView = redoArray.last!
        ImageViewArray.append(lastRedoImageView)
        self.view.addSubview(lastRedoImageView)
        redoArray.removeLast()
    }
    //
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider
        if let itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self){
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in DispatchQueue.main.async {
                self.backgroundImageView.image = image as? UIImage
            }
          }
        }
        dismiss(animated: true)
    }
}

