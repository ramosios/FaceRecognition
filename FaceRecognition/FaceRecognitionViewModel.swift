//
//  FaceRecognitionViewModel.swift
//  FaceRecognition
//
//  Created by Jorge Ramos on 24/09/25.
//
import SwiftUI
import FaceSDK

final class FaceRecognitionViewModel: ObservableObject {
    @Published var showResultAlert = false
    @Published var resultMessage = ""

    func calculateSimilarity(firstImage: UIImage?, secondImage: UIImage?) {
        guard let first = firstImage, let second = secondImage else {
            DispatchQueue.main.async {
                self.resultMessage = "Please add both images before calculating similarity."
                self.showResultAlert = true
            }
            return
        }

        let sdkImages = [
            MatchFacesImage(image: first, imageType: .printed),
            MatchFacesImage(image: second, imageType: .printed)
        ]
        let request = MatchFacesRequest(images: sdkImages)

        FaceSDKManager.matchFaces(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    self.resultMessage = message
                case .failure(let error):
                    self.resultMessage = "Error: \(error.localizedDescription)"
                }
                self.showResultAlert = true
            }
        }
    }
}
