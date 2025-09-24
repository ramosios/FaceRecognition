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
                ContentView()
            }
        }
    }
}
