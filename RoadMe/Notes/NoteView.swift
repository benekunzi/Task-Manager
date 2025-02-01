//
//  NoteView.swift
//  RoadMe
//
//  Created by Benedict Kunzmann on 28.01.25.
//

import SwiftUI

struct NoteView: View {
    
    @EnvironmentObject var editorModel: EditorModel
    @FocusState private var isEditorFocused: Bool // Focus handling
    
    @State private var htmlContent: String = ""
    @State private var showEditor: Bool = false
    
    var body: some View {
        GeometryReader { reader in
            RichTextWebView(htmlContent: $htmlContent)
                .frame(height: reader.size.height)
                .opacity(showEditor ? 1 : 0)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 150_000_000)
                withAnimation(.easeInOut) {
                    print("show editor")
                    showEditor = true
                }
            }
        }
    }
}
