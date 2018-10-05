//
//  Utilities.swift
//  TestFirebaseMLKit
//
//  Created by Paul Von Schrottky on 7/1/18.
//  Copyright © 2018 Schrottky. All rights reserved.
//

import UIKit
import FirebaseMLVision

class Utilities {
    
    /**
     Returns the bounding box of the template including the margins.
     
     - Parameter template: A template to match.
     - Parameter visionTexts: A list of found vision texts.
     
     - Returns: The bounding box.
     */
    class func rectFor(template: Template, visionTexts: [VisionText]) -> CGRect? {
        
        // This is the bounding box of the found elements (does not include margins specified in template).
        guard let boundingElementsRect = boundingRectFor(visionTexts: visionTexts) else { return nil }
        
        // Inflate the bounding box to include the margins.
        print("before scale affine transform", boundingElementsRect)
        let newWidth = boundingElementsRect.width / (1 - template.leftMarginRatio - template.rightMarginRatio)
        let scaleX = newWidth / boundingElementsRect.width
        let newHeight = boundingElementsRect.height / (1 - template.topMarginRatio - template.bottomMarginRatio)
        let scaleY = newHeight / boundingElementsRect.height
        let scaleAffineTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledRect = boundingElementsRect.applying(scaleAffineTransform)
        print("after scale affine transform", scaledRect)
        
        // Shift the bounding box left and up to account for the scaling.
        let deltaX = (scaledRect.width - boundingElementsRect.width) / 2
        let deltaY = (scaledRect.height - boundingElementsRect.height) / 2
        let translateAffineTransform = CGAffineTransform(translationX: -deltaX, y: -deltaY)
        let translatedRect = scaledRect.applying(translateAffineTransform)
        print("after translate affine transform", translatedRect)
        
        return translatedRect
    }
    
    
    /**
     The bounding box of the given vision texts.
     
     - Parameter visionTexts: A list of detected vision texts.
     
     - Returns: The bounding box of the given vision texts.
     */
    fileprivate class func boundingRectFor(visionTexts: [VisionText]) -> CGRect? {
        
        // Make a list of the points that make up the corner points of all vision texts.
        let allPoints = visionTexts.reduce([]) { (partialResult, current) -> [CGPoint] in
            let points = current.cornerPoints.compactMap { $0 as? CGPoint }
            return partialResult + points
        }
        
        // Map all the points along the horizontal axis and find the left-most and right-most elements.
        let horizontals = allPoints.map { $0.x }
        guard let left = horizontals.sorted(by: <).first else { return nil }
        guard let right = horizontals.sorted(by: <).last else { return nil }
        
        // Map all the points along the vertical axis and find the top-most and bottom-most elements.
        let verticals = allPoints.map { $0.y }
        guard let top = verticals.sorted(by: <).first else { return nil }
        guard let bottom = verticals.sorted(by: <).last else { return nil }
        
        return CGRect(x: left, y: top, width: right - left, height: bottom - top)
    }
    
    
    /**
     A list of template elements that match the given image.
     
     - Parameter visionTexts: A list of detected vision texts.
     - Parameter template: A template to match.
     - Parameter image: The scanned image.
     
     - Returns: The matching elements.
     */
    class func match(visionTexts: [VisionText], to template: Template, in image: UIImage) -> [TemplateElement] {
        
        guard let templateRect = rectFor(template: template, visionTexts: visionTexts) else { return [] }
        
        var matchedTemplateElements = [TemplateElement]()
        
        for element in template.elements {
            
            // Filter out any texts that don't match the element's regex.
            var possibleVisionTexts = visionTexts.filter {
                if let regex = element.regex {
                    return Utilities.matches(for: regex, in: $0.text).count > 0
                }
                return true
            }
            
            let elementCornerPoints = template.cornerPointsOf(templateElement: element, inTemplateRect: templateRect)
            let elementCenter = approximateRectFor(vertices: elementCornerPoints).center
            
            let distances = possibleVisionTexts.map {
                $0.frame.center.distanceTo(point: elementCenter)
            }
            
            // Sort the closest distance first.
            let sortedDistances = distances.enumerated().sorted { $0.element < $1.element }
        
            // Get the closest vision text.
            if let offset = sortedDistances.first?.offset {
                var templateElement = element
                templateElement.value = possibleVisionTexts[offset].text
                matchedTemplateElements.append(templateElement)
            }
        }
        
        return matchedTemplateElements
    }
    
    
    /**
     An (inaccurate) bounding box for the given vertices.
     
     - Parameter vertices: A list of vertices.
     
     - Returns: A rectangle that roughly bounds the given vertices.
     */
    class func approximateRectFor(vertices: [CGPoint]) -> CGRect {
        let leftTop = vertices[0]
        let rightTop = vertices[1]
        let rightBottom = vertices[2]
        let leftBottom = vertices[3]
        let rect = CGRect(x: leftTop.x, y: leftTop.y, width: rightTop.x - leftTop.x, height: leftBottom.y - leftTop.y)
        return rect
    }
    
    
    /**
     Match a text string to the given regex.
     
     - Parameter regex: A regex.
     - Parameter text: A string to match.
     
     - Returns: A list of matches where the regex matches the text.
     */
    class func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    /**
     Obtain a description of a list of elements and their scanned values.
     
     - Parameter templateElements: An array of elements to list.
     
     - Returns: An attributed string describing a list of element-value pairs, delimited by new-lines.
     */
    class func matchOutputFor(templateElements: [TemplateElement]) -> NSAttributedString {
        
        let reportAttributedString = NSMutableAttributedString()
        
        for element in templateElements {
            guard let text = element.value else { continue }
            reportAttributedString.append(NSAttributedString(string: "• ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
            reportAttributedString.append(NSAttributedString(string: element.label + ": ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]))
            reportAttributedString.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
            reportAttributedString.append(NSAttributedString(string: "\n"))
        }
        
        return reportAttributedString
    }
}
