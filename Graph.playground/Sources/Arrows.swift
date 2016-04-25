//
//  Arrows.swift
//  Graph
//
//  Created by Wojciech Czekalski on 21.03.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit

// https://gist.github.com/mayoff/4146780 rewritten in Swift

public struct Arrow {
    let from: CGPoint
    let to: CGPoint
    let tailWidth: CGFloat
    let headWidth: CGFloat
    let headLength: CGFloat
}

public extension UIBezierPath {
    convenience init(arrow: Arrow) {
        let length = CGFloat(hypotf(Float(arrow.to.x - arrow.from.x), Float(arrow.to.y - arrow.from.y)))
        var points = [CGPoint]()
        
        let tailLength = length - arrow.headLength;
        points.append(CGPointMake(0, arrow.tailWidth / 2))
        points.append(CGPointMake(tailLength, arrow.tailWidth / 2))
        points.append(CGPointMake(tailLength, arrow.headWidth / 2))
        points.append(CGPointMake(length, 0))
        points.append(CGPointMake(tailLength, -arrow.headWidth / 2))
        points.append(CGPointMake(tailLength, -arrow.tailWidth / 2))
        points.append(CGPointMake(0, -arrow.tailWidth / 2))
        
        var transform = UIBezierPath.transform(from: arrow.from, to: arrow.to, length: length)
        let path = CGPathCreateMutable()
        CGPathAddLines(path, &transform, points, 7)
        CGPathCloseSubpath(path)
        self.init(CGPath: path)
    }

    private static func transform(from start: CGPoint, to: CGPoint, length: CGFloat) -> CGAffineTransform {
        let cosine = (to.x - start.x) / length;
        let sine = (to.y - start.y) / length;
        return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
    }
    
    func shapeLayer() -> CAShapeLayer {
        let l = CAShapeLayer()
        let path = self.copy()
        let bounds = path.bounds
        let origin = bounds.origin
        
        path.applyTransform(CGAffineTransformMakeTranslation(-origin.x, -origin.y))
        
        l.path = path.CGPath
        l.frame = bounds
        return l
    }
}
