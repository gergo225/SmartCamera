//
//  ForegroundMaskAnalyzer.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 03.07.2025.
//

import SwiftUI

struct ForegroundMaskAnalyzer: View {
    var body: some View {
        let imageUrl = Bundle.main.url(forResource: "cat", withExtension: "jpg")!

        ForegroundMaskView(imageUrl: imageUrl)
    }
}
