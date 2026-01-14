//
//  Person.swift
//  Surgit
//
//  Created by Marco Vela on 12/4/25.
//

import Foundation
import CoreGraphics

struct Person: Identifiable {
    let id: UUID
    let boundingBox: CGRect
    let keypoints: [Keypoint]
    let confidence: Float
    
    init(id: UUID = UUID(), boundingBox: CGRect, keypoints: [Keypoint], confidence: Float) {
        self.id = id
        self.boundingBox = boundingBox
        self.keypoints = keypoints
        self.confidence = confidence
    }
}
