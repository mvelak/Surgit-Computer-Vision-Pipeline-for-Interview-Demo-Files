//
//  Keypoint.swift
//  Surgit
//
//  Created by Marco Vela on 12/4/25.
//

import Foundation
import CoreGraphics

struct Keypoint: Identifiable {
    let id: UUID
    let index: Int
    let point: CGPoint
    let confidence: Float
    
    init(id: UUID = UUID(), index: Int, point: CGPoint, confidence: Float) {
        self.id = id
        self.index = index
        self.point = point
        self.confidence = confidence
    }
}
