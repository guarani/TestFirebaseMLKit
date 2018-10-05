//
//  ViewController.swift
//  TestFirebaseMLKit
//
//  Created by Paul Von Schrottky on 6/22/18.
//  Copyright © 2018 Schrottky. All rights reserved.
//

import UIKit
import FirebaseMLVision

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var outputTextArea: UITextView!
    
    /// The image view to hold the scanned template.
    var imageView: UIImageView!
    
    /// The image picker to allow the user to select/take a photo.
    let imagePickerController = UIImagePickerController()
    
    lazy var vision = Vision.vision()
    var textDetector: VisionTextDetector?
    
    var template: Template?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load a template.
        template = Template(fromJSONFileNamed: "ande")
        
        // Create the text detector.
        textDetector = vision.textDetector()
        
        // Create an image view inside the scroll view so as to handle zoom.
        view.setNeedsLayout()
        view.layoutIfNeeded()
        scrollView.delegate = self
        imageView = UIImageView(frame: scrollView.bounds)
        scrollView.addSubview(imageView)
    }

    @IBAction func loadImageAction(_ sender: Any) {
        
        // Configure the image picker.
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func assign(image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        scrollView.contentSize = image.size
    }
    
    func process(image: UIImage) {
        
        // Abort if there is no template.
        guard let template = self.template else { return }

        // Call ML Kit to detect text in the image.
        textDetector?.detect(in: VisionImage(image: image)) { features, error in
            
            // Handle errors or lack of data
            guard error == nil, let visionTexts = features, !visionTexts.isEmpty else {
                self.outputTextArea.text = error.debugDescription
                return
            }
            
            // Draw a rectange around the template.
            guard let templateRect = Utilities.rectFor(template: template, visionTexts: visionTexts) else { return }
            guard let imageWithTemplateRect = image.annotate(rectangle: templateRect, with: .red) else { return }
            self.assign(image: imageWithTemplateRect)
            
            // Draw rectangles around the template elements.
            guard let imageWithTemplateElementsRects = imageWithTemplateRect.imageWith(template: template, boundingRect: templateRect) else { return }  // REFACTOR
            self.assign(image: imageWithTemplateElementsRects)
            
            // Draw polygons around the vision texts.
            guard let imageWithVisionPolygons = imageWithTemplateElementsRects.debugAnnotatedWith(visionTexts: visionTexts) else { return }     // REFACTOR
            self.assign(image: imageWithVisionPolygons)
            
            
            let matches = Utilities.match(visionTexts: visionTexts, to: template, in: imageWithTemplateRect)
            self.outputTextArea.attributedText = Utilities.matchOutputFor(templateElements: matches)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    
    /// Handle image zoom.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    /// Handle selected image from system image picker.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Close the image picker.
        dismiss(animated: true, completion: nil)
        
        // Grab the image from the picker and upright it if need be.
        guard var image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        image = image.orientatedUp()
        
        // Process the image.
        process(image: image)
    }
    
    /// Handle cancelation of system image picker.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Close the image picker.
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate { }
