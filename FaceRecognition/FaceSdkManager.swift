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
    case licenseFileNotFound
    case failedToReadLicense
    case initializationFailed

    var errorDescription: String? {
        switch self {
        case .noResultsFound:
            return "No matching results found."
        case .licenseFileNotFound:
            return "License file not found."
        case .failedToReadLicense:
            return "Failed to read license file."
        case .initializationFailed:
            return "Initialization failed for an unknown reason."
        }
    }
}

final class FaceSDKManager {
    private static var isInitialized = false

    private static func initializeSDK(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let filePath = Bundle.main.path(forResource: "regula", ofType: "license") else {
            completion(.failure(FaceSDKManagerError.licenseFileNotFound))
            return
        }

        guard let licenseData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            completion(.failure(FaceSDKManagerError.failedToReadLicense))
            return
        }

        let initConfiguration = InitializationConfiguration {
            $0.licenseData = licenseData
            $0.licenseUpdate = false
        }

        FaceSDK.service.initialize(configuration: initConfiguration) { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if success {
                    self.isInitialized = true
                    completion(.success(()))
                } else {
                    completion(.failure(FaceSDKManagerError.initializationFailed))
                }
            }
        }
    }

    static func matchFaces(request: MatchFacesRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let performMatch = {
            FaceSDK.service.matchFaces(request) { response in
                FaceSDK.service.deinitialize()
                self.isInitialized = false

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

        if isInitialized {
            performMatch()
        } else {
            initializeSDK { result in
                switch result {
                case .success:
                    performMatch()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
