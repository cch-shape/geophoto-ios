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
    @EnvironmentObject var photoData: PhotoData
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isImagePickerDisplay = false
    
    @State private var showSelectTypeAlert = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        HStack {
            if let selectedImage {
                Button {
                    showSelectTypeAlert = true
                } label: {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            } else {
                HStack {
                    Spacer()
                    Image(systemName: "camera.fill")
                        .imageScale(.large)
                        .padding()
                        .background(.clear)
                        .onTapGesture {
                            print(1)
                            ShowPicker(sourceType: .camera)
                        }
                    Spacer()
                }
                Divider()
                HStack {
                    Spacer()
                    Image(systemName: "photo")
                        .imageScale(.large)
                        .padding()
                        .background(.clear)
                        .onTapGesture {
                            print(2)
                            ShowPicker(sourceType: .photoLibrary)
                        }
                    Spacer()
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
        .alert(Configs.CameraDeinedMsg, isPresented: $showPermissionAlert){
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
