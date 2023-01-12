//
//  PhotoPicker.swift
//  GeoPhoto
//
//  Created by Chi hin cheung on 12/1/2023.
//

import SwiftUI
import PhotosUI

struct ImagePickerCard: View {
    @Binding var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isImagePickerDisplay = false
    
    @State private var showSelectTypeAlert = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        HStack {
            Button {
                showSelectTypeAlert = true
            } label: {
                if let selectedImage {
                    Button {
                        showSelectTypeAlert = true
                    } label: {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                } else {
                    List {
                        Button {
                            ShowPicker(sourceType: .camera)
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "camera.fill")
                                    .imageScale(.large)
                                Spacer()
                            }
                        }
                        .padding()
                        Divider()
                        Button {
                            ShowPicker(sourceType: .photoLibrary)
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "photo")
                                    .imageScale(.large)
                                Spacer()
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .alert("Replace Photo", isPresented: $showSelectTypeAlert){
            Button("Camera") {
                ShowPicker(sourceType: .camera)
            }
            Button("Photo Library") {
                ShowPicker(sourceType: .photoLibrary)
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Grant access to your camera", isPresented: $showPermissionAlert){
            Button("Open Settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $isImagePickerDisplay) {
            ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
    }
    
    private func ShowPicker(sourceType: UIImagePickerController.SourceType) {
        self.sourceType = sourceType
        if sourceType == .photoLibrary {
            self.isImagePickerDisplay = true
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isImagePickerDisplay = true
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.isImagePickerDisplay = true
                    return
                }
            }
        case .denied:
            showPermissionAlert = true
            return
        default:
            self.sourceType = .photoLibrary
            self.isImagePickerDisplay = true
            return
        }
    }
}
