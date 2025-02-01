//
//  MediaView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 29.01.25.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import WebKit

struct MediaView: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var projectModel: ProjectModel
    @EnvironmentObject var editorModel: EditorModel
    
    @State private var showImagePicker: Bool = false
    @State private var showFilePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    private let impactMed = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                HStack {
                    Image(systemName: "photo")
                        .font(.system(size: 16))
                    Text("Add photo")
                        .font(.custom(GhibliFont.medium.name, size: 14))
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(
                            Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                        )
                )
                .foregroundStyle(
                    Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                )
                .onTapGesture {
                    impactMed.impactOccurred()
                    showImagePicker = true
                }
                
                HStack {
                    Image(systemName: "doc")
                        .font(.system(size: 16))
                    Text("Add document")
                        .font(.custom(GhibliFont.medium.name, size: 14))
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    Capsule()
                        .fill(
                            Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.secondary ?? themeManager.currentTheme.colors["green"]!.secondary)
                        )
                )
                .foregroundStyle(
                    Color(themeManager.currentTheme.colors[projectModel.selectedTask.color]?.primary ?? themeManager.currentTheme.colors["green"]!.primary)
                )
                .onTapGesture {
                    impactMed.impactOccurred()
                    showFilePicker = true
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage) { image in
                if let data = image.jpegData(compressionQuality: 1) {
                    let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("pickedImage.jpg")
                    try? data.write(to: tempUrl)

                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first,
                       let webView = window.rootViewController?.view?.findSubview(ofType: WKWebView.self) {
                        insertImage(tempUrl.absoluteString, webView: webView)
                    }
                }
            }
        }
        .sheet(isPresented: $showFilePicker) {
            FilePicker { url in
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first,
                   let webView = window.rootViewController?.view?.findSubview(ofType: WKWebView.self) {
                    insertFile(url.absoluteString, fileName: url.lastPathComponent, webView: webView)
                }
            }
        }
    }
    
    func insertImage(_ imageUrl: String, webView: WKWebView) {
        let jsCode = "insertImage('\(imageUrl)');"
        webView.evaluateJavaScript(jsCode, completionHandler: nil)
    }

    func insertFile(_ fileUrl: String, fileName: String, webView: WKWebView) {
        let jsCode = "insertFile('\(fileUrl)', '\(fileName)');"
        webView.evaluateJavaScript(jsCode, completionHandler: nil)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            if let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        if let uiImage = image as? UIImage {
                            self.parent.image = uiImage
                            self.parent.onImagePicked(uiImage)
                        }
                    }
                }
            }
        }
    }
}

struct FilePicker: UIViewControllerRepresentable {
    var onFilePicked: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePicker

        init(_ parent: FilePicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.onFilePicked(url)
            }
        }
    }
}
