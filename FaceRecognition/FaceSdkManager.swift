//
//  FaceSDKManager.swift
//  FaceRecognition
//
//  Created by Jorge Ramos on 24/09/25.
//

import SwiftUI
import FaceSDK

enum FaceSDKManagerError: Error, LocalizedError {
    case noResultsFound

    var errorDescription: String? {
        switch self {
        case .noResultsFound:
            return "No matching results found."
        }
    }
}

final class FaceSDKManager {
    static func matchFaces(request: MatchFacesRequest, completion: @escaping (Result<String, Error>) -> Void) {
        FaceSDK.service.matchFaces(request) { response in
            if let error = (response as AnyObject).value(forKey: "error") as? Error {
                completion(.failure(error))
                return
            }

            let results = response.results
            guard !results.isEmpty else {
                completion(.failure(FaceSDKManagerError.noResultsFound))
                return
            }

            let lines = results.map { r -> String in
                let simText = String(format: "%.2f", r.similarity?.doubleValue ?? 0.0)
                let scoreText = String(format: "%.2f", r.score?.doubleValue ?? 0.0)
                return "Result : Score \(scoreText), Similarity \(simText)"
            }

            completion(.success(lines.joined(separator: "\n")))
        }
    }
}
