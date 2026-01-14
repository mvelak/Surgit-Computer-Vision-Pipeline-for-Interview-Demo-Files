//
//  PoseService.swift
//  Surgit
//
//  Created by Marco Vela on 12/4/25.
//

import Foundation
import CoreML
import Vision
import UIKit
import QuartzCore


protocol PoseServiceProtocol: Actor {
    func predict(pixelBuffer: CVPixelBuffer) async throws -> Person?
    func warmup() async
}

actor PoseService: PoseServiceProtocol {
    private var model: VNCoreMLModel?
    private let smoother = PersonSmoother()
    private var modelLoadTask: Task<VNCoreMLModel, Error>?
    
    init() {
    }
    
    private func ensureModelLoaded() async throws -> VNCoreMLModel {
        if let existingModel = model {
            return existingModel
        }
        
        // Use existing task if already loading
        if let loadTask = modelLoadTask {
            return try await loadTask.value
        }
        
        let loadTask = Task<VNCoreMLModel, Error> {
            let mlConfig = MLModelConfiguration()
            mlConfig.computeUnits = .all // .all uses Neural Engine
            
            guard let modelURL = Bundle.main.url(forResource: MLConfig.modelName, withExtension: "mlpackage") else {
                throw NSError(domain: "ModelLoad", code: -99, userInfo: [NSLocalizedDescriptionKey: "ML model not found"])
            }
            
            let coreMLModel = try MLModel(contentsOf: modelURL, configuration: mlConfig)
            return try VNCoreMLModel(for: coreMLModel)
        }
        
        modelLoadTask = loadTask
        let loadedModel = try await loadTask.value
        self.model = loadedModel
        return loadedModel
    }
    
    func warmup() async {
        print("Model Warmup Started...")
        
        // Load model asynchronously (first time)
        do {
            _ = try await ensureModelLoaded()
        } catch {
            print("Model Load Failed: \(error)")
            return
        }
        
        // Create a dummy 640x640 buffer
        guard let dummyBuffer = createDummyBuffer() else { return }
        
        do {
            _ = try await predict(pixelBuffer: dummyBuffer)
            print("Model Warmup Complete")
        } catch {
            print("Model Warmup Failed: \(error)")
        }
    }
    
    private func createDummyBuffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(MLConfig.inputSize.width),
            Int(MLConfig.inputSize.height),
            kCVPixelFormatType_32BGRA,
            attrs,
            &pixelBuffer
        )
        return pixelBuffer
    }
    
    func predict(pixelBuffer: CVPixelBuffer) async throws -> Person? {
        let model = try await ensureModelLoaded()
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                      let multiArray = results.first?.featureValue.multiArrayValue else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Parse the raw tensor
                let person = YOLOOutputParser.decode(multiArray)
                
                guard let person = person else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Smooth the results to reduce jitter
                Task { [weak self] in
                    guard let self = self else {
                        continuation.resume(returning: person)
                        return
                    }
                    
                    let smoothed = await self.smoother.smooth(person: person, timestamp: CACurrentMediaTime())
                    
                    continuation.resume(returning: smoothed)
                }
            }
            
            request.imageCropAndScaleOption = .scaleFill
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

}

