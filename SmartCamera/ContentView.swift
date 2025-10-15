//
//  ContentView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 27.06.2025.
//

import SwiftUI

struct ContentView: View {
    enum Destination: Hashable {
        case contours
        case foregroundMask
        case face
        case hand
        case aesthetics

        var title: String {
            switch self {
            case .contours:
                "Contours"
            case .foregroundMask:
                "Foreground mask"
            case .face:
                "Face detection"
            case .hand:
                "Hand detection"
            case .aesthetics:
                "Aesthetics score"
            }
        }

        static var allValues: [Destination] = [.contours, .foregroundMask, .face, .hand, .aesthetics]
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(Destination.allValues, id: \.self) { destination in
                    NavigationLink(destination.title, value: destination)
                }
            }
            .navigationDestination(for: Destination.self, destination: page)
        }
    }

    @ViewBuilder
    private func page(for destination: Destination) -> some View {
        switch destination {
        case .contours:
            ContourAnalyzer()
        case .foregroundMask:
            ForegroundMaskAnalyzer()
        case .face:
            FaceAnalyzer()
        case .hand:
            HandAnalyzer()
        case .aesthetics:
            AestheticsView()
        }
    }
}

#Preview {
    ContentView()
}
