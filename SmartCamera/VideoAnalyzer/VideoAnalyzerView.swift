//
//  VideoAnalyzerView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 29.06.2025.
//

import SwiftUI

struct VideoAnalyzerView: View {
    @State private var viewModel = VideoAnalyzerViewModel()

    var body: some View {
        VideoView {
            viewModel.processFrame($0)
        }
    }
}
