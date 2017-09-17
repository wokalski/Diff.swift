//
//  GraphView.swift
//  Graph
//
//  Created by Wojciech Czekalski on 19.03.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit

public struct Grid {
    let x: Int
    let y: Int
}

public struct Graph {
    let grid: Grid
    let bounds: CGRect
}

public extension Graph {
    func gridLayers() -> [CALayer] {
        guard grid.x > 0 && grid.y > 0 else {
            return []
        }

        var layers = [CALayer]()
        let lineWidth: CGFloat = 1
        let layer: (CGRect) -> CALayer = { rect in
            let layer = CALayer()
            layer.frame = rect
            layer.backgroundColor = UIColor.white.cgColor
            return layer
        }

        for i in 0 ... (grid.x) {
            let rect = CGRect(x: x(at: i), y: y(at: 0), width: lineWidth, height: bounds.height)
            layers.append(layer(rect))
        }

        for i in 0 ... (grid.y) {
            let rect = CGRect(x: x(at: 0), y: y(at: i), width: bounds.width, height: lineWidth)
            layers.append(layer(rect))
        }

        return layers
    }

    func rect(at point: Point) -> CGRect {
        let origin = coordinates(at: point)
        let width = x(at: point.x + 1) - origin.x
        let height = y(at: point.y + 1) - origin.y
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    func rects(row y: Int) -> [CGRect] {
        return (0 ..< grid.x).map {
            rect(at: Point(x: $0, y: y))
        }
    }

    func rects(column x: Int) -> [CGRect] {
        return (0 ..< grid.y).map {
            rect(at: Point(x: x, y: $0))
        }
    }

    func coordinates(at point: Point) -> CGPoint {
        return CGPoint(x: x(at: point.x), y: y(at: point.y))
    }

    func x(at x: Int) -> CGFloat {
        return bounds.width / CGFloat(grid.x) * CGFloat(x) + bounds.origin.x
    }

    func y(at y: Int) -> CGFloat {
        return bounds.height / CGFloat(grid.y) * CGFloat(y) + bounds.origin.y
    }
}
