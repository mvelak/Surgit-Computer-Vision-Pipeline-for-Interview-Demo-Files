//
//  PersonSmoother.swift
//  Surgit
//
//  Created by Marco Vela on 11/7/25.
//

import CoreGraphics

final class PersonSmoother {
    private var keypointFilters: [Int: PointSmoother] = [:]

    func smooth(person: Person, timestamp: Double) -> Person {
        var smoothedKeypoints: [Keypoint] = []
        
        for k in person.keypoints {
            let smoother: PointSmoother
            
            if let existing = keypointFilters[k.index] {
                smoother = existing
            } else {
                let s = PointSmoother(minCutoff: 1.0, beta: 0.1, dCutoff: 1.0)
                keypointFilters[k.index] = s
                smoother = s
            }

            smoothedKeypoints.append(
                Keypoint(
                    id: k.id,
                    index: k.index,
                    point: smoother.filter(point: k.point, timestamp: timestamp),
                    confidence: k.confidence
                )
            )
        }

        return Person(
            id: person.id,
            boundingBox: person.boundingBox,
            keypoints: smoothedKeypoints,
            confidence: person.confidence
        )
    }
}

final class PointSmoother {
    private let xFilter: OneEuroFilter
    private let yFilter: OneEuroFilter

    init(minCutoff: Double = 1.0, beta: Double = 0.1, dCutoff: Double = 1.0) {
        self.xFilter = OneEuroFilter(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff)
        self.yFilter = OneEuroFilter(minCutoff: minCutoff, beta: beta, dCutoff: dCutoff)
    }

    func filter(point: CGPoint, timestamp: Double) -> CGPoint {
        CGPoint(
            x: xFilter.filter(value: Double(point.x), timestamp: timestamp),
            y: yFilter.filter(value: Double(point.y), timestamp: timestamp)
        )
    }
}
