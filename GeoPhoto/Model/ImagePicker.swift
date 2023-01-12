//
//  CameraPicker.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//
import UIKit
import SwiftUI
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: ImagePicker
    
    init(picker: ImagePicker) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
}

//        PhotosPicker(
//            selection: $selectedItem,
//            matching: .images,
//            photoLibrary: .shared()) {
//                Text("From Library")
//            }
//            .onChange(of: selectedItem) { newItem in
//                Task {
//                    // Retrieve selected asset in the form of Data
//                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                        selectedImageData = data
//                    }
//                }
//            }
//
//        if let selectedImageData,
//           let uiImage = UIImage(data: selectedImageData) {
//            Image(uiImage: uiImage)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 250, height: 250)
//        }
//    }
