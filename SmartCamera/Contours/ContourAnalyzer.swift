//
//  ContourAnalyzer.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 03.07.2025.
//

import SwiftUI

struct ContourAnalyzer: View {
    enum ContourDestination: Hashable {
        case image
        case video

        var title: String {
            switch self {
            case .image:
                "Image"
            case .video:
                "Video"
            }
        }

        var systemImage: String {
            switch self {
            case .image:
                "photo"
            case .video:
                "video"
            }
        }
    }

    var body: some View {
        HStack(spacing: 32) {
            button(for: .image)
            button(for: .video)
        }
        .navigationDestination(for: ContourDestination.self, destination: page)
    }

    private func button(for destination: ContourDestination) -> some View {
        NavigationLink {
            page(for: destination)
        } label: {
            Label(destination.title, systemImage: destination.systemImage)
        }
    }

    @ViewBuilder
    private func page(for destination: ContourDestination) -> some View {
        switch destination {
        case .image:
            ImageContourView()
        case .video:
            VideoContourView()
        }
    }
}
