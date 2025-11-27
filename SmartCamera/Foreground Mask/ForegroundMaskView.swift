//
//  ForegroundAnalyzerView.swift
//  SmartCamera
//
//  Created by Fazekas, Gergo on 05.07.2025.
//

import SwiftUI
import PhotosUI

struct ForegroundMaskView: View {
    @State private var viewModel = ForegroundMaskViewModel()
    @State private var shouldShowMask = true
    @State private var selectedImage: PhotosPickerItem?

    var body: some View {
        VStack {
            if let photo = viewModel.photo {
                imageView(originalImage: photo)
                .onLongPressGesture(
                    minimumDuration: 0,
                    perform: {
                        shouldShowMask = false
                    },
                    onPressingChanged: { inProgress in
                        if !inProgress {
                            shouldShowMask = true
                        }
                    }
                )
            } else {
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Select an Image")
                }
            }
        }
        .padding()
        .toolbar {
            if let selectedImage {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Text("Change Image")
                        }

                        Button("Analyze") {
                            viewModel.analyzeImage(photo: selectedImage)
                        }
                    }
                }
            }
        }
        .onChange(of: selectedImage) { _, newImage in
            guard let newImage else { return }
            viewModel.analyzeImage(photo: newImage)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack {
//                ForEach($viewModel.selectedFilter.parameters, id: \.name) { $filterParameter in
//                    VStack(alignment: .center) {
//                        Slider(
//                            value: $filterParameter.value,
//                            in: filterParameter.range,
//                            step: 0.5,
//                            label: {
//                                Text("\(filterParameter.name): \(filterParameter.value)")
//                            },
//                            minimumValueLabel: {
//                                Text(String(filterParameter.range.lowerBound))
//                            },
//                            maximumValueLabel: {
//                                Text(String(filterParameter.range.upperBound))
//                            }
//                        )
//                        Text("\(filterParameter.name): \(filterParameter.value)")
//                    }
//                    .onChange(of: filterParameter.value) { _, newValue in
//                        print("mylog - new value: \(newValue)")
//                    }
//                }

                Picker("Effect", selection: $viewModel.selectedFilter) {
                    ForEach(ImageFilterType.allCases) { filterType in
                        Text(filterType.filter.title)
                            .tag(filterType)
                    }
                }
                .onChange(of: viewModel.selectedFilter) { _, newValue in
                    viewModel.selectedFilter = newValue.filter.filterType
                }
            }
            .frame(maxHeight: 200, alignment: .bottom)
        }
    }

    func imageView(originalImage: UIImage) -> some View {
        let uiImage = shouldShowMask ? viewModel.modifiedImage : originalImage

        return Image(uiImage: uiImage ?? originalImage)
            .resizable()
            .scaledToFit()
    }
}
