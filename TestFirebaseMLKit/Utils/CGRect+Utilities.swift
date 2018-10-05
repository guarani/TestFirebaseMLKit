//
//  CGRect+Utilities.swift
//  TestFirebaseMLKit
//
//  Created by Paul Von Schrottky on 7/8/18.
//  Copyright © 2018 Schrottky. All rights reserved.
//

import UIKit

/// Computed additions to CGRect.
extension CGRect {
    
    /// The center of the rectangle.
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
