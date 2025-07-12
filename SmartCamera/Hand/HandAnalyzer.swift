//
//  HandAnalyzer.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 10.07.2025.
//

import SwiftUI

struct HandAnalyzer: View {
    enum HandDestination {
        case handDetector
        case drawing

        var title: String {
            switch self {
            case .handDetector:
                "Hand Detector"
            case .drawing:
                "Drawing"
            }
        }

        var systemImage: String {
            switch self {
            case .handDetector:
                "hand.raised"
            case .drawing:
                "paintbrush.pointed"
            }
        }
    }

    var body: some View {
        HStack(spacing: 32) {
            button(for: .handDetector)
            button(for: .drawing)
        }
        .navigationDestination(for: HandDestination.self, destination: page)
    }

    private func button(for destination: HandDestination) -> some View {
        NavigationLink {
            page(for: destination)
        } label: {
            Label(destination.title, systemImage: destination.systemImage)
        }
    }

    @ViewBuilder
    private func page(for destination: HandDestination) -> some View {
        switch destination {
        case .handDetector:
            VideoHandView()
        case .drawing:
            HandDrawingView()
        }
    }
}
