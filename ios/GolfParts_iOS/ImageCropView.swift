//
//  ImageCropView.swift
//  GolfParts_iOS
//
//  Created by Divij Wadhawan on 26.09.26.
//

import SwiftUI
import UIKit

/// Screen that allows the user to position a photo before
/// sending only the selected area to the backend/Gemini.
struct ImageCropView: View {

    // Original image selected from camera/photo library.
    let image: UIImage

    // Called when the user confirms the crop.
    let onCrop: (UIImage) -> Void

    // Called when the user cancels.
    let onCancel: () -> Void

    // Current zoom level.
    @State private var scale: CGFloat = 1.0

    // Zoom level when the current pinch gesture started.
    @State private var lastScale: CGFloat = 1.0

    // Current image position.
    @State private var offset: CGSize = .zero

    // Position when the current drag gesture started.
    @State private var lastOffset: CGSize = .zero

    var body: some View {

        GeometryReader { geometry in

            let cropSize = min(
                geometry.size.width - 40,
                geometry.size.height * 0.60
            )

            VStack(spacing: 20) {

                Text("Select the part")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Zoom and move the image until the part you want to identify fills the square.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // MARK: - Crop area

                ZStack {

                    Color.black

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cropSize, height: cropSize)
                        .scaleEffect(scale)
                        .offset(offset)

                        // Pinch to zoom.
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(
                                        1.0,
                                        min(lastScale * value, 5.0)
                                    )
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                        )

                        // Drag image around.
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                }
                .frame(width: cropSize, height: cropSize)
                .clipped()
                .cornerRadius(16)

                Text("Pinch to zoom • Drag to position")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // MARK: - Actions

                HStack(spacing: 16) {

                    Button("Cancel") {
                        onCancel()
                    }
                    .buttonStyle(.bordered)

                    Button {
                        let croppedImage = createCroppedImage(
                            cropSize: cropSize
                        )

                        if let croppedImage {
                            onCrop(croppedImage)
                        }
                    } label: {
                        Label(
                            "Analyze Selection",
                            systemImage: "sparkles"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }

    // MARK: - Image cropping

    /// Converts the crop shown on screen into a real UIImage.
    ///
    /// This is important because Gemini should receive the selected
    /// part of the vehicle rather than the entire original photograph.
    private func createCroppedImage(
        cropSize: CGFloat
    ) -> UIImage? {

        guard let cgImage = image.cgImage else {
            return nil
        }

        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)

        // scaledToFill determines how much the original image has
        // to be enlarged to completely fill our square crop area.
        let baseScale = max(
            cropSize / imageWidth,
            cropSize / imageHeight
        )

        let totalScale = baseScale * scale

        // Size of the crop rectangle in original image pixels.
        let cropWidth = cropSize / totalScale
        let cropHeight = cropSize / totalScale

        // Translate the screen offset back into original-image pixels.
        let offsetX = offset.width / totalScale
        let offsetY = offset.height / totalScale

        let cropX =
            (imageWidth - cropWidth) / 2 - offsetX

        let cropY =
            (imageHeight - cropHeight) / 2 - offsetY

        // Keep the rectangle inside the original image.
        let rect = CGRect(
            x: max(0, min(cropX, imageWidth - cropWidth)),
            y: max(0, min(cropY, imageHeight - cropHeight)),
            width: min(cropWidth, imageWidth),
            height: min(cropHeight, imageHeight)
        ).integral

        guard let croppedCGImage = cgImage.cropping(to: rect) else {
            return nil
        }

        return UIImage(
            cgImage: croppedCGImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
    }
}
