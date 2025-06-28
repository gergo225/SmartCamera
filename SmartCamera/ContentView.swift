//
//  ContentView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 27.06.2025.
//

import SwiftUI

struct ContentView: View {
    private let imageUrl = Bundle.main.url(forResource: "tree_image", withExtension: "jpg")!

    var body: some View {
        ImageAnalyzerView(imageUrl: imageUrl)
    }
}

#Preview {
    ContentView()
}
