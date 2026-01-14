//
//  YoloOutputParser.swift
//  Surgit
//
//  Created by Marco Vela on 11/9/25.
//

import CoreML
import Accelerate

struct YOLOOutputParser {
    static let keypointCount = 17
    static let channelCount = 4 + 1 + (keypointCount * 3)
    
    static func decode(_ output: MLMultiArray) -> Person? {
        guard let data = try? UnsafeBufferPointer<Float>(output) else { return nil }
        
        let shape = output.shape
        let anchors = Int(truncating: shape[2])
        
        var topPerson: Person? = nil
        var topConfidence: Float = 0.0
        

        for i in 0..<anchors {
            let confidenceIndex = (4 * anchors) + i
            let confidence = data[confidenceIndex]
            
            guard confidence > MLConfig.confidenceThreshold, confidence > topConfidence else { continue }
        
            // Get the bounding box
            let cx = data[(0 * anchors) + i]
            let cy = data[(1 * anchors) + i]
            let w  = data[(2 * anchors) + i]
            let h  = data[(3 * anchors) + i]
            
            let boundingBox = CGRect(x: CGFloat(cx - w/2), y: CGFloat(cy - h/2), width: CGFloat(w), height: CGFloat(h))
            
            // Get the keypoints
            var keypoints: [Keypoint] = []
            for k in 0..<keypointCount {
                // Each keypoint has 3 values: x, y, confidence
                let offset = 5 + (k * 3)
                
                let kx = data[(offset * anchors) + i]
                let ky = data[((offset + 1) * anchors) + i]
                let kc = data[((offset + 2) * anchors) + i]
                
                if kc > MLConfig.keypointConfidenceThreshold {
                    keypoints.append(Keypoint(index: k, point: CGPoint(x: CGFloat(kx), y: CGFloat(ky)), confidence: kc))
                }
            }
            
            topConfidence = confidence
            topPerson = Person(boundingBox: boundingBox, keypoints: keypoints, confidence: confidence)
        }

        return topPerson
    }
}
