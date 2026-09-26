//
//  PhotoPicker.swift
//  GolfParts_iOS
//
//  Created by Divij Wadhawan on 25.09.26.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {

    let onImageSelected: (UIImage) -> Void

    func makeUIViewController(
        context: Context
    ) -> PHPickerViewController {

        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(
            configuration: configuration
        )

        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    ) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onImageSelected: onImageSelected
        )
    }

    class Coordinator:
        NSObject,
        PHPickerViewControllerDelegate {

        let onImageSelected: (UIImage) -> Void

        init(
            onImageSelected:
                @escaping (UIImage) -> Void
        ) {
            self.onImageSelected = onImageSelected
        }

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {

            picker.dismiss(animated: true)

            guard let provider =
                    results.first?.itemProvider,
                  provider.canLoadObject(
                    ofClass: UIImage.self
                  ) else {
                return
            }

            provider.loadObject(
                ofClass: UIImage.self
            ) { object, error in

                guard let image =
                        object as? UIImage else {
                    return
                }

                DispatchQueue.main.async {
                    self.onImageSelected(image)
                }
            }
        }
    }
}
