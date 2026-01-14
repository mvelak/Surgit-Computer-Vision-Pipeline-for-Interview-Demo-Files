//
//  CameraView.swift
//  Surgit
//
//  Created by Marco Vela on 12/4/25.
//

import SwiftUI
import AVFoundation


struct CameraView: View {
    @ObservedObject var viewModel: CameraViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack {
            theme.colors.background.ignoresSafeArea()
            
            switch viewModel.cameraAuthorizationStatus {
            case .authorized:
                ZStack {
                    PreviewView(session: viewModel.cameraService.session)
                        .ignoresSafeArea()
                    
                    if let person = viewModel.detectedPerson {
                        PoseOverlayView(person: person)
                            .allowsHitTesting(false)
                            .ignoresSafeArea()
                    }
                    
                    WorkoutStatsOverlay(viewModel: viewModel)
                        .allowsHitTesting(false)
                    
                    CameraUIView(
                        viewModel: viewModel,
                        onClose: {
                            viewModel.stopSession()
                            viewModel.resetExercise()
                            dismiss()
                        }
                    )
                }
                    .onAppear {
                        viewModel.startSession()
                    }
                    .onDisappear {
                        viewModel.resetExercise()
                    }
            case .denied, .restricted:
                permissionDeniedView
            case .notDetermined:
                ProgressView("Requesting Camera Access")
                    .task {
                        await viewModel.requestPermission()
                    }
            @unknown default:
                permissionDeniedView
            }
        }
        .navigationBarHidden(true)
    }
    
    private var permissionDeniedView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Camera Access Required")
                    .font(theme.typography.headline)
                    .foregroundColor(.white)
                
                Text("We need access to your camera to analyze movement in real-time. Please enable it in settings.")
                    .font(theme.typography.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Settings")
                        .font(theme.typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                                .stroke(Color.white, lineWidth: 1.5)
                        )
                }
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Not Now")
                        .font(theme.typography.body)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [theme.colors.background.opacity(0.9), theme.colors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}
