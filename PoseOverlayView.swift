//
//  PoseOverlayView.swift
//  Surgit
//
//  Created by Marco Vela on 12/4/25.
//

import SwiftUI
import CoreGraphics

struct PoseOverlayView: View {
    let person: Person

    var body: some View {
        GeometryReader { geo in
            ZStack {
                let kMap = Dictionary(uniqueKeysWithValues: person.keypoints.map { ($0.index, $0) })

                // Points
                Path { path in
                    for (startIdx, endIdx) in Skeleton.connections {
                        if let start = kMap[startIdx], let end = kMap[endIdx] {
                            path.move(to: GeometryCalculator.scale(start.point, in: geo.size))
                            path.addLine(to: GeometryCalculator.scale(end.point, in: geo.size))
                        }
                    }
                }
                .stroke(Color.hyperVolt, lineWidth: 3)

                // Joints
                Path { path in
                    for keypoint in person.keypoints {
                        let pt = GeometryCalculator.scale(keypoint.point, in: geo.size)
                        path.addEllipse(in: CGRect(x: pt.x - 4, y: pt.y - 4, width: 8, height: 8))
                    }
                }
                .fill(Color.black)
            }
        }
    }
}
