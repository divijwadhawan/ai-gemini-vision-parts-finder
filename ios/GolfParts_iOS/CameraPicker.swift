//
//  CameraPicker.swift
//  GolfParts_iOS
//
//  Created by Divij Wadhawan on 25.09.26.
//

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {

    let onImageSelected: (UIImage) -> Void

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {

        let picker = UIImagePickerController()

        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator

        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
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
        UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {

        let onImageSelected: (UIImage) -> Void

        init(
            onImageSelected:
                @escaping (UIImage) -> Void
        ) {
            self.onImageSelected = onImageSelected
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info:
                [UIImagePickerController.InfoKey: Any]
        ) {

            picker.dismiss(animated: true)

            guard let image =
                    info[.originalImage] as? UIImage else {
                return
            }

            onImageSelected(image)
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            picker.dismiss(animated: true)
        }
    }
}
