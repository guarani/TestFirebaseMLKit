//
//  CGPoint+Utilities.swift
//  TestFirebaseMLKit
//
//  Created by Paul Von Schrottky on 7/8/18.
//  Copyright © 2018 Schrottky. All rights reserved.
//

import UIKit

extension CGPoint {
    func isInsidePolygon(vertices: [CGPoint]) -> Bool {
        guard !vertices.isEmpty else { return false }
        var j = vertices.last!, c = false
        for i in vertices {
            let a = (i.y > y) != (j.y > y)
            let b = (x < (j.x - i.x) * (y - i.y) / (j.y - i.y) + i.x)
            if a && b { c = !c }
            j = i
        }
        return c
    }
    
    func distanceTo(point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        let distance = sqrt(xDist * xDist + yDist * yDist)
        return distance
    }
}
