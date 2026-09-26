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

    // ============================================================
    // MARK: - Input
    // ============================================================

    let image: UIImage

    let onCrop: (UIImage) -> Void

    let onCancel: () -> Void


    // ============================================================
    // MARK: - Gesture State
    // ============================================================
    //
    // We intentionally keep the simple gesture implementation
    // because it provides smooth pinch/zoom behavior on the iPhone.
    //

    @State private var scale: CGFloat = 1.0

    @State private var lastScale: CGFloat = 1.0

    @State private var offset: CGSize = .zero

    @State private var lastOffset: CGSize = .zero


    // ============================================================
    // MARK: - Normalized Image
    // ============================================================
    //
    // iPhone images may contain orientation metadata.
    //
    // SwiftUI understands this metadata, while CGImage cropping
    // works with the underlying pixels.
    //
    // Normalizing the image makes sure that:
    //
    // what the user sees
    //        ↓
    // what we crop
    //        ↓
    // what Gemini receives
    //
    // are all the same area.
    //

    private var normalizedImage: UIImage {
        image.normalizedOrientation()
    }


    // ============================================================
    // MARK: - UI
    // ============================================================

    var body: some View {

        GeometryReader { geometry in

            let cropSize = min(
                geometry.size.width - 40,
                geometry.size.height * 0.60
            )


            VStack(spacing: 20) {

                // ------------------------------------------------
                // Title
                // ------------------------------------------------

                Text("Select the part")
                    .font(.title2)
                    .fontWeight(.semibold)


                Text(
                    "Zoom and move the image until the part you want to identify fills the square."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)


                // =================================================
                // MARK: - Crop Area
                // =================================================

                ZStack {

                    Color.black


                    Image(uiImage: normalizedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: cropSize,
                            height: cropSize
                        )
                        .scaleEffect(scale)
                        .offset(offset)


                        // -----------------------------------------
                        // Pinch to zoom
                        // -----------------------------------------

                        .gesture(

                            MagnificationGesture()

                                .onChanged { value in

                                    scale = max(
                                        1.0,
                                        min(
                                            lastScale * value,
                                            5.0
                                        )
                                    )
                                }

                                .onEnded { _ in

                                    lastScale = scale
                                }
                        )


                        // -----------------------------------------
                        // Drag image
                        // -----------------------------------------

                        .simultaneousGesture(

                            DragGesture()

                                .onChanged { value in

                                    offset = CGSize(

                                        width:
                                            lastOffset.width
                                            + value.translation.width,

                                        height:
                                            lastOffset.height
                                            + value.translation.height
                                    )
                                }

                                .onEnded { _ in

                                    lastOffset = offset
                                }
                        )
                }
                .frame(
                    width: cropSize,
                    height: cropSize
                )
                .clipped()
                .cornerRadius(16)


                Text(
                    "Pinch to zoom • Drag to position"
                )
                .font(.caption)
                .foregroundStyle(.secondary)


                // =================================================
                // MARK: - Gemini Information
                // =================================================

                VStack(spacing: 6) {

                    Label(
                        "AI Visual Analysis",
                        systemImage: "sparkles"
                    )
                    .font(.headline)


                    Text(
                        "Gemini will analyze only the selected area and identify the vehicle assembly."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal)


                Spacer()


                // =================================================
                // MARK: - Actions
                // =================================================

                HStack(spacing: 16) {

                    Button("Cancel") {

                        onCancel()
                    }
                    .buttonStyle(.bordered)


                    Button {

                        let croppedImage =
                            createCroppedImage(
                                cropSize:
                                    cropSize
                            )


                        if let croppedImage {

                            onCrop(
                                croppedImage
                            )
                        }

                    } label: {

                        Label(
                            "Analyze with Gemini",
                            systemImage:
                                "sparkles"
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                }
            }
            .padding()
        }
    }


    // ================================================================
    // MARK: - Image Cropping
    // ================================================================

    private func createCroppedImage(
        cropSize: CGFloat
    ) -> UIImage? {

        // ------------------------------------------------------------
        // Always crop the normalized image.
        // ------------------------------------------------------------

        let sourceImage =
            normalizedImage


        guard let cgImage =
                sourceImage.cgImage else {

            return nil
        }


        let imageWidth =
            CGFloat(
                cgImage.width
            )


        let imageHeight =
            CGFloat(
                cgImage.height
            )


        // ============================================================
        // scaledToFill calculation
        // ============================================================

        let baseScale =
            max(

                cropSize
                    / imageWidth,

                cropSize
                    / imageHeight
            )


        let totalScale =
            baseScale
            * scale


        // ============================================================
        // Convert visible square to image pixels
        // ============================================================

        let cropWidth =
            cropSize
            / totalScale


        let cropHeight =
            cropSize
            / totalScale


        // Convert SwiftUI offset back to source-image pixels.

        let offsetX =
            offset.width
            / totalScale


        let offsetY =
            offset.height
            / totalScale


        // ============================================================
        // Crop origin
        // ============================================================

        let cropX =
            (imageWidth - cropWidth)
            / 2
            - offsetX


        let cropY =
            (imageHeight - cropHeight)
            / 2
            - offsetY


        // ============================================================
        // Keep rectangle inside source image
        // ============================================================

        let rect =
            CGRect(

                x:
                    max(
                        0,
                        min(
                            cropX,
                            imageWidth
                                - cropWidth
                        )
                    ),

                y:
                    max(
                        0,
                        min(
                            cropY,
                            imageHeight
                                - cropHeight
                        )
                    ),

                width:
                    min(
                        cropWidth,
                        imageWidth
                    ),

                height:
                    min(
                        cropHeight,
                        imageHeight
                    )
            )
            .integral


        guard let croppedCGImage =
                cgImage.cropping(
                    to: rect
                ) else {

            return nil
        }


        return UIImage(

            cgImage:
                croppedCGImage,

            scale:
                sourceImage.scale,

            orientation:
                .up
        )
    }
}


// ====================================================================
// MARK: - UIImage Orientation Normalization
// ====================================================================

private extension UIImage {

    /// Creates an upright version of an image whose underlying
    /// pixel orientation matches what SwiftUI displays.
    func normalizedOrientation() -> UIImage {

        if imageOrientation == .up {

            return self
        }


        let format =
            UIGraphicsImageRendererFormat
                .default()


        format.scale =
            scale


        let renderer =
            UIGraphicsImageRenderer(

                size:
                    size,

                format:
                    format
            )


        return renderer.image { _ in

            draw(

                in:
                    CGRect(
                        origin:
                            .zero,

                        size:
                            size
                    )
            )
        }
    }
}
