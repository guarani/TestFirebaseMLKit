//
//  Template.swift
//  TestFirebaseMLKit
//
//  Created by Paul Von Schrottky on 7/6/18.
//  Copyright © 2018 Schrottky. All rights reserved.
//

import UIKit

/// A template for scanning a specific type of document.
struct Template: Codable {
    
    /**
     Initializes a new template using the provided JSON representation.
     
     - Parameter named: The JSON file (must be in the project bundle).
     
     - Returns: A struct representation of the template, or nil, if no JSON file was found for the given name.
     */
    init?(fromJSONFileNamed named: String) {
        guard let url = Bundle.main.url(forResource: named, withExtension: "json") else { return nil }
        guard let jsonData = try? Data(contentsOf: url) else { return nil }
        guard let template = try? JSONDecoder().decode(Template.self, from: jsonData) else { return nil }
        self = template
    }
    
    /// The user-facing name of the template.
    let title: String
    
    /// The width of the template (in millimeters).
    let width: CGFloat
    
    /// The height of the template (in millimeters).
    let height: CGFloat
    
    /// The left margin of the template (in millimeters).
    let leftMargin: CGFloat
    
    /// The top margin of the template (in millimeters).
    let topMargin: CGFloat
    
    /// The right margin of the template (in millimeters).
    let rightMargin: CGFloat
    
    /// The bottom margin of the template (in millimeters).
    let bottomMargin: CGFloat
    
    /// The template's elements.
    let elements: [TemplateElement]
}

/// Computed template measurements.
extension Template {
    
    /// Left margin as a percentage of total width (including margins).
    var leftMarginRatio: CGFloat {
        return leftMargin / width
    }
    
    /// Top margin as a percentage of total height (including margins).
    var topMarginRatio: CGFloat {
        return topMargin / height
    }
    
    /// Right margin as a percentage of total width (including margins).
    var rightMarginRatio: CGFloat {
        return rightMargin / width
    }
    
    /// Bottom margin as a percentage of total height (including margins).
    var bottomMarginRatio: CGFloat {
        return bottomMargin / height
    }
    
    /**
     Translate the vertices of a template element to the coordinate system of the scanned image (using the template).
     E.g.: In a template of width 100mm and height 200mm, let's say that the top-left vertice of a given template
     element is at x 20mm and y 50mm. If the scanned image is of width 3000px and height 4000px, this method will
     return (for the top-left vertice):
     
     x = 3000 * 20 / 100 = 600px
     x = 4000 * 50 / 200 = 1000px
     
     - Parameter templateElement: The element to translate.
     - Parameter templateRect: The template rectangle.
     
     - Returns: The list of the element's vertices in the coordinate system of the scanned image.
     */
    func cornerPointsOf(templateElement: TemplateElement, inTemplateRect templateRect: CGRect) -> [CGPoint] {
        return templateElement.vertices.map { vertex in
            let x = templateRect.origin.x + templateRect.width * (vertex.x / width)
            let y = templateRect.origin.y + templateRect.height * (vertex.y / height)
            return CGPoint(x: x, y: y)
        }
    }
}
