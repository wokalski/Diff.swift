
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

        let tailLength = length - arrow.headLength
        points.append(CGPoint(x: 0, y: arrow.tailWidth / 2))
        points.append(CGPoint(x: tailLength, y: arrow.tailWidth / 2))
        points.append(CGPoint(x: tailLength, y: arrow.headWidth / 2))
        points.append(CGPoint(x: length, y: 0))
        points.append(CGPoint(x: tailLength, y: -arrow.headWidth / 2))
        points.append(CGPoint(x: tailLength, y: -arrow.tailWidth / 2))
        points.append(CGPoint(x: 0, y: -arrow.tailWidth / 2))

        let transform = UIBezierPath.transform(from: arrow.from, to: arrow.to, length: length)
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()
        self.init(cgPath: path)
    }

    private static func transform(from start: CGPoint, to: CGPoint, length: CGFloat) -> CGAffineTransform {
        let cosine = (to.x - start.x) / length
        let sine = (to.y - start.y) / length
        return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
    }

    func shapeLayer() -> CAShapeLayer {
        let l = CAShapeLayer()
        let bounds = self.bounds
        let origin = bounds.origin
        let path = copy() as! UIBezierPath

        path.apply(CGAffineTransform(translationX: -origin.x, y: -origin.y))

        l.path = path.cgPath
        l.frame = bounds
        return l
    }
}
