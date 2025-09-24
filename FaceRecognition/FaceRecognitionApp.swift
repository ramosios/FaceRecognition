//
//  FaceRecognitionApp.swift
//  FaceRecognition
//
//  Created by Jorge Ramos on 24/09/25.
//
import SwiftUI
import FaceSDK

@main
struct FaceRecognitionApp: App {
    @State private var initializationError: String?

    var body: some Scene {
        WindowGroup {
            Group {
                if let errorMessage = initializationError {
                    ErrorView(message: errorMessage)
                } else {
                    ContentView()
                }
            }
            .onAppear(perform: initializeFaceSDK)
        }
    }

    private func initializeFaceSDK() {
        guard let filePath = Bundle.main.path(forResource: "regula", ofType: "license") else {
            self.initializationError = "License file not found."
            return
        }

        guard let licenseData = try? Data(contentsOf: URL(fileURLWithPath:filePath)) else {
            self.initializationError = "Failed to read license file."
            return
        }

        let initConfiguration = InitializationConfiguration {
            $0.licenseData = licenseData
            $0.licenseUpdate = false
        }

        FaceSDK.service.initialize(configuration: initConfiguration) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.initializationError = error.localizedDescription
                } else if !success {
                    self.initializationError = "Initialization failed for an unknown reason."
                }
            }
        }
    }
}

