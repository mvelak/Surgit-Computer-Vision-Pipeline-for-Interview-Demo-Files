//
//  PointSmoother.swift
//  Surgit
//
//  Created by Marco Vela on 11/7/25.
//

class OneEuroFilter {
    private var minCutoff: Double
    private var beta: Double
    private var dCutoff: Double
    
    private var xPrev: Double?
    private var dxPrev: Double?
    private var tPrev: Double?
    
    init(minCutoff: Double, beta: Double, dCutoff: Double) {
        self.minCutoff = minCutoff
        self.beta = beta
        self.dCutoff = dCutoff
    }
    
    func filter(value: Double, timestamp: Double) -> Double {
        // If no history return the value right away
        guard let tPrev = tPrev, let xPrev = xPrev else {
            self.xPrev = value
            self.tPrev = timestamp
            self.dxPrev = 0.0
            return value
        }
        
        let dt = timestamp - tPrev
        let a_d = smoothingFactor(cutoff: dCutoff, dt: dt)
        let dx = (value - xPrev) / dt
        let dxHat = exponentialSmoothing(a: a_d, x: dx, xPrev: dxPrev ?? 0.0)
        let cutoff = minCutoff + beta * abs(dxHat)
        let a = smoothingFactor(cutoff: cutoff, dt: dt)
        let xHat = exponentialSmoothing(a: a, x: value, xPrev: xPrev)
        

        self.xPrev = xHat
        self.dxPrev = dxHat
        self.tPrev = timestamp
        
        return xHat
    }
    
    private func smoothingFactor(cutoff: Double, dt: Double) -> Double {
        let r = 2.0 * Double.pi * cutoff * dt
        return r / (r + 1.0)
    }
    
    private func exponentialSmoothing(a: Double, x: Double, xPrev: Double) -> Double {
        return a * x + (1.0 - a) * xPrev
    }
}
