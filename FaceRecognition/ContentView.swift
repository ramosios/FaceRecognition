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
    @StateObject private var viewModel = FaceRecognitionViewModel()
    @State private var images: [UIImage?] = [nil, nil]
    @State private var pickerItems: [PhotosPickerItem?] = [nil, nil]

    private let slotSize = CGSize(width: 320, height: 320)

    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                VStack(spacing: 20) {
                    photosPickerSlot(index: 0)
                    photosPickerSlot(index: 1)
                }
                .padding()

                HStack(spacing: 20) {
                    Button("Calcular Similitud") {
                        viewModel.calculateSimilarity(firstImage: images[0], secondImage: images[1])
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
            .disabled(viewModel.isLoading)
            .alert(viewModel.resultMessage, isPresented: $viewModel.showResultAlert) {
                Button("OK", role: .cancel) { }
            }

            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView("Calculando...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
            }
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
}

#Preview {
    ContentView()
}
