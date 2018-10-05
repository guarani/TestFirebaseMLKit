//
//  TemplateElement.swift
//  TestFirebaseMLKit
//
//  Created by Paul Von Schrottky on 7/1/18.
//  Copyright © 2018 Schrottky. All rights reserved.
//

import UIKit

/// A template-specific data element.
struct TemplateElement: Codable {
    
    ///
    let key: String
    
    /// User-facing label.
    let label: String
    
    /// A regex that represents this element's value.
    let regex: String?
    
    /// The value obtained by scanning the image.
    var value: String?
    
    /// The approximate position of this element (in millimeters)
    /// where (0, 0) is the top-left corner of the image.
    ///
    /// Note that CGPoint encodes its `x` and `y` components as an array.
    /// Therefore, the JSON representation of a CGPoint is an array, as [x, y],
    /// and `vertices` is an array of arrays.
    let vertices: [CGPoint]
}

