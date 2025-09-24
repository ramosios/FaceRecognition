//
//  ContentView.swift
//  FaceRecognition
//
//  Created by Jorge Ramos on 24/09/25.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var images: [UIImage?] = [nil, nil]
    @State private var pickerItems: [PhotosPickerItem?] = [nil, nil]
    @State private var showResultAlert = false
    @State private var resultMessage = ""

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
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            .frame(width: 320, height: 320)
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
    }
}

#Preview {
    ContentView()
}
