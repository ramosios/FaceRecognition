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

        FaceSDK.service.matchFaces(request) { response in
            let results = response.results
            if !results.isEmpty {
                let lines = results.enumerated().map { index, r -> String in
                    let scoreText: String
                    if let score = (r as AnyObject).value(forKey: "score") as? Double {
                        scoreText = String(format: "%.2f", score)
                    } else {
                        scoreText = "N/A"
                    }

                    let simText: String
                    if let sim = (r as AnyObject).value(forKey: "similarity") as? Double {
                        simText = String(format: "%.2f", sim)
                    } else {
                        simText = "N/A"
                    }

                    return "Result : Score \(scoreText), Similarity \(simText)"
                }

                DispatchQueue.main.async {
                    self.resultMessage = lines.joined(separator: "\n")
                    self.showResultAlert = true
                }
                return
            }

            if let error = (response as AnyObject).value(forKey: "error") as? Error {
                DispatchQueue.main.async {
                    self.resultMessage = "Error: \(error.localizedDescription)"
                    self.showResultAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    self.resultMessage = "No matching results found."
                    self.showResultAlert = true
                }
            }
        }
    }
}
