//
//  GeometryCalculator.swift
//  Surgit
//
//  Created by Marco Vela on 12/4/25.
//

import CoreGraphics

struct GeometryCalculator {
    
    static func angle(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat {
        let v1 = CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
        let v2 = CGPoint(x: p3.x - p2.x, y: p3.y - p2.y)
        
        let angle1 = atan2(v1.y, v1.x)
        let angle2 = atan2(v2.y, v2.x)
        var degree = (angle2 - angle1) * 180 / .pi
        
        return min(degree, 360 - degree)
    }
    
    static func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    // Scales a point from ML model coordinate space to screen coordinate space.
    static func scale(_ point: CGPoint, in screenSize: CGSize) -> CGPoint {
        let imageSize = MLConfig.cameraInputSize
        let scale = max(screenSize.width / imageSize.width, screenSize.height / imageSize.height)
        let renderedWidth = imageSize.width * scale
        let renderedHeight = imageSize.height * scale
        let xOffset = (screenSize.width - renderedWidth) / 2
        let yOffset = (screenSize.height - renderedHeight) / 2

        let nx = point.x / MLConfig.inputSize.width
        let ny = point.y / MLConfig.inputSize.height

        return CGPoint(
            x: nx * renderedWidth + xOffset,
            y: ny * renderedHeight + yOffset
        )
    }
    
    /// Convenience methods for Keypoints
    static func angle(_ p1: Keypoint, _ p2: Keypoint, _ p3: Keypoint) -> CGFloat {
        return angle(p1: p1.point, p2: p2.point, p3: p3.point)
    }
    
    static func distance(_ p1: Keypoint, _ p2: Keypoint) -> CGFloat {
        return distance(p1: p1.point, p2: p2.point)
    }
    
    
}
