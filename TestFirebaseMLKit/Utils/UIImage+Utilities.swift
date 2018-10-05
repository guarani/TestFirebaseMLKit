//
//  UIImage+Utilities.swift
//  TestFirebaseMLKit
//
//  Created by Paul Von Schrottky on 7/1/18.
//  Copyright © 2018 Schrottky. All rights reserved.
//

import UIKit
import FirebaseMLVision

/// Additions to CGRect.
extension UIImage {
    
    /**
     Obtain an upright copy of the given image,
     
     - Returns: An upright copy of the given image.
     */
    func orientatedUp() -> UIImage {
        
        // If the image's orientation is already up, nothing to do.
        guard imageOrientation != .up else { return self }
        
        // Whether the image is opaque.
        let isOpaque = self.cgImage?.alphaInfo == .none
        
        // Create a context with the same size, opaque support, and scale as the original image.
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, scale)
        
        // Draw the image inside the original image area.
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        draw(in: rect)
        
        // Return the image from the context, then close the context.
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    
    /**
     Annotate a copy of the given image, with the bounding rectange drawn over it.
     
     - Returns: The new image.
     */
    func imageWith(template: Template, boundingRect: CGRect) -> UIImage? {
        
        // First, draw the image.
        UIGraphicsBeginImageContext(size)
        draw(at: .zero)
        
        // Grab the context and set setup the line properties.
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.setLineWidth(10)
        UIColor.green.setStroke()
        
        // Draw a path around each element.
        for element in template.elements {
            let cornerPoints = template.cornerPointsOf(templateElement: element, inTemplateRect: boundingRect)
            guard let firstCorner = cornerPoints.first else { continue }
            ctx.move(to: firstCorner)
            cornerPoints.forEach {
                ctx.addLine(to: $0)
            }
            ctx.closePath()
            ctx.strokePath()
        }
        
        let annotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return annotatedImage
    }
    
    func annotate(rectangle: CGRect, with color: UIColor) -> UIImage? {
        
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        ctx.setLineWidth(20)
        color.setStroke()
        
        ctx.stroke(rectangle)
        
        guard let annotatedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return annotatedImage
    }
    
    func debugAnnotatedWith(visionTexts: [VisionText]) -> UIImage? {
        
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        
        ctx.setLineWidth(10)
        
        for visionText in visionTexts {
            
            UIColor.blue.setStroke()
            
            let cornerPoints = visionText.cornerPoints.compactMap { $0 as? CGPoint }
            guard let firstCorner = cornerPoints.first else { continue }
            ctx.move(to: firstCorner)
            cornerPoints.forEach { ctx.addLine(to: $0) }
            ctx.closePath()
            ctx.strokePath()
        }
    
        
        guard let annotatedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return annotatedImage
    }
}
