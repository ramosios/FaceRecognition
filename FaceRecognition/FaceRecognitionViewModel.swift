//
//  FaceRecognitionViewModel.swift
//  FaceRecognition
//
//  Created by Jorge Ramos on 24/09/25.
//

import SwiftUI
import FaceSDK

@MainActor
final class FaceRecognitionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showResultAlert = false
    @Published var resultMessage = ""

    func calculateSimilarity(firstImage: UIImage?, secondImage: UIImage?) {
        guard let firstImage = firstImage, let secondImage = secondImage else {
            resultMessage = "Please select two images."
            showResultAlert = true
            return
        }

        isLoading = true

        let firstFaceImage = MatchFacesImage(image: firstImage, imageType: .printed)
        let secondFaceImage = MatchFacesImage(image: secondImage, imageType: .printed)
        let request = MatchFacesRequest(images: [firstFaceImage, secondFaceImage])

        FaceSDKManager.matchFaces(request: request) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let message):
                    self.resultMessage = message
                case .failure(let error):
                    self.resultMessage = error.localizedDescription
                }
                self.showResultAlert = true
            }
        }
    }
}
