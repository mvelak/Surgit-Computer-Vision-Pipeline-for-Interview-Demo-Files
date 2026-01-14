//
//  Skeleton.swift
//  Surgit
//
//  Created by Marco Vela on 12/4/25.
//

struct Skeleton {
    static let connections: [(Int, Int)] = [
        (0,1), (0,2), (1,3), (2,4), // Face
        (5,6), (5,7), (7,9), (6,8), (8,10), // Arms
        (5,11), (6,12), // Torso
        (11,12), (11,13), (13,15), (12,14), (14,16) // Legs
    ]
}
