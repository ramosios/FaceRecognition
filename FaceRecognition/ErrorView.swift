//
//  ErrorView.swift
//  FaceRecognition
//
//  Created by Jorge Ramos on 24/09/25.
//
import SwiftUI

struct ErrorView: View {
    var message: String

    var body: some View {
        VStack {
            Image(systemName: "xmark.octagon.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 4)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
