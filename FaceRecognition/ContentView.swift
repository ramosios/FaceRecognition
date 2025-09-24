//
//  ContentView.swift
//  FaceRecognition
//
//  Created by Jorge Ramos on 24/09/25.
//

import SwiftUI
import PhotosUI
import FaceSDK

struct ContentView: View {
    @State private var images: [UIImage?] = [nil, nil]
    @State private var pickerItems: [PhotosPickerItem?] = [nil, nil]
    @State private var showResultAlert = false
    @State private var resultMessage = ""

    private let slotSize = CGSize(width: 320, height: 320)

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 20) {
                photosPickerSlot(index: 0)
                photosPickerSlot(index: 1)
            }
            .padding()

            HStack(spacing: 20) {
                Button("Calcular Similitud") {
                    calculateSimilarity()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    images = [nil, nil]
                    pickerItems = [nil, nil]
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(resultMessage, isPresented: $showResultAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    @ViewBuilder
    private func photosPickerSlot(index: Int) -> some View {
        PhotosPicker(selection: Binding(
            get: { pickerItems[index] },
            set: { newValue in
                pickerItems[index] = newValue
                loadImage(from: newValue, into: index)
            }
        ), matching: .images, photoLibrary: .shared()) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.secondary, lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.95)))

                if let uiImage = images[index] {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: slotSize.width, height: slotSize.height)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Tap to add")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: slotSize.width, height: slotSize.height)
            .contentShape(Rectangle())
            .padding(.horizontal)
        }
    }

    private func loadImage(from item: PhotosPickerItem?, into index: Int) {
        guard let item = item else {
            images[index] = nil
            return
        }

        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        images[index] = uiImage
                    }
                }
            } catch {
                await MainActor.run {
                    images[index] = nil
                }
            }
        }
    }

    private func calculateSimilarity() {
        guard let firstImage = images[0], let secondImage = images[1] else {
            resultMessage = "Please add both images before calculating similarity."
            showResultAlert = true
            return
        }
        let sdkImages = [
            MatchFacesImage(image: firstImage, imageType: .printed),
            MatchFacesImage(image: secondImage, imageType: .printed)
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

                    return "Result \(index + 1): score \(scoreText), similarity \(simText)"
                }

                DispatchQueue.main.async {
                    resultMessage = lines.joined(separator: "\n")
                    showResultAlert = true
                }
                return
            }

            // Handle error or empty response
            if let error = (response as AnyObject).value(forKey: "error") as? Error {
                DispatchQueue.main.async {
                    resultMessage = "Error: \(error.localizedDescription)"
                    showResultAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    resultMessage = "No matching results found."
                    showResultAlert = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
